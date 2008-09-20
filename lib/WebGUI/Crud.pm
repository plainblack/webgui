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

=head2 crud_createTable ( session )

A management class method used to create the database table using the crud_definition(). Returns 1 on successful completion. 

=head3 session

A reference to a WebGUI::Session.

=cut

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
	$db->write('alter table '.dbh->quote_identifier($class->crud_getTableName).'
		add index '.$dbh->quote_identifier($class->crud_getTableKey).' ('.$dbh->quote_identifier($class->crud_getTableKey).')');
	return 1;
}

#-------------------------------------------------------------------

=head2 crud_definition ()

A management class method that returns the properties necessary to construct this object. This should be extended by all subclasses.

B<NOTE:> When you subclass WebGUI::Crud, note the properties you're defining in the POD of this method. That way it's in a consistent place for all subclasses. There are no settable properties by default, but all WebGUI::Crud objects have an id (who's name is set with tableKey), dateCreated, lastUpdated, and sequenceNumber.

Returns a hash reference that looks like this:

 {
	tableName	=> 'unamed_crud_table',
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

=head2 crud_dropTable ( session )

A management class method that will drop the table created by crud_createTable(). Returns 1 on success.

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_dropTable {
	my ($class, $session) = @_;
	my $db = $session->db;
	my $dbh = $db->dbh;
	$db->write("drop table ".$dbh->quote_identifier($class->crud_getTableName)."");
	return 1;
}

#-------------------------------------------------------------------

=head2 crud_getProperties ()

A management class method that returns just the 'properties' from crud_definition().

=cut

sub crud_getProperties {
	my $class = shift;
	return $class->crud_definition->{properties};
}

#-------------------------------------------------------------------

=head2 crud_getSequenceKey ()

A management class method that returns just the 'sequenceKey' from crud_definition().

=cut

sub crud_getSequenceKey {
	my $class = shift;
	my $definition = $class->crud_definition;
	return $definition->{sequenceKey};
}

#-------------------------------------------------------------------

=head2 crud_getTableName ()

A management class method that returns just the 'tableName' from crud_definition().

=cut

sub crud_getTableName {
	my $class = shift;
	return $class->crud_definition->{tableName};
}

#-------------------------------------------------------------------

=head2 crud_getTableKey ()

A management class method that returns just the 'tableKey' from crud_definition().

=cut

sub crud_getTableKey {
	my $class = shift;
	return $class->crud_definition->{tableKey};
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

=head2 delete ()

Deletes this object from the database. Returns 1 on success.

=cut

sub delete {
	my $self = shift;
	$self->session->db->deleteRow($self->crud_getTableName, $self->crud_getTableKey, $self->getId);
	$self->reorder;
	return 1;
}

#-------------------------------------------------------------------

=head2 demote ()

Moves this object one position closer to the end of its sequence. If the object is already at the bottom of the sequence then no change will be made. Returns 1 on success.

=cut

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

=head2 get ( [ property ] )

Returns a hash reference of all the properties of this object.

=head3 property

If specified, returns the value of the property associated with this this property name. Returns undef if the property doesn't exist. See crud_definition() in the subclass of this class for a complete list of properties.

=cut

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
        my ($id) = $ids->array;
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
	my $sql = "select ".$dbh->quote_identifier($class->crud_getTableKey)." from ".$dbh->quote_identifier($class->crud_getTableName);

	# limit to our sequence
	my $sequenceKey = $class->crud_getSequenceKey;
	unless ($options->{sequenceKeyValue} && $sequenceKey) {
		$sql .= $dbh->quote_identifier($sequenceKey)."=?";
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
	return $self->objectData->{$self->crud_getTableKey};
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
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber-1 where ".$dbh->quote_identifier($tableKey)."=?");
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber+1 where ".$dbh->quote_identifier($tableKey)."=?");
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

=head2 update ( properties )

Updates an object's properties. While doing so also validates default data and sets the lastUpdated date.

=head3 properties

A hash reference of properties to be set. See crud_definition() for a list of the properties available.

=cut

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
			$data->{property} = JSON->new->canonical->encode($data->{property});
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
