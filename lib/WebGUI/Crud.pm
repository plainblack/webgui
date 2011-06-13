package WebGUI::Crud;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Moose;
use WebGUI::Definition::Crud;
use JSON;
use Tie::IxHash;
use Clone qw/clone/;
use WebGUI::DateTime;
use WebGUI::Exception;
use WebGUI::FormBuilder;
use Scalar::Util qw( blessed );

has session => (
    is       => 'ro',
    required => 1,
);

has lastUpdated => (
    is       => 'rw',
    lazy     => 1,
    builder  => '_now',
);

has dateCreated => (
    is       => 'rw',
    lazy     => 1,
    builder  => '_now',
);

has sequenceNumber => (
    is       => 'rw',
    default  => 1,
);

has _dirty => (
    is       => 'rw',
    default  => 0,
);

# True if the object was created by this instance
has _new => (
    is      => 'ro',
    default => 0,
);

sub _now {
    my $self = shift;
    return WebGUI::DateTime->new($self->session)->toDatabase;
}

has sequenceNumber => (
    is       => 'rw',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if(ref $_[0] eq 'HASH') {
        ##Standard Moose invocation for creating a new object
        return $class->$orig(@_);
    }

    # dynamic recognition of object or session
    my $session = shift;
    unless ($session->isa('WebGUI::Session')) {
        $session = $session->session;
    }

    my $identifier = shift;
    if(!defined($identifier) || ref $identifier eq 'HASH') {
        ##Creating a new object
        my $data      = $identifier;
        my $tableKey  = $class->meta->tableKey();
        my $tableName = $class->meta->tableName();
        my $db        = $session->db;

        # determine sequence
        my $sequenceKey = $class->meta->sequenceKey();
        my $clause;
        my @params;
        if ($sequenceKey) {
            $clause = "where ".$db->quote_identifier($sequenceKey)."=?";
            push @params, $data->{$sequenceKey};
        }
        my $sequenceNumber = $db->quickScalar("select max(sequenceNumber) from ".$db->quote_identifier($tableName)." $clause", \@params);
        $sequenceNumber++;

        my $now = WebGUI::DateTime->new($session, time())->toDatabase;
        $data->{dateCreated}    = $now;
        $data->{lastUpdated}    = $now;
        $data->{session}        = $session;
        $data->{sequenceNumber} = $sequenceNumber;
        $data->{$tableKey}      = $data->{id} || $session->id->generate;
        $data->{_dirty}         = 1;
        $data->{_new}           = 1;

        return $class->$orig($data);
    }
    ##Grabbing an object from the database
	my $tableKey = $class->meta->tableKey;
    unless ($session->id->valid($identifier)) {
        WebGUI::Error::InvalidParam->throw(error=>'need a '.$tableKey);
    }

	# retrieve object data
	my $data = $session->db->getRow($class->meta->tableName(), $tableKey, $identifier);
	if ($data->{$tableKey} eq '') {
        WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$tableKey, id=>$identifier);
    }
    $data->{session} = $session;
    return $class->$orig($data);
};

sub BUILD {
    my $self = shift;
    if ($self->_dirty) {
        $self->write;
    }
}

=head1 NAME

Package WebGUI::Crud

=head1 DESCRIPTION

CRUD = Create, Read, Update, and Delete. This package should be the base class for almost all database backed objects. It provides all the basics you will need when creating such objects.

This package is very light weight compared to it's cousins (like DBIx::Class), and is very specific to WebGUI. That's because we aren't afraid of SQL, and don't want to automate everything. If you need something more powerful then consider DBIx::Class.

=head1 SYNOPSIS

WebGUI::Crud can be used in one of two ways. You can create a subclass with a defined definition. Or you can create a subclass that dynamically generates it's definition.

=head2 Static Subclass

The normal way to use WebGUI::Crud is to create a subclass that defines a specific definition. In your subclass you'd make your own like this:

 use Moose;
 use WebGUI::Definition::Crud;
 extends 'WebGUI::Crud';
 define tableName => 'ambassador';
 define tableKey  => 'ambassadorId';
 has ambassadorId => (
    fieldType => 'text',
    default =>undef,
 );
 property name => (
    fieldType => 'text',
    default   => undef,
 );
 property emailAddress => (
    fieldType => 'email',
    default   =>undef,
 );

