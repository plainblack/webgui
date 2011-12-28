package WebGUI::Definition::Meta::Property::Crud;

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
no warnings qw(uninitialized);

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Meta::Property::Asset

=head1 DESCRIPTION

Extends WebGUI::Definition::Meta::Property to provide Asset properties with
specific methods.  The tableName and fieldType class properties must be defined.

=head1 METHODS

The following methods are added.

=cut

has 'serialize' => (
    is       => 'ro',
);

has 'isQueryKey' => (
    is => 'ro',
);

#-------------------------------------------------------------------

=head2 serialize ( )

serialize tells WebGUI::Crud to automatically serialize this field in a JSON wrapper before storing it to the database, and to convert it back to it's native structure upon retrieving it from the database. This is useful if you wish to persist hash references or array references.

=cut

#-------------------------------------------------------------------

=head2 isQueryKey ( )

isQueryKey tells WebGUI::Crud that the field should be marked as 'non null' in the table and then adds an index of the same name to the table to make searching on the field faster. B<WARNING:> Don't use this if the field is already a sequenceKey. If it's a sequence key then it will automatically be indexed.

=cut

#-------------------------------------------------------------------

=head2 noFormPost ( )

This is boolean which indicates that no data from HTML forms should be validated
and stored for this property.

=cut

1;

