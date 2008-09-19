package WebGUI::Crud;

use strict;
use Class::InsideOut qw(readonly private id register);
use JSON;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Exception;


private objectData => my %objectData;
readonly session => my %session;


#-------------------------------------------------------------------
sub create {
	my ($class, $session, $data) = @_;
	
	# validate 
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	
	# initialize
	my $definition = $class->crud_definition;
	my $tableKey = $class->crud_getTableKey;
	my $tableName = $class->crud_getTableName;
	my $db = $session->db;
	my $dbh = $db->dbh;

	# get creation date
	my $now = WebGUI::DateTime->new($session, time())->toDatabase;
	$data->{lastUpdated} = $now;

	# add defaults
	my $properties = $class->crud_getProperties;
	foreach my $property (keys %{$properties}) {
		$data->{$property} ||= $properties->{$property}{defaultValue};
	}
	
	# determine sequence
	my $sequenceKey = $class->crud_getSequenceKey;
	my $clause;
	my @params;
	if ($sequenceKey) {
		$clause = "where ".$dbh->quote_identifier($sequenceKey)."=?";
		push @params, $data->{$sequenceKey};
	}
	my $sequenceNumber = $db->getScalar("select max(sequenceNumber) from ".$dbh->quote_identifier($tableName)." $clause", \@params);
	$sequenceNumber++;

	# create object
	my $id = $db->setRow($tableName, $tableKey, {$tableKey=>'new', dateCreated=>$now, sequenceNumber=>$sequenceNumber});
	my $self = $class->new($session, $id);
	$self->update($data);
	return $self;
}

#-------------------------------------------------------------------
sub crud_createTable {
	my ($class, $session) = @_;
	my $db = $session->db;
	my $dbh = $db->dbh;
	$db->write('create table '.$dbh->quote_identifier($class->crud_getTableName).' (
		'.$dbh->quote_identifier($class->crud_getTableKey).' varchar(22) binary not null primary key,
		sequenceNumber int not null default 1,
		dateCreated datetime,
		lastUpdated datetime
		)');
	$class->crud_updateTable($session);
	return 1;
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
	my $db = $session->db;
	my $dbh = $db->dbh;
	$db->write("drop table ".$dbh->quote_identifier($class->crud_getTableName)."");
	return 1;
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
	my $dbh = $db->dbh;
	my $tableName = $dbh->quote_identifier($class->crud_getTableName);
	
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
			#	$db->write("alter table $tableName change column ".$dbh->quote_identifier($property)." ".$dbh->quote_identifier($property)." $fieldType");
			#}
			delete $tableFields{$property};
		}
		else {
			$db->write("alter table $tableName add column ".$dbh->quote_identifier($property)." $fieldType");
			delete $tableFields{$property};
		}
	}
	
	# delete fields that are no longer in the definition
	foreach my $property (keys %tableFields) {
		$db->write("alter table $tableName drop column ".$dbh->quote_identifier($property));	
	}
	return 1;
}

#-------------------------------------------------------------------
sub delete {
	my $self = shift;
	$self->session->db->deleteRow($self->crud_getTableName, $self->crud_getTableKey, $self->getId);
	$self->reorder;
	return 1;
}

#-------------------------------------------------------------------
sub demote {
	my $self = shift;
	my $tableKey = $self->crud_getTableKey;
	my $tableName = $self->crud_getTableName;
	my $sequenceKey = $self->crud_getSequenceKey;
	my @params = ($self->get('sequenceNumber') + 1);
	my $db = $self->session->db;
	my $dbh = $db->dbh;
	my $clause = '';
	
	# determine sequence
	if ($sequenceKey) {
		$clause = $dbh->quote_identifier($sequenceKey)."=? and";
		unshift @params, $self->get($sequenceKey)
	}
	
	# update database
	$db->beginTransaction;
    my ($id) = $db->quickArray("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)." where  $clause sequenceNumber=?", \@params);
    if ($id ne "") {
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber+1 where ".$dbh->quote_identifier($tableKey)."=?",[$self->getId]);
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber-1 where ".$dbh->quote_identifier($tableKey)."=?",[$id]);
    }
	$db->commit;
	return 1;
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
sub getAll {
	my ($class, $session, $options) = @_;
	my $db = $session->db;
	my $dbh = $db->dbh;
	my @objects;
	my $ids = $session->db->read("select ".$dbh->quote_identifier($class->crud_getTableKey)." from ".$dbh->quote_identifier($class->crud_getTableName));
	while (my ($id) = $ids->array) {
		if ($options->{return} eq "ids") {
			push @objects, $id;
		}
		else {
			push @objects, $class->new($session, $id);
		}
	}
	return \@objects;
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
	my $data = $session->db->getRow($class->crud_getTableName, $tableKey, $id);
	if ($data->{$tableKey} eq '') {
        WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$tableKey, id=>$id);
    }
	
	# deserialize data
	my $properties = $class->crud_getProperties;
	foreach my $name (keys %{$properties}) {
		if ($properties->{$name}{serialize}) {
			$data->{$name} = JSON->new->decode($data->{$name});
		}
	}
	
	# set up object
	my $self = register($class);
	my $refId = id $self;
	$objectData{$refId} = $data;
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
	my $db = $self->session->db;
	my $dbh = $db->dbh;
	
	# determine sequence type
	if ($sequenceKey) {
		$clause = $dbh->quote_identifier($sequenceKey)."=? and";
		unshift @params, $self->get($sequenceKey)
	}
	
	# make database changes
	$db->beginTransaction;
    my ($id) = $db->quickArray("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)." where ".$dbh->quote_identifier($sequenceKey)."=? $clause", \@params);
    if ($id ne "") {
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber-1 where ".$dbh->quote_identifier($tableKey)."=?",[$self->getId]);
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber+1 where ".$dbh->quote_identifier($tableKey)."=?",[$id]);
    }
	$db->commit;
	return 1;
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
	my $dbh = $db->dbh;
	
	# find all the items in this sequence
	my $clause = ($sequenceKey) ? "where ".$dbh->quote_identifier($sequenceKey)."=?" : '';
	my $current = $db->read("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)."
			$clause order by sequenceNumber", [$sequenceKeyValue]);
	
	# query to update items in the sequence
	$clause = ($sequenceKey) ? "and ".$dbh->quote_identifier($sequenceKey)."=?" : '';
	my $change = $db->prepare("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=?
			where ".$dbh->quote_identifier($tableKey)."=? $clause");
	
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
	return 1;
}

#-------------------------------------------------------------------
sub update {
	my ($self, $data) = @_;
	
	# validate incoming data
	my $properties = $self->crud_getProperties;
	foreach my $property (keys %{$data}) {
		
		# don't save fields that aren't part of our definition
		unless (exists $properties->{$property} || $property eq 'lastUpdated') {
			delete $data->{$property};
			next;
		}
		
		# set a default value if it's empty or undef
		$data->{$property} ||= $properties->{$property}{defaultValue};
		
		# serialize if needed
		if ($properties->{$property}{serialize}) {
			$data->{property} = JSON->new->encode($data->{property});
		}
	}
	
	# set last updated
	$data->{lastUpdated} ||= WebGUI::DateTime->new($self->session, time())->toDatabase;
	
	# update memory
	my $refId = id $self;
	%{$objectData{$refId}} = (%{$objectData{$refId}}, %{$data});
	
	# update the database
	$self->session->db->setRow($self->crud_getTableName, $self->crud_getTableKey, $objectData{$refId});
	return 1;
}


1;