=head2 Dynamic Subclass

A more advanced approach is to create a subclass that dynamically generates a definition from a database table or a config file.

 use Moose;
 use WebGUI::Definition::Crud;
 extends 'WebGUI::Crud';
 my $config = Config::JSON->new('/path/to/file.cfg');
 define tableName => $config->get('tableName');
 define tableKey  => $config->get('tableKey');
 has $config->get('tableKey') => (
    fieldType => 'text',
    default =>undef,
 );
 my $fields = $config->get('fields');
 foreach my $fieldName (keys %{$fields}) {
    property $fieldName => (
        @{ $fields->{$fieldName} },
    );
 }

=head2 Usage

Once you have a crud class, you can use it's methods like this:

 use WebGUI::Crud::Subclass;

 $sequenceKey = WebGUI::Crud::Subclass->meta->sequenceKey();
 $tableKey = WebGUI::Crud::Subclass->meta->tableKey();
 $tableName = WebGUI::Crud::Subclass->meta->tableName();
 $propertiesHashRef = WebGUI::Crud::Subclass->meta->get_all_property_list();

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

=head2 new ( session, id )

Constructor.  Looks up an object in the database.

=head3 session

A reference to a WebGUI::Session.

=head3 id

A guid, the unique identifier for this object.  Looks in the database for this object's properties.  If the object
cannot be found, throws an WebGUI::Error::ObjectNotFound exception.  If the id isn't a valid GUID, then it will
throw an WebGUI::Error::InvalidParam exception.

=head2 new ( session, [ properties ])

Constructor. Creates a new instance of this object. Returns a reference to the object, but does not serialize inital properties
to the database.  You must call $object->write to do this.

=head3 session

A reference to a WebGUI::Session or an object that has a session method. If it's an object that has a session method, then this object will be passed to new() instead of session as well. This is useful when you are creating WebGUI::Crud subclasses that require another object to function.

=head3 properties

The properties that you wish to create this object with. Note that if this object has a sequenceKey then that sequence key must be specified in these properties or it will throw an execption.

=cut

#-------------------------------------------------------------------

=head2 crud_createOrUpdateTable ( session )

A detection class method used to affirm creation or update of the database table using the crud_definition(). Returns 1 on successful completion.

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_createOrUpdateTable {
    my ( $class, $session ) = @_;
    my $tableName   = $class->meta->tableName();
    my $tableExists = $session->db->dbh->do("show tables like '$tableName'");

    return ( $tableExists ne '0E0' ? $class->crud_updateTable($session) : $class->crud_createTable($session) );
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
	my $tableName = $class->meta->tableName();
	$class->crud_dropTable($session);
	$db->write('create table '.$dbh->quote_identifier($tableName).' (
		'.$dbh->quote_identifier($class->meta->tableKey()).' CHAR(22) binary not null primary key,
		sequenceNumber int not null default 1,
		dateCreated datetime,
		lastUpdated datetime
		)');
	$class->crud_updateTable($session);
	my $sequenceKey = $class->meta->sequenceKey();
	if ($sequenceKey) {
		$db->write('alter table '.$dbh->quote_identifier($tableName).'
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
		default	=> 'Acme Widgets',
		label			=> 'Company Name',
		serialize		=> 0,
	},
	companyWebSite	=> {
		fieldType		=> 'url',
		default	=> undef,
		serialize		=> 0,
	},
	presidentUserId	=> {
		fieldType		=> 'guid',
		default	=> undef,
		isQueryKey		=> 1,
	}
 }

The properties of each field can be any property associated with a WebGUI::Form::Control. There are two special properties as well. They are fieldType and serialize.

fieldType is the WebGUI::Form::Control type that you wish to associate with this field. It is required for all fields. Examples are 'HTMLarea', 'text', 'url', 'email', and 'selectBox'.

serialize tells WebGUI::Crud to automatically serialize this field in a JSON wrapper before storing it to the database, and to convert it back to it's native structure upon retrieving it from the database. This is useful if you wish to persist hash references or array references.

isQueryKey tells WebGUI::Crud that the field should be marked as 'non null' in the table and then adds an index of the same name to the table to make searching on the field faster. B<WARNING:> Don't use this if the field is already a sequenceKey. If it's a sequence key then it will automatically be indexed.

=cut

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
	$db->write("drop table if exists ".$dbh->quote_identifier($class->meta->tableName()));
	return 1;
}

