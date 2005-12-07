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
use WebGUI::Id;
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
	my $class = shift;
	my $properties = shift;
 	my $id = WebGUI::Id::generate();
        my ($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from userProfileCategory");
        WebGUI::SQL->write("insert into userProfileCategory (profileCategoryId,sequenceNumber) values (".quote($id).", ".($sequenceNumber+1).")");
	my $self = $class->new($id);
	$self->update($properties);
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this category and all fields attached to it.

=cut

sub delete {
	my $self = shift;
	foreach my $field (@{$self->getFields}) {
		$field->delete;
	}
	WebGUI::SQL->write("delete from userProfileCategory where profileCategoryId=".quote($self->getId));
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a hash reference of all the properties of the category.

=head3 property

If specified, the value of an individual property is returned.

=cut

sub get {
        my $self = shift;
        my $propertyName = shift;
        if (defined $propertyName) {
                return $self->{_properties}{$propertyName};
        }
        return $self->{_properties};
}

#-------------------------------------------------------------------

=head2 getCategories ()

Returns an array reference of all WebGUI::ProfileCategory objects in order of sequence. This is a class method.

=cut

sub getCategories {

}


#-------------------------------------------------------------------

=head2 getFields ()

Returns an array reference of all WebGUI::ProfileField objects that are part of this category in order of sequence.

=cut

sub getFields {

}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique ID for this category.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
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


