package WebGUI::Persistent;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use warnings;
use WebGUI::SQL;
use WebGUI::Persistent::Query::Select;
use WebGUI::Persistent::Query::Delete;
use WebGUI::Persistent::Query::Update;
use WebGUI::Persistent::Query::Insert;
use WebGUI::ErrorHandler;

our %classData = ();

=head1 NAME

Package WebGUI::Persistent

=head1 DESCRIPTION

An abstract base class for objects stored in the database.

This class provides simple get() and set() methods that interact with the 
database.

=head1 SYNOPSIS

 package MyClass;

 use WebGUI::Persistent;
 our @ISA = qw(WebGUI::Persistent);

 sub classSettings { 
      {
           properties => {
                A => { key => 1 },
                B => { defaultValue => 5},
                C => { quote => 1 , defaultValue => "hello world"},
                D => { },
           },
           table => 'myTable'
      }
 }

 1;

 .
 .
 .
  
 use MyClass;

 # create a new instance
 my $obj = MyClass->new( -properties => {B => 3} );

 # commit it to the database
 $obj->set();

 # find out what id it has
 my $id = $obj->get('A');

This would leave a row in the table:

 +---+---+-------------+------+
 | A | B |      C      |  D   |
 +---+---+-------------+------+
 | 1 | 3 | hello world | NULL |
 +---+---+-------------+------+

Rows can be retrieved from the database individually:

 my $sameObj = MyClass->new(A => $id);

Or multiple rows can be fetched:

 my @objs = MyClass->multiNew(-where => ["A > 5"], B => 3);

Rows can also be deleted from the database individually or many at once.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

# Provides access to various stored classData.
sub classData {
     my ($self) = @_;
     my $class = ref($self) || $self;
     return $classData{$class} ||= {}; 
}

#-------------------------------------------------------------------

=head2 classSettings

This class method must be overridden to return a hash reference with one or
more of the following keys.

 sub classSettings { 
      {
           properties => {
                A => { key => 1 },
                B => { defaultValue => 5},
                C => { quote => 1 , defaultValue => "hello world"},
                D => { },
           },
           table => 'myTable'
      }
 }

=over

=item properties

This should be a hash reference keyed by the field names of the table that 
this class refers to (and should be able to be manipulated with this classes
get() and set() methods). The values of the hash reference should be hash
references containing settings for each field.

=over

=item * defaultValue 

The default value for this field (optional).

=item * key

Should be true for the primary key column (one field must be set in this way).

=item * quote

Should be true for fields that need to be quoted in database queries.

=back

=item table

This must be set to the name of the table that this class represents.

=back

=cut

sub classSettings {
     WebGUI::ErrorHandler::fatalError("classSettings() must be overridden");
}

#-------------------------------------------------------------------

=head2 delete

An instance method to delete the currently instantiated row.

=cut

sub delete {
     my ($self) = @_;
     my $delete = WebGUI::Persistent::Query::Delete->new(
          table => $self->table(),
          where => { $self->keyColumn() => $self->get($self->keyColumn()) }
     );
     WebGUI::SQL->write($delete->buildQuery());
}

#-------------------------------------------------------------------

=head2 get( $propertyName )

Returns the value of a field.

=cut

sub get {
     my ($self,$propertyName) = @_;
     if ($propertyName) {
          if (exists($self->{_property}{$propertyName})) {
               return $self->{_property}{$propertyName};
          } elsif ($self->properties->{$propertyName}) {
               WebGUI::ErrorHandler::warn(
                    ref($self)." $propertyName not retrieved from database"
               );
          }
     }
     return $self->{_property};
}

#-------------------------------------------------------------------

=head2 keyColumn

Returns the name of the column that is the primary key for this table. 

See classSettings() for details on how to set this value.

=cut

sub keyColumn {
     my ($class) = @_;
     unless ($class->classData->{keyColumn}) {
          my $properties = $class->properties();
          foreach my $key (keys %$properties) {
               next unless $properties->{$key}{key};
               $class->classData->{keyColumn} = $key;
          }
     }
     return $class->classData->{keyColumn};
}

#-------------------------------------------------------------------

sub _mergeWhere {
     my ($class,$where,$p) = @_;
     $where ||= [];
     if (%$p) {
          push @$where,$p if ref($where) eq 'ARRAY';
          $where = [$where,$p] if ref($where) eq 'HASH';
     }
     return $where;
}

#-------------------------------------------------------------------

=head2 minimumFields

Returns an array reference to the minimum subset of fields that maybe
selected from the database. This list defaults to the keyColum().

=cut

sub minimumFields {
     my ($class) = @_;
     unless ($class->classData->{minimumFields}) {
          $class->classData->{minimumFields} = [$class->keyColumn()]
     }
     return $class->classData->{minimumFields};
}

#-------------------------------------------------------------------

=head2 multiDelete( -where => @whereClauses, %p )

=over

=item -where

See multiNew().

=back

=cut

sub multiDelete {
     my $class = shift;
     my ($where,%p) = $class->_pluck([qw(-where)],@_);

     my $delete = WebGUI::Persistent::Query::Delete->new(
          table  => $class->table(),
          properties => $class->properties(),
          where => $class->_mergeWhere($where,\%p)
     );
     my $query = $delete->buildQuery();
     WebGUI::SQL->write($query);
}

#-------------------------------------------------------------------

=head2 multiNew( %p )