#-------------------------------------------------------------------

=head2 crud_form ( $form, [$object] )

A class method to populate a WebGUI::FormBuilder object with all the fields for this Cruddy object.

=head3 $form

A WebGUI::FormBuilder object, or any object that does
FormBuilder::Role::HasFields

=head3 $object

An object of this class, used to provide values to the form.  It's optional.

=cut

sub crud_form {
	my ($class, $form, $object) = @_;
    my $properties = $class->crud_getProperties( $form->session );
    for my $propName ( keys %$properties ) {
        my $prop = $properties->{ $propName };
        $form->addField( delete $prop->{fieldType},
            %$prop,
            value => $object ? $object->get( $propName ) : undef,
        );
    }
}

#-------------------------------------------------------------------

=head2 crud_getProperties ( )

A management class method that returns just the 'properties' from the Crud'd definition.
These properties have limited use, as you really need a full object to get access to a
session.

=cut

sub crud_getProperties {
	my ($class, $session) = @_;
        # We must really have a class here
        if ( blessed $class ) {
            $class = blessed $class;
        }

	my @property_names = $class->meta->get_all_property_list();
    my $properties = {};
	foreach my $property_name (@property_names) {
        my $property        = $class->meta->find_attribute_by_name($property_name);
        next unless $property;
        $properties->{$property_name} = {
                                %{ $class->getFormProperties( $session, $property_name ) },
                                name        => $property_name,
                                fieldType => $property->form->{fieldType},
                            };
    }
    return $properties;
}

#-------------------------------------------------------------------

=head2 crud_getSequenceKey

A management class method that returns just the 'sequenceKey' from the meta class.  This is left for
backwards compatility.  You should call

WebGUI::Crud::Subclass->meta->sequenceKey

instead.

=cut

sub crud_getSequenceKey {
	my ($class) = @_;
    return $class->meta->sequenceKey;
}

#-------------------------------------------------------------------

=head2 crud_getTableName

A management class method that returns just the 'tableName'.  This is left for
backwards compatility.  You should call

WebGUI::Crud::Subclass->meta->tableName

instead.

=cut

sub crud_getTableName {
	my ($class) = @_;
    return $class->meta->tableName;
}

#-------------------------------------------------------------------

=head2 crud_getTableKey

A management class method that returns just the 'tableKey'.  This is left for
backwards compatility.  You should call

WebGUI::Crud::Subclass->meta->tableKey

instead.


=cut

sub crud_getTableKey {
	my ($class) = @_;
    return $class->meta->tableKey;
}

#-------------------------------------------------------------------

=head2 crud_updateTable ( session )

