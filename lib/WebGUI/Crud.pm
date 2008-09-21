package WebGUI::Crud;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Class::InsideOut qw(readonly private id register);
use JSON;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Exception;


private objectData => my %objectData;
readonly session => my %session;

=head1 NAME

Package WebGUI::Crud

=head1 DESCRIPTION

CRUD = Create, Read, Update, and Delete. This package should be the base class for almost all database backed objects. It provides all the basics you will need when creating such objects, and creates a nice uniform class signature to boot. 

=head1 SYNOPSIS

WebGUI::Crud can be used in one of two ways. You can create a subclass with a defined definition. Or you can create a subclass that dynamically generates it's definition.

=head2 Static Subclass

The normal way to use WebGUI::Crud is to create a subclass that defines a specific definition. In your subclass you'd override the crud_definition() method with your own like this:

 sub crud_definition {
	my ($class, $session) = @_;
	my $definition = $class->SUPER::crud_definition($session);
	$definition->{tableName} = 'ambassador';
	$definition->{tableKey} = 'ambassadorId';
	$definition->{properties}{name} = {
			fieldType		=> 'text',
			defaultValue	=> undef,
		};
	$definition->{properties}{emailAddress} = {
			fieldType		=> 'email',
			defaultValue	=> undef,
		};
	return $definition;
 }
 
=head2 Dynamic Subclass

A more advanced approach is to create a subclass that dynamically generates a definition from a database table or a config file.

 sub crud_definition {
	my ($class, $session) = @_;
	my $definition = $class->SUPER::crud_definition($session);
	my $config = Config::JSON->new('/path/to/file.cfg');
	$definition->{tableName} = $config->get('tableName');
	$definition->{tableKey} = $config->get('tableKey');
	my $fields = $config->get('fields');
	foreach my $fieldName (keys %{$fields}) {
		$definition->{properties}{$fieldName} = $fields->{$fieldName};
	}
	return $definition;
 }

=head2 Usage

Once you have a crud class, you can use it's methods like this:

 use WebGUI::Crud::Subclass;

 $sequenceKey = WebGUI::Crud::Subclass->crud_getSequenceKey($session);
 $tableKey = WebGUI::Crud::Subclass->crud_getTableKey($session);
 $tableName = WebGUI::Crud::Subclass->crud_getTableName($session);
 $propertiesHashRef = WebGUI::Crud::Subclass->crud_getProperties($session);
 $definitionHashRef = WebGUI::Crud::Subclass->crud_definition($session);

 $crud = WebGUI::Crud::Subclass->create($session, $properties);
 $crud = WebGUI::Crud::Subclass->new($session, $id);

 $sql = WebGUI::Crud::Subclass->getAllSql($session, $options);
 $arrayRef = WebGUI::Crud::Subclass->getAllIds($session, $options);
 $iterator = WebGUI::Crud::Subclass->getAllIterator($session, $options);
 while (my $object = $iterator->()) {
	...
 }
 
 $id = $crud->getId;
 $hashRef = $crud->get;
 $value = $crud->get($propertyName);
 
 $success = $crud->promote;
 $success = $crud->demote;
 $success = $crud->delete;
 $success = $crud->update($properties);
 $success = $crud->reorder;
 
=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 create ( session, [ properties ])

Constructor. Creates a new instance of this object. Returns a reference to the object.

=head3 session

A reference to a WebGUI::Session.

=head3 properties

The properties that you wish to create this object with. Note that if this object has a sequenceKey then that sequence key must be specified in these properties or it will throw an execption. See crud_definition() for a list of all the properties.

=cut

sub create {
	my ($class, $session, $data) = @_;
	
	# validate 
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	
	# initialize
	my $definition = $class->crud_definition($session);
	my $tableKey = $class->crud_getTableKey($session);
	my $tableName = $class->crud_getTableName($session);
	my $db = $session->db;
	my $dbh = $db->dbh;

	# get creation date
	my $now = WebGUI::DateTime->new($session, time())->toDatabase;
	$data->{lastUpdated} = $now;

	# add defaults
	my $properties = $class->crud_getProperties($session);
	foreach my $property (keys %{$properties}) {
		$data->{$property} ||= $properties->{$property}{defaultValue};
	}
	
	# determine sequence
	my $sequenceKey = $class->crud_getSequenceKey($session);
	my $clause;
	my @params;
	if ($sequenceKey) {
		$clause = "where ".$dbh->quote_identifier($sequenceKey)."=?";
		push @params, $data->{$sequenceKey};
	}
	my $sequenceNumber = $db->quickScalar("select max(sequenceNumber) from ".$dbh->quote_identifier($tableName)." $clause", \@params);
	$sequenceNumber++;

	# create object
	my $id = $db->setRow($tableName, $tableKey, {$tableKey=>'new', dateCreated=>$now, sequenceNumber=>$sequenceNumber});
	my $self = $class->new($session, $id);
	$self->update($data);
	return $self;
}

