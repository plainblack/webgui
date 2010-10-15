package WebGUI::Definition::Crud;

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

use 5.010;
use feature ();

use Moose::Exporter;
use WebGUI::Definition ();
use WebGUI::Definition::Meta::Crud;
use Moose::Util;
use Moose::Util::MetaRole;
use JSON;
use Tie::IxHash;
use Clone qw/clone/;
use WebGUI::DateTime;
use WebGUI::Exception;

use namespace::autoclean;

no warnings qw(uninitialized);

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Crud

=head1 DESCRIPTION

Moose-based meta class for all Shop definitions in WebGUI.  Shop plugins have a name, pluginName, and
the table where their data is stored as JSON blobs, tableName.

=head1 SYNOPSIS

A definition contains all the information needed to build an object.
Information required to build forms are added as optional roles and
sub metaclasses.  Database persistance is handled similarly.

=head1 METHODS

These methods are available from this class:

=cut

my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
    install          => [ 'unimport' ],
    also             => 'WebGUI::Definition',
);

#-------------------------------------------------------------------

=head2 import ( )

A custom import method is provided so that uninitialized properties do not
generate warnings.

=cut

sub import {
    my $class = shift;
    my $caller = caller;
    $class->$import({ into_level => 1 });
    warnings->unimport('uninitialized');
    feature->import(':5.10');
    namespace::autoclean->import( -cleanee => $caller );
    return 1;
}

#-------------------------------------------------------------------

=head2 init_meta ( )

A custom init_meta, so that if inported into a class, it applies the roles
to the class, and applies the meta-role to the meta-class.

But, if it is applied to a Role, then only the meta-role is applied, since we want
the final application to be in the end user of the Role.

This permits using this to compose Roles with their own database tables.

=cut

sub init_meta {
    my $class = shift;
    my %args = @_;
    my $for_class = $args{for_class};
    if ($for_class->meta->isa('Moose::Meta::Class')) {
        Moose::Util::MetaRole::apply_metaroles(
            for             => $for_class,
            class_metaroles => {
                class           => ['WebGUI::Definition::Meta::Crud'],
            },
        );
        Moose::Util::apply_all_roles(
            $for_class,
            'WebGUI::Definition::Role::Object',
        );
    }
    else {
        Moose::Util::MetaRole::apply_metaroles(
            for             => $for_class,
            role_metaroles  => {
                role            => ['WebGUI::Definition::Meta::Crud'],
            },
        );
    }
    return $for_class->meta;
}

#-------------------------------------------------------------------

=head2 create ( session, [ properties ], [ options ])

Constructor. Creates a new instance of this object. Returns a reference to the object.

=head3 session

A reference to a WebGUI::Session or an object that has a session method. If it's an object that has a session method, then this object will be passed to new() instead of session as well. This is useful when you are creating WebGUI::Crud subclasses that require another object to function.

=head3 properties

The properties that you wish to create this object with. Note that if this object has a sequenceKey then that sequence key must be specified in these properties or it will throw an execption. See crud_definition() for a list of all the properties.

=head3 options

A hash reference of creation options.

=head4 id

A guid. Use this to force the row's table key to a specific ID.

=cut

sub create {
    my ($class, $someObject, $data, $options) = @_;

    # dynamic recognition of object or session
    my $session = $someObject;
    unless ($session->isa('WebGUI::Session')) {
        $session = $someObject->session;
    }

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
        # set a default value if it's empty or undef (as per L<update>)
        if ($data->{$property} eq "") {
            $data->{$property} = $properties->{$property}{defaultValue};
        }
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
    my $id = $db->setRow($tableName, $tableKey, {$tableKey=>'new', dateCreated=>$now, sequenceNumber=>$sequenceNumber}, $options->{id});
    my $self = $class->new($someObject, $id);
    $self->update($data);
    return $self;
}

#-------------------------------------------------------------------

=head2 crud_createOrUpdateTable ( session )