A management class method that tries to resolve the differences between the database table and the definition. Returns 1 on success.

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
	my $tableName = $dbh->quote_identifier($class->meta->tableName());

	# find out what fields already exist
	my %tableFields = ();
	my $sth = $db->read("DESCRIBE ".$tableName);
	my $tableKey = $class->meta->tableKey();
	while (my ($col, $type, $null, $key, $default) = $sth->array) {
		next if ($col ~~ [$tableKey, 'lastUpdated', 'dateCreated','sequenceNumber']);
		$tableFields{$col} = {
			type	=> $type,
			null	=> $null,
			key		=> $key,
			default	=> $default,
			};
	}

	# update existing and create new fields
	my @property_names = $class->meta->get_all_property_list($session);
	foreach my $property_name (@property_names) {
        my $property        = $class->meta->find_attribute_by_name($property_name);
        my $form_properties = $property->form;
		my $control         = WebGUI::Form::DynamicField->new( $session, fieldType => $form_properties->{fieldType},);
		my $fieldType       = $control->getDatabaseFieldType;
		my $isKey           = $property->isQueryKey;
        my $default         = $property->default;
		my $notNullClause   = ($isKey || $default ne "") ? "not null" : "";
		if (exists $tableFields{$property_name}) {
			my $changed = 0;
			
			# parse database table field type
			$tableFields{$property_name}{type} =~ m/^(\w+)(\([\d\s,]+\))?$/;
			my ($tableFieldType, $tableFieldLength) = ($1, $2);
			
			# parse form field type
			$fieldType =~ m/^(\w+)(\([\d\s,]+\))?\s*(binary)?$/;
			my ($formFieldType, $formFieldLength) = ($1, $2);
			
			# compare table parts to definition
			$changed = 1 if ($tableFieldType ne $formFieldType);
			$changed = 1 if ($tableFieldLength ne $formFieldLength);
			$changed = 1 if ($tableFields{$property_name}{null} eq "YES" && $isKey);
			$changed = 1 if ($tableFields{$property_name}{default} ne $default);

			# modify if necessary
			if ($changed) {
				$db->write("alter table $tableName change column ".$dbh->quote_identifier($property_name)." ".$dbh->quote_identifier($property_name)." $fieldType $notNullClause");
			}
		}
		else {
			$db->write("alter table $tableName add column ".$dbh->quote_identifier($property_name)." $fieldType $notNullClause");
		}
		if ($isKey && !$tableFields{$property}{key}) {
			$db->write("alter table $tableName add index ".$dbh->quote_identifier($property_name)." (".$dbh->quote_identifier($property_name).")");
		}
		delete $tableFields{$property_name};
	}

	# delete fields that are no longer in the definition
	foreach my $property (keys %tableFields) {
		if ($tableFields{$property}{key}) {
			$db->write("alter table $tableName drop index ".$dbh->quote_identifier($property));	
		}
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
	$self->session->db->deleteRow($self->meta->tableName(), $self->meta->tableKey(), $self->getId);
	$self->reorder;
	return 1;
}

#-------------------------------------------------------------------

=head2 demote ()

Moves this object one position closer to the end of its sequence. If the object is already at the bottom of the sequence then no change will be made. Returns 1 on success.

=cut

sub demote {
	my $self = shift;
	my $tableKey = $self->meta->tableKey();
	my $tableName = $self->meta->tableName();
	my $sequenceKey = $self->meta->sequenceKey();
	my @params = ($self->sequenceNumber + 1);
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
    $self->sequenceNumber($self->sequenceNumber+1);
    }
	$db->commit;
	return 1;
}

#-------------------------------------------------------------------

=head2 getAllIds ( )

A class method that returns a list of all the ids in this object type. Has the same signature of getAllSql().

=cut

sub getAllIds {
	my ($class, $someObject, $options) = @_;

	# dynamic recognition of object or session
	my $session = $someObject;
	unless ($session->isa('WebGUI::Session')) {
		$session = $someObject->session;
	}

	# generate the array
	my @objects;
	my $ids = $session->db->read($class->getAllSql($session, $options, @_));
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
	my ($class, $someObject, $options) = @_;

	# dynamic recognition of object or session
	my $session = $someObject;
	unless ($session->isa('WebGUI::Session')) {
		$session = $someObject->session;
	}

	my @objects;
	my $ids = $class->getAllIds($session, $options, @_);
    my $sub = sub {
        my ($id) = shift @{$ids};
        return if !$id;
        my $object = $class->new($someObject, $id);
        if (!$object) {
            WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$class->meta->tableKey, id => $id);
        }
        return $object;
    };
    return $sub;
}

#-------------------------------------------------------------------

=head2 getAllSql ( session, [ options ] )

A class method that returns two values. The first is the SQL necessary to retrieve all of the records for this object. The second is an array reference with the placeholder parameters needed to execute the SQL.

=head3 session

A reference to a WebGUI::Session or an object that has a session method. If it's an object that has a session method, then this object will be passed to new() instead of session as well. This is useful when you are creating WebGUI::Crud subclasses that require another object to function.