#-------------------------------------------------------------------

=head2 crud_createTable ( session )

A management class method used to create the database table using the crud_definition(). Returns 1 on successful completion. 

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_createTable {
	my ($class, $session) = @_;
	my $db = $session->db;
	my $dbh = $db->dbh;
	my $tableName = $class->crud_getTableName($session);
	$db->write('create table '.$dbh->quote_identifier($tableName).' (
		'.$dbh->quote_identifier($class->crud_getTableKey($session)).' varchar(22) binary not null primary key,
		sequenceNumber int not null default 1,
		dateCreated datetime,
		lastUpdated datetime
		)');
	$class->crud_updateTable($session);
	my $sequenceKey = $class->crud_getSequenceKey($session);
	if ($sequenceKey) {
		$db->write('alter table '.dbh->quote_identifier($tableName).'
			add index '.$dbh->quote_identifier($sequenceKey).' ('.$dbh->quote_identifier($sequenceKey).')');
	}
	return 1;
}

#-------------------------------------------------------------------

=head2 crud_definition ()

A management class method that returns the properties necessary to construct this object. This should be extended by all subclasses.

B<NOTE:> When you subclass WebGUI::Crud, note the properties you're defining in the POD of this method. That way it's in a consistent place for all subclasses. There are no settable properties by default, but all WebGUI::Crud objects have an id (who's name is set with tableKey), dateCreated, lastUpdated, and sequenceNumber.

Returns a hash reference that looks like this:

 {
	tableName	=> 'unnamed_crud_table',
	tableKey	=> 'id',
	sequenceKey => '',
	properties  => {},
 }

tableName is the name of the database table that will be used or created by this object.

tableKey is the name of the column in the database table that will act as the primary key.

sequenceKey is the name of any field in the table that will be used as a grouping mechanism to allow multiple sequences per table. For example, you might use an assetId so that all items attached to an asset can be ordered independent of other assets.

properties is a hash reference tied to IxHash so that it maintains its order. It's used to define properties of this objects and columns in the table. It should look like this:

 {
	companyName	=> {
		fieldType		=> 'text',
		defaultValue	=> 'Acme Widgets',
		label			=> 'Company Name',
		serialize		=> 0,
	},
	companyWebSite	=> {
		fieldType		=> 'url',
		defaultValue	=> undef,
		serialize		=> 0,
	},
 }

The properties of each field can be any property associated with a WebGUI::Form::Control. There are two special properties as well. They are fieldType and serialize.

fieldType is the WebGUI::Form::Control type that you wish to associate with this field. It is required for all fields. Examples are 'HTMLarea', 'text', 'url', 'email', and 'selectBox'.

serialize tells WebGUI::Crud to automatically serialize this field in a JSON wrapper before storing it to the database, and to convert it back to it's native structure upon retrieving it from the database. This is useful if you wish to persist hash references or array references.

=cut

sub crud_definition {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	tie my %properties, 'Tie::IxHash';
	my %definition = (
		tableName 	=> 'unnamed_crud_table',
		tableKey	=> 'id',
		sequenceKey => '',
		properties	=> \%properties,
	);
	return \%definition;
}

#-------------------------------------------------------------------

=head2 crud_dropTable ( session )

A management class method that will drop the table created by crud_createTable(). Returns 1 on success.

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_dropTable {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	my $db = $session->db;
	my $dbh = $db->dbh;
	$db->write("drop table ".$dbh->quote_identifier($class->crud_getTableName($session)));
	return 1;
}

#-------------------------------------------------------------------

=head2 crud_getProperties ( session )

A management class method that returns just the 'properties' from crud_definition().

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_getProperties {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	return $class->crud_definition($session)->{properties};
}

#-------------------------------------------------------------------

=head2 crud_getSequenceKey ( session )

A management class method that returns just the 'sequenceKey' from crud_definition().

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_getSequenceKey {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	my $definition = $class->crud_definition($session);
	return $definition->{sequenceKey};
}

#-------------------------------------------------------------------

=head2 crud_getTableName ( session )

A management class method that returns just the 'tableName' from crud_definition().

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_getTableName {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	return $class->crud_definition($session)->{tableName};
}

#-------------------------------------------------------------------

=head2 crud_getTableKey ( session )

A management class method that returns just the 'tableKey' from crud_definition().

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_getTableKey {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	return $class->crud_definition($session)->{tableKey};
}

#-------------------------------------------------------------------

=head2 crud_updateTable ( session )

A management class method that tries to resolve the differences between the database table and the definition. Returns 1 on success.

B<WARNING:> This works perfectly for adding new fields, but is not perfect at making changes to fields. For that reason we recommend you write your own upgrade scripts when making database changes rather than relying upon this API at this time.

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_updateTable {
	my ($class, $session) = @_;
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
	my $db = $session->db;
	my $dbh = $db->dbh;
	my $tableName = $dbh->quote_identifier($class->crud_getTableName($session));
	
	# find out what fields already exist
	my %tableFields = ();
	my $sth = $db->read("DESCRIBE ".$tableName);
	my $tableKey = $class->crud_getTableKey($session);
	while (my ($col, $type) = $sth->array) {
		next if ($col eq $tableKey);
		next if ($col eq 'lastUpdated');
		next if ($col eq 'dateCreated');
		next if ($col eq 'sequenceNumber');
		$tableFields{$col} = $type;
	}
	
	# update existing and create new fields
	my $properties = $class->crud_getProperties($session);
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

=head2 delete ()

Deletes this object from the database. Returns 1 on success.

=cut

sub delete {
	my $self = shift;
	$self->session->db->deleteRow($self->crud_getTableName($self->session), $self->crud_getTableKey($self->session), $self->getId);
	$self->reorder;
	return 1;
}

#-------------------------------------------------------------------

=head2 demote ()

Moves this object one position closer to the end of its sequence. If the object is already at the bottom of the sequence then no change will be made. Returns 1 on success.

=cut

sub demote {
	my $self = shift;
	my $tableKey = $self->crud_getTableKey($self->session);
	my $tableName = $self->crud_getTableName($self->session);
	my $sequenceKey = $self->crud_getSequenceKey($self->session);
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
    my $id = $db->quickScalar("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)." where $clause sequenceNumber=?", \@params);
    if ($id ne "") {
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber+1 where ".$dbh->quote_identifier($tableKey)."=?",[$self->getId]);
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber-1 where ".$dbh->quote_identifier($tableKey)."=?",[$id]);
		$objectData{id $self}{sequenceNumber}++;
    }
	$db->commit;
	return 1;
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a hash reference of all the properties of this object.

=head3 property

If specified, returns the value of the property associated with this this property name. Returns undef if the property doesn't exist. See crud_definition() in the subclass of this class for a complete list of properties.

=cut

sub get {
	my ($self, $name) = @_;
	
	# return a specific property
	if (defined $name) {
		return $objectData{id $self}{$name};
	}
	
	# return a copy of all properties
	my %copy = %{$objectData{id $self}};	
	return \%copy;
}

#-------------------------------------------------------------------

=head2 getAllIds ( )

A class method that returns a list of all the ids in this object type. Has the same signature of getAllSql().

=cut

sub getAllIds {
	my ($class, $session, $options) = @_;
	my @objects;
	my @params;
	if ($options->{sequenceKeyValue}) {
		push @params, $options->{sequenceKeyValue};
	}
	my $ids = $session->db->read($class->getAllSql($session, $options, @_), \@params);
	while (my ($id) = $ids->array) {
		push @objects, $id;
	}
	return \@objects;
}

#-------------------------------------------------------------------

=head2 getAllIterator ( )

A class method that returns an iterator of all the instanciated objects in this object type. Has the same signature of getAllSql().

=cut

sub getAllIterator {
	my ($class, $session, $options) = @_;
	my @objects;
	my $ids = $class->getAllIds($session, $options, @_);
    my $sub = sub {
        my ($id) = shift @{$ids};
        return if !$id;
        my $object = $class->new($session, $id);
        if (!$object) {
            WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$class->getTableKey, id => $id);
        }
        return $object;
    };
    return $sub;
}

#-------------------------------------------------------------------

=head2 getAllSql ( session, [ options ] )

A class method that returns the SQL necessary to retrieve all of the records for this object.

=head3 session

A reference to a WebGUI::Session.

=head3 options

A hash reference of optional rules to modify the returned results.

=head4 limit

Either an integer representing the number of records to return, or an array reference of an integer of the starting record position and another integer representing the number of records to return.

=head4 orderBy

A field name to order the results by. Defaults to sequenceNumber.

=head4 sequenceKeyValue

If specified will limit the query to a specific sequence identified by this sequence key value. Note the object must have a sequenceKey specified in the crud_definition for this to work.

=cut

sub getAllSql {
	my ($class, $session, $options) = @_;
	my $dbh = $session->db->dbh;
	my @where;
	my $limit;
	my $order = " order by sequenceNumber";
	
	# the base query
	my $sql = "select ".$dbh->quote_identifier($class->crud_getTableKey($session))." from ".$dbh->quote_identifier($class->crud_getTableName($session));

	# limit to our sequence
	my $sequenceKey = $class->crud_getSequenceKey($session);
	if ($options->{sequenceKeyValue} && $sequenceKey) {
		push @where, $dbh->quote_identifier($sequenceKey)."=?";
	}

	# merge all clauses with the main query
	if (scalar(@where)) {
		$sql .= join(" AND ", @where);
	}
	
	# construct a record limit
	if ( exists $options->{limit}) {
		if (ref $options->{limit} eq "ARRAY") {
			$limit = " limit ".$options->{limit}[0].",".$options->{limit}[1];
		}
		else {
			$limit = " limit ".$options->{limit};
		}
	}
	
	# custom order by field
	if (exists $options->{orderBy}) {
		$order = " order by ".$dbh->quote_identifier($options->{orderBy});
	}
	
	return $sql . $order . $limit;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns a guid, this object's unique identifier.

=cut

sub getId {
	my $self = shift;
	return $objectData{id $self}{$self->crud_getTableKey($self->session)};
}

#-------------------------------------------------------------------

=head2 new ( session, id )

Constructor.

=head3 session

A reference to a WebGUI::Session.

=head3 id

A guid, the unique identifier for this object.

=cut

sub new {
	my ($class, $session, $id) = @_;
	my $tableKey = $class->crud_getTableKey($session);
	
	# validate
	unless (defined $session && $session->isa('WebGUI::Session')) {
        WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::Session', got=>(ref $session), error=>'Need a session.');
    }
    unless (defined $id && $id =~ m/^[A-Za-z0-9_-]{22}$/) {
        WebGUI::Error::InvalidParam->throw(error=>'need a '.$tableKey);
    }
	
	# retrieve object data
	my $data = $session->db->getRow($class->crud_getTableName($session), $tableKey, $id);
	if ($data->{$tableKey} eq '') {
        WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$tableKey, id=>$id);
    }
	
	# deserialize data
	my $properties = $class->crud_getProperties($session);
	foreach my $name (keys %{$properties}) {
		if ($properties->{$name}{serialize}) {
			$data->{$name} = JSON->new->canonical->decode($data->{$name});
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

=head2 promote ()

Moves this object one position closer to the beginning of its sequence. If the object is already at the top of the sequence then no change will be made. Returns 1 on success.

=cut

sub promote {
	my $self = shift;
	my $tableKey = $self->crud_getTableKey($self->session);
	my $tableName = $self->crud_getTableName($self->session);
	my $sequenceKey = $self->crud_getSequenceKey($self->session);
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
    my ($id) = $db->quickArray("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)." where $clause sequenceNumber=?", \@params);
    if ($id ne "") {
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber-1 where ".$dbh->quote_identifier($tableKey)."=?", [$self->getId]);
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber+1 where ".$dbh->quote_identifier($tableKey)."=?", [$id]);
		$objectData{id $self}{sequenceNumber}--;
    }
	$db->commit;
	return 1;
}

#-------------------------------------------------------------------

=head2 reorder ()

Removes gaps in the sequence. Usually only called by delete(), but may be useful if you randomize a sequence.

=cut

sub reorder {
	my ($self) = @_;
	my $tableKey = $self->crud_getTableKey($self->session);
	my $tableName = $self->crud_getTableName($self->session);
	my $sequenceKey = $self->crud_getSequenceKey($self->session);
	my $sequenceKeyValue = $self->get($sequenceKey);	
	my $i = 1;
	my $db = $self->session->db;
	my $dbh = $db->dbh;
	
	# find all the items in this sequence
	my @params = ();
	if ($sequenceKey) {
		push @params, $sequenceKeyValue;
	}
	my $clause = ($sequenceKey) ? "where ".$dbh->quote_identifier($sequenceKey)."=?" : '';
	my $current = $db->read("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)."
			$clause order by sequenceNumber", \@params);
	
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
		my @params = ($i, $id);
		if ($sequenceKey) {
			push @params, $sequenceKeyValue;
		}
		$change->execute(\@params);
        $i++;
    }
	$db->commit;
	return 1;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Updates an object's properties. While doing so also validates default data and sets the lastUpdated date.

=head3 properties

A hash reference of properties to be set. See crud_definition() for a list of the properties available.

=cut

sub update {
	my ($self, $data) = @_;
	
	# validate incoming data
	my $properties = $self->crud_getProperties($self->session);
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
			$data->{property} = JSON->new->canonical->encode($data->{property});
		}
	}
	
	# set last updated
	$data->{lastUpdated} ||= WebGUI::DateTime->new($self->session, time())->toDatabase;
	
	# update memory
	my $refId = id $self;
	%{$objectData{$refId}} = (%{$objectData{$refId}}, %{$data});
	
	# update the database
	$self->session->db->setRow($self->crud_getTableName($self->session), $self->crud_getTableKey($self->session), $objectData{$refId});
	return 1;
}


1;