A detection class method used to affirm creation or update of the database table using the crud_definition(). Returns 1 on successful completion.

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_createOrUpdateTable {
    my ( $class, $session ) = @_;
    my $tableName   = $class->crud_getTableName($session);
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
    my $tableName = $class->crud_getTableName($session);
    $class->crud_dropTable($session);
    $db->write('create table '.$dbh->quote_identifier($tableName).' (
        '.$dbh->quote_identifier($class->crud_getTableKey($session)).' CHAR(22) binary not null primary key,
        sequenceNumber int not null default 1,
        dateCreated datetime,
        lastUpdated datetime
        )');
    $class->crud_updateTable($session);
    my $sequenceKey = $class->crud_getSequenceKey($session);
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
    tableName    => 'unnamed_crud_table',
    tableKey    => 'id',
    sequenceKey => '',
    properties  => {},
 }

tableName is the name of the database table that will be used or created by this object.

tableKey is the name of the column in the database table that will act as the primary key.

sequenceKey is the name of any field in the table that will be used as a grouping mechanism to allow multiple sequences per table. For example, you might use an assetId so that all items attached to an asset can be ordered independent of other assets.

properties is a hash reference tied to IxHash so that it maintains its order. It's used to define properties of this objects and columns in the table. It should look like this:

 {
    companyName    => {
        fieldType        => 'text',
        defaultValue    => 'Acme Widgets',
        label            => 'Company Name',
        serialize        => 0,
    },
    companyWebSite    => {
        fieldType        => 'url',
        defaultValue    => undef,
        serialize        => 0,
    },
    presidentUserId    => {
        fieldType        => 'guid',
        defaultValue    => undef,
        isQueryKey        => 1,
    }
 }

The properties of each field can be any property associated with a WebGUI::Form::Control. There are two special properties as well. They are fieldType and serialize.

fieldType is the WebGUI::Form::Control type that you wish to associate with this field. It is required for all fields. Examples are 'HTMLarea', 'text', 'url', 'email', and 'selectBox'.

serialize tells WebGUI::Crud to automatically serialize this field in a JSON wrapper before storing it to the database, and to convert it back to it's native structure upon retrieving it from the database. This is useful if you wish to persist hash references or array references.

isQueryKey tells WebGUI::Crud that the field should be marked as 'non null' in the table and then adds an index of the same name to the table to make searching on the field faster. B<WARNING:> Don't use this if the field is already a sequenceKey. If it's a sequence key then it will automatically be indexed.

=cut

sub crud_definition {
    my ($class, $session) = @_;
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
	$db->write("drop table if exists ".$dbh->quote_identifier($class->crud_getTableName($session)));
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
	my ($class) = @_;
    return $class->meta->sequenceKey;
}

#-------------------------------------------------------------------

=head2 crud_getTableName ( session )

A management class method that returns just the 'tableName' from crud_definition().

=head3 session

A reference to a WebGUI::Session.

=cut

sub crud_getTableName {
	my ($class) = @_;
    return $class->meta->tableName;
}

#-------------------------------------------------------------------

=head2 crud_getTableKey ( session )

A management class method that returns just the 'tableKey' from crud_definition().

=head3 session