Returns a list of objects matching the query arguments.

Unrecognised parameters are combined to form the where clause:

 MyClass->multiNew(A => [1,2], B => 3);

Additional, more complicated parameters maybe passed using the -where option.

=over

=item -where

If provided -where must be an array reference, which is evaluated to generate
an Sql where clause using the properties in classSettings. Any left over named
parameters to this method are built into the where clause.

For a class with settings as defined in the sysnopsis above the following 
argument to -where would be evaluated as:

 -where => [{A => [1,2]},[{B => 3,C => 'hello'}],"D = (B * 3)"]

Evaluates to:

 A in (1,2) AND (B = 3 OR C = 'hello') AND D = (B * 3)

=item -fields

This maybe an array reference of fields to be selected from the database,
otherwise, all fields in properties are selected unless the -minimumFields
option is true.

=item -minimumFields

If true the minimum fields are selected from the database.

=back

=cut

sub multiNew {
     my $class = shift;
     my ($where,$fields,$minimumFields,%p) 
       = $class->_pluck([qw(-where -fields -minimumFields)],@_);
     $minimumFields = $class->minimumFields if $minimumFields;
     my (@objs);

     my $select = WebGUI::Persistent::Query::Select->new(
          table  => $class->table(),
          properties => $class->properties(),
          where  => $class->_mergeWhere($where,\%p),
          fields => $minimumFields ? $minimumFields : $fields
     );
     my $query = $select->buildQuery();
     my $sth = WebGUI::SQL->read($query);
     while (my $hash = $sth->hashRef()) {
          push @objs, $class->new(-properties => $hash);
     }

     return @objs;
}

#-------------------------------------------------------------------

=head2 new 

=over

=item -properties

If a hash reference of property names to values is provided to this method,
then the database is not queried. This is mainly used for creating new rows
by calling set afterwards (if not specified the value of the key column is
set to 'new', so that when set() is called, and insert takes place).

=item -where

See multiNew().

=item -fields

See multiNew().

=item -minimumFields

See multiNew().

=item -noSet

If true this stops the set() method from doing writing to the database.

=back

=cut

sub new {
     my $class = shift;
     my ($properties,$where,$fields,$minimumFields,$noSet,%p) 
       = $class->_pluck(
            [qw(-properties -where -fields -minimumFields -noSet)],@_
       );
     $minimumFields = $class->minimumFields if $minimumFields;

     if ($properties) {
          my $classProperties = $class->properties();
          foreach my $propertyName (keys %$classProperties) {
               next if exists $properties->{$propertyName};
               $properties->{$propertyName} 
                 = $classProperties->{$propertyName}{defaultValue};
          }
          unless (defined($properties->{$class->keyColumn()})) {
               $properties->{$class->keyColumn()} = 'new';
          }
          return bless {_property => $properties,_noSet => $noSet}, $class;
     } else {
          $where = $class->_mergeWhere($where,\%p);
          my $select = WebGUI::Persistent::Query::Select->new(
               table      => $class->table(),
               properties => $class->properties(),
               where      => $where,
               fields     => $minimumFields ? $minimumFields : $fields
          );
          my $query = $select->buildQuery();
          my $hash = WebGUI::SQL->quickHashRef($query);
          return undef unless defined %$hash; 
          return bless {_property => $hash,_noSet => $noSet}, $class;
     }
}

#-------------------------------------------------------------------

sub _pluck {
     my ($class,$p,%q) = @_;
     return ((map {delete($q{$_})} @$p),%q);
}

#-------------------------------------------------------------------

=head2 properties

Returns a cached hash reference containing the "properties" defined in 
classSettings()

=cut

sub properties {
     my ($class) = @_;
     unless ($class->classData->{properties}) {
          $class->classData->{properties} = $class->classSettings->{properties};
     }
     return $class->classData->{properties}
}

#-------------------------------------------------------------------

=head2 set( [ \%p ] )

This method optionally takes a hash reference of property to value and updates
the object and database:

 $obj->set({ B => 9, D => 60 });

If no arguments are provided then the object's current state is written to the
database.

 $obj->set();

=cut

sub set {
     my ($self,$properties) = @_;
     $properties ||= {};

     foreach my $propertyName (keys %$properties) {
          $self->{_property}{$propertyName} = $properties->{$propertyName};
     }
  
     return if $self->{_noSet};

     if ($self->get($self->keyColumn()) ne 'new') {
          my $update = WebGUI::Persistent::Query::Update->new(
               table      => $self->table(),
               where      => { $self->keyColumn => $self->get($self->keyColumn()) },
               data       => $properties,
               properties => $self->properties()
          );
          WebGUI::SQL->write($update->buildQuery());
     } else {
          $self->{_property}{$self->keyColumn()} = getNextId($self->keyColumn());
          my $insert = WebGUI::Persistent::Query::Insert->new(
               table      => $self->table(),
               data       => $self->{_property},
               properties => $self->properties()
          );
          WebGUI::SQL->write($insert->buildQuery());
     }
}

#-------------------------------------------------------------------

=head2 table

Returns the table name set in classSettings().

=cut 

sub table {
     my ($class) = @_;
     unless ($class->classData->{table}) {
          unless ($class->classSettings->{table}) {
               WebGUI::ErrorHandler::fatalError("table() must be overridden");
          }
          $class->classData->{table} = $class->classSettings->{table};
     }
     return $class->classData->{table}
}

1;
