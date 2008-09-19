package WebGUI::Crud;

use strict;
use Class::InsideOut qw(readonly private id register);
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Exception;


private objectData => my %objectData;
readonly session => my %session;


#-------------------------------------------------------------------
sub create {
	my ($class, $session, $properties) = @_;
	
	# validate 
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	
	# initialize
	my $definition = $class->crud_definition;
	my $tableKey = $class->crud_getTableKey;
	my $tableName = $class->crud_getTableName;
	my $db = $session->db;

	# get creation date
	my $now = WebGUI::DateTime->new($session, time())->toDatabase;

	# determine sequence
	my $sequenceKey = $class->crud_getSequenceKey;
	my $clause;
	my @params;
	if ($sequenceKey) {
		$clause = "where `".$sequenceKey."`=?";
		push @params, $properties->{$sequenceKey};
	}
	my $sequenceNumber = $db->getScalar("select max(sequenceNumber) from `".$tableName."` $clause", \@params);
	$sequenceNumber++;
	
	# create object
	my $id = $db->setRow($tableName, $tableKey, {$tableKey=>'new', dateCreated=>$now, lastUpdated=>$now, sequenceNumber=>$sequenceNumber});
	my $self = $class->new($session, $id);
	$self->update($properties);
	return $self;
}

#-------------------------------------------------------------------
sub crud_createTable {
	my ($class, $session) = @_;
	$session->db->write('create table `'.$class->crud_getTableName.'` (
		`'.$class->crud_getTableKey.'` varchar(22) binary not null primary key,
		sequenceNumber int not null default 1,
		dateCreated datetime,
		lastUpdated datetime
		)');
	$class->crud_updateTable($session);
}

#-------------------------------------------------------------------
sub crud_definition {
	my $class = shift;
	tie my %properties, 'Tie::IxHash';
	my %definition = (
		tableName 	=> 'unamed_crud_table',
		tableKey	=> 'id',
		sequenceKey => '',
		properties	=> \%properties,
	);
	return \%definition;
}

#-------------------------------------------------------------------
sub crud_dropTable {
	my ($class, $session) = @_;
	$session->db->write("drop table `".$class->crud_getTableName."`");
}

#-------------------------------------------------------------------
sub crud_getProperties {
	my $class = shift;
	return $class->crud_definition->{properties};
}

#-------------------------------------------------------------------
sub crud_getSequenceKey {
	my $class = shift;
	my $definition = $class->crud_definition;
	return $definition->{sequenceKey};
}

#-------------------------------------------------------------------
sub crud_getTableName {
	my $class = shift;
	return $class->crud_definition->{tableName};
}

#-------------------------------------------------------------------
sub crud_getTableKey {
	my $class = shift;
	return $class->crud_definition->{tableKey};
}

#-------------------------------------------------------------------
sub crud_updateTable {
	my ($class, $session) = @_;
	my $db = $session->db;
	my $tableName = '`'.$class->crud_getTableName.'`';
	
	# find out what fields already exist
	my %tableFields = ();
	my $sth = $db->read("DESCRIBE ".$tableName);
	while (my ($col, $type) = $sth->array) {
		$tableFields{$col} = $type;
	}
	
	# update existing and create new fields
	my $properties = $class->crud_getProperties;
	foreach my $property (keys %{$properties}) {
		my $control = WebGUI::Form::DynamicField->new( $session, %{ $properties->{ $property } });
		my $fieldType = $control->getDatabaseFieldType;
		if (exists $tableFields{$property}) {
			### have to figure out field type matching
			#unless ($fieldType eq $tableFields{$property}) {
			#	$db->write("alter table $tableName change column `".$property."` `".$property."` $fieldType");
			#}
			delete $tableFields{$property};
		}
		else {
			$db->write("alter table $tableName add column `".$property."` $fieldType");
			delete $tableFields{$property};
		}
	}
	
	# delete fields that are no longer in the definition
	foreach my $property (keys %tableFields) {
		$db->write("alter table $tableName drop column `".$property."`");	
	}
}

#-------------------------------------------------------------------
sub delete {
	my $self = shift;
	$self->session->db->deleteRow($self->crud_getTableName, $self->crud_getTableKey, $self->getId);
	$self->reorder;
}