A reference to a WebGUI::Session.

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
	my $tableName = $dbh->quote_identifier($class->crud_getTableName($session));

	# find out what fields already exist
	my %tableFields = ();
	my $sth = $db->read("DESCRIBE ".$tableName);
	my $tableKey = $class->crud_getTableKey($session);
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
	my $properties = $class->crud_getProperties($session);
	foreach my $property (keys %{$properties}) {
		my $control = WebGUI::Form::DynamicField->new( $session, %{ $properties->{ $property } });
		my $fieldType = $control->getDatabaseFieldType;
		my $isKey = $properties->{$property}{isQueryKey};
		my $defaultValue =  $properties->{$property}{defaultValue};
        if ($properties->{$property}{serialize}) {
            $defaultValue = JSON->new->canonical->encode($defaultValue);
        }
		my $notNullClause = ($isKey || $defaultValue ne "") ? "not null" : "";
		my $defaultClause = '';
        if ($fieldType !~ /(?:text|blob)$/i) {
            $defaultClause = "default ".$dbh->quote($defaultValue) if ($defaultValue ne "");
        }
		if (exists $tableFields{$property}) {
			my $changed = 0;
			
			# parse database table field type
			$tableFields{$property}{type} =~ m/^(\w+)(\([\d\s,]+\))?$/;
			my ($tableFieldType, $tableFieldLength) = ($1, $2);
			
			# parse form field type
			$fieldType =~ m/^(\w+)(\([\d\s,]+\))?\s*(binary)?$/;
			my ($formFieldType, $formFieldLength) = ($1, $2);
			
			# compare table parts to definition
			$changed = 1 if ($tableFieldType ne $formFieldType);
			$changed = 1 if ($tableFieldLength ne $formFieldLength);
			$changed = 1 if ($tableFields{$property}{null} eq "YES" && $isKey);
			$changed = 1 if ($tableFields{$property}{default} ne $defaultValue);

			# modify if necessary
			if ($changed) {
				$db->write("alter table $tableName change column ".$dbh->quote_identifier($property)." ".$dbh->quote_identifier($property)." $fieldType $notNullClause $defaultClause");
			}
		}
		else {
			$db->write("alter table $tableName add column ".$dbh->quote_identifier($property)." $fieldType $notNullClause $defaultClause");
		}
		if ($isKey && !$tableFields{$property}{key}) {
			$db->write("alter table $tableName add index ".$dbh->quote_identifier($property)." (".$dbh->quote_identifier($property).")");
		}
		delete $tableFields{$property};
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
		#$objectData{id $self}{sequenceNumber}++;
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
            WebGUI::Error::ObjectNotFound->throw(error=>'no such '.$class->getTableKey, id => $id);
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
	my $tableName = $class->crud_getTableName($session);

	# the base query
	my $sql = "select ".$dbh->quote_identifier($tableName, $class->crud_getTableKey($session))." from ".$dbh->quote_identifier($tableName);

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
	my $sequenceKey = $class->crud_getSequenceKey($session);
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
		if ($properties->{$name}{serialize} && $data->{$name} ne "") {
			$data->{$name} = JSON->new->canonical->decode($data->{$name});
		}
	}

	# set up object
	my $self = register($class);
	my $refId = id $self;
	#$objectData{$refId} = $data;
	#$session{$refId} = $session;
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
		#$objectData{id $self}{sequenceNumber}--;
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
			#$objectData{id $self} = $i;
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

B<WARNING:> As part of it's validation mechanisms, update() will delete any elements from the properties list that are not specified in the crud_definition().

=cut

#sub update {
#	my ($self, $data) = @_;
#    my $session = $self->session;
#
#	# validate incoming data
#	my $properties = $self->crud_getProperties($session);
#    my $dbData = { $self->crud_getTableKey($session) => $self->getId };
#	foreach my $property (keys %{$data}) {
#
#		# don't save fields that aren't part of our definition
#		unless (exists $properties->{$property} || $property eq 'lastUpdated') {
#			delete $data->{$property};
#			next;
#		}
#
#		# set a default value if it's empty or undef
#        if ($data->{$property} eq "") {
#            $data->{$property} = $properties->{$property}{defaultValue};
#        }
#
#		# serialize if needed
#		if ($properties->{$property}{serialize} && $data->{$property} ne "") {
#			$dbData->{$property} = JSON->new->canonical->encode($data->{$property});
#		}
#        else {
#            $dbData->{$property} = $data->{$property};
#        }
#	}
#
#	# set last updated
#	$data->{lastUpdated} ||= WebGUI::DateTime->new($session, time())->toDatabase;
#
#	# update memory
#	my $refId = id $self;
#	%{$objectData{$refId}} = (%{$objectData{$refId}}, %{$data});
#
#	# update the database
#	$session->db->setRow($self->crud_getTableName($session), $self->crud_getTableKey($session), $dbData);
#	return 1;
#}

#-------------------------------------------------------------------

=head2 updateFromFormPost ( )

Calls update() on any properties that are available from $session->form. Returns 1 on success.

=cut

sub updateFromFormPost {
	my $self = shift;
	my $session = $self->session;
	my $form = $session->form;
	my %data;
	my $properties = $self->crud_getProperties($session);
	foreach my $property ($form->param) {
		$data{$property} = $form->get($property, $properties->{$property}{fieldType}, $properties->{$property}{defaultValue});
	}
	return $self->update(\%data);
}




1;
