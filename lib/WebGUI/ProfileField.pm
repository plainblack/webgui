package WebGUI::ProfileField;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;


=head1 NAME

Package WebGUI::ProfileField

=head1 DESCRIPTION

This package is used to manipulate the schema of the user profiling system. If you wish to manipulate the profile data for an individual user look at WebGUI::User.

=head1 SYNOPSIS

 use WebGUI::ProfileField;

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 create ( fieldName [, properties] ) 

Add a new field to the system. Returns a WebGUI::ProfileField object if created successfully, otherwise returns undef.

=head3 fieldName

The unique name of this field.

=head3 properties

A hash reference containing the properties of this field. See the set() method for details.

=cut

sub create {

}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this field and all user data attached to it.

=cut

sub delete {

}

#-------------------------------------------------------------------

=head2 formField ()

Returns an HTMLified form field element.

=cut

sub formField {

}


#-------------------------------------------------------------------

=head2 formProcess ()

Returns the value retrieved from a form post.

=cut

sub formProcess {

}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a hash reference of all the properties of the field.

=head3 property

If specified, the value of an individual property is returned.

=cut

sub get {

}

#-------------------------------------------------------------------

=head2 moveDown ()

Moves this field down one position within it's category.

=cut

sub moveDown {

}

#-------------------------------------------------------------------

=head2 moveUp ()

Moves this field up one position within it's category.

=cut

sub moveUp {

}


#-------------------------------------------------------------------

=head2 new ( fieldName )

Constructor

=head3 fieldName

The unique name of this field.

=cut

sub new {
	my $class = shift;
}

#-------------------------------------------------------------------

=head2 rename ( newFieldName )

Renames this field. Returns a 1 if successful and a 0 if not.

=head3 newFieldName

The new name this field should take.

=cut

sub rename {

}


#-------------------------------------------------------------------

=head2 set ( properties )

Update the profile field properties.

=head3 properties

A hash reference containing the properties to be updated.

=head4 label

A perl structure that will return a scalar. Defaults to 'Undefined'.

=head4 visible

A boolean indicating whether this field should be visible when a user views a user's profile.

=head4 required

=head4 protected

=head4 editable

=head4 fieldType

=head4 possibleValues

=head4 defaultValues

=head4 categoryId

=cut

sub update {

}


1;


