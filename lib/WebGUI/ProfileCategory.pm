package WebGUI::ProfileCategory;


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

Package WebGUI::ProfileCategory

=head1 DESCRIPTION

This package is used to manipulate the organization of the user profiling system. 

=head1 SYNOPSIS

 use WebGUI::ProfileCategory;

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 create ( [ properties] ) 

Add a new category to the system. Returns a WebGUI::ProfileCategory object if created successfully, otherwise returns undef.

=head3 properties

A hash reference containing the properties of this field. See the set() method for details.

=cut

sub create {

}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this category and all fields attached to it.

=cut

sub delete {

}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a hash reference of all the properties of the category.

=head3 property

If specified, the value of an individual property is returned.

=cut

sub get {

}

#-------------------------------------------------------------------

=head2 moveDown ()

Moves this category down one position.

=cut

sub moveDown {

}

#-------------------------------------------------------------------

=head2 moveUp ()

Moves this field up one position.

=cut

sub moveUp {

}

#-------------------------------------------------------------------

=head2 new ( id )

Constructor

=head3 id

The unique id of this category.

=cut

sub new {
	my $class = shift;
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

=head4 editable

=cut

sub set {

}


1;


