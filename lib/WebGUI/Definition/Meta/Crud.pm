package WebGUI::Definition::Meta::Crud;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use 5.010;
use Moose::Role;
use namespace::autoclean;
use WebGUI::Definition::Meta::Property;
use WebGUI::Definition::Meta::Property::Crud;
no warnings qw(uninitialized);

with 'WebGUI::Definition::Meta::Class';

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Meta::Crud

=head1 DESCRIPTION

Extends 'WebGUI::Definition::Meta::Class' to provide attributes specific to Cruds.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 property_meta ( )

Asset Definitions use WebGUI::Definition::Meta::Property::Crud as the base class
for properties.

=cut

has 'property_metaroles' => (
    is => 'ro',
    default => sub { [ 'WebGUI::Definition::Meta::Property', 'WebGUI::Definition::Meta::Property::Crud'] },
);

#-------------------------------------------------------------------

has [ qw{tableName tableKey sequenceKey} ] => (
    is       => 'rw',
);

#-------------------------------------------------------------------

=head2 tableName ( )

The table that this plugin stores its properties in.

=cut

#-------------------------------------------------------------------

=head2 tableKey ( )

The column in the table that is the primary key.

=cut

#-------------------------------------------------------------------

=head2 sequenceKey ( )

The column in the table that denotes the order of objects in the table.  If undef, or empty,
then no ordering is possible.

=cut

1;