=head3 options

A hash reference of optional rules to modify the returned results.

=head4 constraints

An array reference of hash references. Each hash reference should contain a where clause as the key complete with place holders (?) and a scalar or an array reference as it's value or values. Each where clause should be written using ANSI SQL. Each where clause will be anded together with any other where clauses that are generated by this API, and the "where" statement will be prepended to that.

Here's an example of this structure:

 [
	{ "price <= ?" 			=> 44 },
	{ "color=? or color=?" 	=> ['blue','black'] },
 ]

would yield

 ( price <= 44 ) AND ( color = 'blue' OR color = 'black' )

=head4 join

An array reference containing the tables you wish to join with this one, and the mechanisms to join them. Here's an example.

 [
	"yetAnotherTable on yetAnotherTable.this = anotherTable.that",
 ]

=head4 joinUsing

An array reference of hash references containing the tables you wish to join with this one and the field to use to join.

 [
	{"someTable" => "thisId"},
 ]

=head4 limit

Either an integer representing the number of records to return, or an array reference of an integer of the starting record position and another integer representing the number of records to return.

=head4 orderBy

A scalar containing a field name to order by. Defaults to 'sequenceNumber'.

=head4 sequenceKeyValue

If specified will limit the query to a specific sequence identified by this sequence key value. Note the object must have a sequenceKey specified in the crud_definition for this to work.

=cut