#-------------------------------------------------------------------
sub demote {
	my $self = shift;
	my $tableKey = $self->crud_getTableKey;
	my $tableName = $self->crud_getTableName;
	my $sequenceKey = $self->crud_getSequenceKey;
	my @params = ($self->get('sequenceNumber') + 1);
	my $clause = '';
	
	# determine sequence
	if ($sequenceKey) {
		$clause = "`".$sequenceKey."`=? and";
		unshift @params, $self->get($sequenceKey)
	}
	
	# update database
	my $db = $self->session->db;
	$db->beginTransaction;
    my ($id) = $db->quickArray("select `".$tableKey."` from `".$tableName."` where  $clause sequenceNumber=?", \@params);
    if ($id ne "") {
        $db->write("update `".$tableName."` set sequenceNumber=sequenceNumber+1 where `".$tableKey."`=?",[$self->getId]);
        $db->write("update `".$tableName."` set sequenceNumber=sequenceNumber-1 where `".$tableKey."`=?",[$id]);
    }
	$db->commit;
}

#-------------------------------------------------------------------
sub get {
	my ($self, $name) = @_;
	
	# return a specific property
	if (defined $name) {
		return $self->objectData->{$name};
	}
	
	# return a copy of all properties
	my %copy = %{$self->objectData};
	return \%copy;
}

#-------------------------------------------------------------------
sub getId {
	my $self = shift;
	return $self->objectData->{$self->crud_getTableKey};
}

#-------------------------------------------------------------------
sub new {
	my ($class, $session, $id) = @_;
	my $tableKey = $class->crud_getTableKey;
	
	# validate
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
    unless (defined $id && $id =~ m/^[A-Za-z0-9_-]{22}$/) {
        WebGUI::Error::InvalidParam->throw(error=>'need a '.$tableKey);
    }
	
	# retrieve object data
	my $properties = $session->db->getRow($class->crud_getTableName, $tableKey, $id);
	if ($properties->{$tableKey} eq '') {
        WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$tableKey, id=>$id);
    }
	
	# set up object
	my $self = register($class);
	my $refId = id $self;
	$objectData{$refId} = $properties;
	$session{$refId} = $session;
	return $self;
}

#-------------------------------------------------------------------
sub promote {
	my $self = shift;
	my $tableKey = $self->crud_getTableKey;
	my $tableName = $self->crud_getTableName;
	my $sequenceKey = $self->crud_getSequenceKey;
	my $sequenceKeyValue = $self->get($sequenceKey);
	my @params = ($self->get('sequenceNumber')-1);
	my $clause = '';
	
	# determine sequence type
	if ($sequenceKey) {
		$clause = "`".$sequenceKey."`=? and";
		unshift @params, $self->get($sequenceKey)
	}
	
	# make database changes
	my $db = $self->session->db;
	$db->beginTransaction;
    my ($id) = $db->quickArray("select `".$tableKey."` from `".$tableName."` where `".$sequenceKey."`=? $clause", \@params);
    if ($id ne "") {
        $db->write("update `".$tableName."` set sequenceNumber=sequenceNumber-1 where `".$tableKey."`=?",[$self->getId]);
        $db->write("update `".$tableName."` set sequenceNumber=sequenceNumber+1 where `".$tableKey."`=?",[$id]);
    }
	$db->commit;
}

#-------------------------------------------------------------------
sub reorder {
	my ($self) = @_;
	my $tableKey = $self->crud_getTableKey;
	my $tableName = $self->crud_getTableName;
	my $sequenceKey = $self->crud_getSequenceKey;
	my $sequenceKeyValue = $self->get($sequenceKey);	
	my $i = 1;
	my $db = $self->session->db;
	
	# find all the items in this sequence
	my $clause = ($sequenceKey) ? "where `".$sequenceKey."`=?" : '';
	my $current = $db->read("select `".$tableKey."` from `".$tableName."`
			$clause order by sequenceNumber", [$sequenceKeyValue]);
	
	# query to update items in the sequence
	$clause = ($sequenceKey) ? "and `".$sequenceKey."`=?" : '';
	my $change = $db->prepare("update `".$tableName."` set sequenceNumber=?
			where `".$tableKey."`=? $clause");
	
	# make the changes
	$db->beginTransaction;
    while (my ($id) = $current->array) {
		if ($id eq $self->getId) {
			$objectData{id $self} = $i;
		}
		$change->execute([$i, $id, $sequenceKeyValue]);
        $i++;
    }
	$db->commit;
}

#-------------------------------------------------------------------
sub update {
	my ($self, $properties) = @_;
	
	# set last updated
	$properties->{lastUpdated} = WebGUI::DateTime->new($self->session, time())->toDatabase;
	
	# update memory
	my $refId = id $self;
	%{$objectData{$refId}} = (%{$objectData{$refId}}, %{$properties});
	
	# update the database
	$self->session->db->setRow($self->crud_getTableName, $self->crud_getTableKey, $objectData{$refId});
}


1;