sub getAllSql {
	my ($class, $someObject, $options) = @_;

	# dynamic recognition of object or session
	my $session = $someObject;
	unless ($session->isa('WebGUI::Session')) {
		$session = $someObject->session;
	}

	# setup
	my $dbh = $session->db->dbh;
	my $tableName = $class->meta->tableName();

	# the base query
	my $sql = "select ".$dbh->quote_identifier($tableName, $class->meta->tableKey())." from ".$dbh->quote_identifier($tableName);

	# process joins
	my @joins;
	if (exists $options->{joinUsing}) {
		foreach my $joint (@{$options->{joinUsing}}) {
			my ($table) = keys %{$joint};
			push @joins, " left join ".$dbh->quote_identifier($table)." using (".$dbh->quote_identifier($joint->{$table}).")";
		}		
	}
	if (exists $options->{join}) {
		foreach my $thejoin (@{$options->{join}}) {
			push @joins, " left join ".$thejoin;
		}		
	}
	$sql .= join(" ", @joins);

	# process constraints
	my @params;
	my @where;
	if (exists $options->{constraints}) {
		foreach my $constraint (@{$options->{constraints}}) {
			my ($clause) = keys %{$constraint};
			push @where, "(".$clause.")";
			my $value = $constraint->{$clause};
			if (ref $value eq 'ARRAY') {
				@params = (@params, @{$value});
			}
			else {
				push @params, $value;
			}
		}		
	}
	
	# limit to our sequence
	my $sequenceKey = $class->meta->sequenceKey();
	if (exists $options->{sequenceKeyValue} && $sequenceKey) {
		push @params, $options->{sequenceKeyValue};
		push @where, $dbh->quote_identifier($tableName, $sequenceKey)."=?";
	}

	# merge all clauses with the main query
	if (scalar(@where)) {
		$sql .= " where ".join(" AND ", @where);
	}

	# custom order by field
	my $order = " order by ".$dbh->quote_identifier($tableName, 'sequenceNumber');
	if (exists $options->{orderBy}) {
		$order = " order by ".$options->{orderBy};
	}
	$sql .= $order;
	
	# construct a record limit
	my $limit;
	if ( exists $options->{limit}) {
		if (ref $options->{limit} eq "ARRAY") {
			$limit = " limit ".$options->{limit}[0].",".$options->{limit}[1];
		}
		else {
			$limit = " limit ".$options->{limit};
		}
	}
	$sql .= $limit;

	return $sql, \@params;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns a guid, this object's unique identifier.

=cut

sub getId {
	my $self = shift;
    my $tableKey = $self->meta->tableKey;
    return $self->$tableKey;
}

#-------------------------------------------------------------------

=head2 promote ()

Moves this object one position closer to the beginning of its sequence. If the object is already at the top of the sequence then no change will be made. Returns 1 on success.

=cut

sub promote {
	my $self = shift;
	my $tableKey = $self->meta->tableKey();
	my $tableName = $self->meta->tableName();
	my $sequenceKey = $self->meta->sequenceKey();
	my $sequenceKeyValue = $sequenceKey ? $self->$sequenceKey : '';
	my @params = ($self->sequenceNumber-1);
	my $clause = '';
	my $db = $self->session->db;
	my $dbh = $db->dbh;

	# determine sequence type
	if ($sequenceKey) {
		$clause = $dbh->quote_identifier($sequenceKey)."=? and";
		unshift @params, $self->$sequenceKey;
	}

	# make database changes
	$db->beginTransaction;
    my ($id) = $db->quickArray("select ".$dbh->quote_identifier($tableKey)." from ".$dbh->quote_identifier($tableName)." where $clause sequenceNumber=?", \@params);
    if ($id ne "") {
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber-1 where ".$dbh->quote_identifier($tableKey)."=?", [$self->getId]);
        $db->write("update ".$dbh->quote_identifier($tableName)." set sequenceNumber=sequenceNumber+1 where ".$dbh->quote_identifier($tableKey)."=?", [$id]);
        $self->sequenceNumber($self->sequenceNumber-1);
    }
	$db->commit;
	return 1;
}

#-------------------------------------------------------------------

=head2 reorder ()

Removes gaps in the sequence. Usually only called by delete(), but may be useful if you randomize a sequence.
This method will not update the current object.

=cut

sub reorder {
	my ($self) = @_;
	my $tableKey         = $self->meta->tableKey;
	my $tableName        = $self->meta->tableName;
	my $sequenceKey      = $self->meta->sequenceKey;
	my $sequenceKeyValue = $sequenceKey ? $self->$sequenceKey : '';
	my $i   = 1;
	my $db  = $self->session->db;
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

Extend the base method to update the lastUpdated property.

=cut

around update => sub {
	my ($orig, $self, $data) = @_;
    delete $data->{lastUpdated};
    $self->lastUpdated($self->_now);
    $self->$orig($data);
};

#-------------------------------------------------------------------

=head2 updateFromFormPost ( )

Calls update() on any properties that are available from $session->form. Returns 1 on success.

=cut

sub updateFromFormPost {
	my $self = shift;
	my $session = $self->session;
	my $form = $session->form;
	my %data;
	my @properties = $self->meta->get_all_property_list($session);
	foreach my $property_name ( @properties ) {
        my $property        = $self->meta->find_attribute_by_name($property_name);
        next unless $property;
		$data{$property_name} = $form->get($property_name,
                    $property->form->{fieldType}, $property->default);
            $self->session->log->warn(" SETTING $property_name to $data{$property_name}");
	}
	return $self->update(\%data);
}

#-------------------------------------------------------------------

=head2 write ( )

Serializes the object's data to the database.  Automatically handles deserializing property values to javascript,
if necessary.

=cut


sub write {
    my $self    = shift;
    my $session = $self->session;
    my $data = {};
    PROPERTY: foreach my $property_name ($self->meta->get_all_property_list) {
        my $property  = $self->meta->find_attribute_by_name($property_name);
        my $value     = $self->$property_name;
        if ($property->does('WebGUI::Definition::Meta::Property::Serialize')) {
            $value    = eval { JSON::to_json($value); } || '';
        }
        $data->{$property_name} = $value;
    }
    my $tableKey = $self->meta->tableKey;
    $data->{$tableKey}      = $self->$tableKey;
    $data->{lastUpdated}    = $self->lastUpdated;
    $data->{dateCreated}    = $self->dateCreated;
    $data->{sequenceNumber} = $self->sequenceNumber;
    if (my $sequenceKey = $self->meta->sequenceKey) {
        $data->{$sequenceKey} = $self->$sequenceKey;
    }
    $session->db->setRow($self->tableName, $self->tableKey, $data);
    $self->_dirty(0);
}

1;
