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
use WebGUI::ProfileField;
use WebGUI::Session;
use WebGUI::SQL;


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
sub _reorderCategories {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select profileCategoryId from userProfileCategory order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber='$i' where profileCategoryId=".quote($id));
        }       
        $sth->finish;
}  

#-------------------------------------------------------------------

=head2 create ( [ properties] ) 

Add a new category to the system. Returns a WebGUI::ProfileCategory object if created successfully, otherwise returns undef.

=head3 properties

A hash reference containing the properties of this field. See the set() method for details.

=cut

sub create {
	my $class = shift;
	my $properties = shift;
        my ($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from userProfileCategory");
 	my $id = WebGUI::SQL->setRow("userProfileCategory","profileCategoryId",{profileCategoryId=>"new", sequenceNumber=>$sequenceNumber+1});
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
	WebGUI::SQL->deleteRow("userProfileCategory","profileCategoryId",$self->getId);
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
	my $self = shift;
	my @categories = ();
 	foreach my $id (WebGUI::SQL->buildArray("select profileCategoryId from userProfileCategory order by sequenceNumber")) {
		push(@categories,WebGUI::ProfileCategory->new($id));
	}
	return \@categories;
}


#-------------------------------------------------------------------

=head2 getFields ()

Returns an array reference of all WebGUI::ProfileField objects that are part of this category in order of sequence.

=cut

sub getFields {
	my $self = shift;
	my @fields = ();
	foreach my $fieldName (WebGUI::SQL->buildArray("select fieldName from userProfileField where profileCategoryId=".quote($self->getId)." order by sequenceNumber")){
		push(@fields,WebGUI::ProfileField->new($fieldName));
	}
	return \@fields;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique ID for this category.

=cut

sub getId {
	my $self = shift;
	return $self->get("profileCategoryId");
}

#-------------------------------------------------------------------

=head2 moveDown ()

Moves this category down one position.

=cut

sub moveDown {
	my $self = shift;
        my ($id, $thisSeq);
        ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=".quote($self->getId));
        ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=".quote($self->getId));
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=".quote($id));
                _reorderCategories();
        }
}

#-------------------------------------------------------------------

=head2 moveUp ()

Moves this field up one position.

=cut

sub moveUp {
	my $self = shift;
	my ($id, $thisSeq);
        ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=".quote($self->getId));
        ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=".quote($self->getId));
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=".quote($id));
                _reorderCategories();
        }
}

#-------------------------------------------------------------------

=head2 new ( id )

Constructor

=head3 id

The unique id of this category.

=cut

sub new {
	my $class = shift;
	my $id = shift;
	return undef unless ($id);
	my $properties = WebGUI::SQL->getRow("userProfileCategory","profileCategoryId",$id);
	bless {_properties=>$properties}, $class;
}


#-------------------------------------------------------------------

=head2 set ( properties )

Update the profile field properties.

=head3 properties

A hash reference containing the properties to be updated.

=head4 label

A perl structure that will return a scalar. Defaults to 'Undefined'.

=head4 visible

A boolean indicating whether the fields in this category should be visible when a user views a user's profile.

=head4 editable

A boolean indicating whether the user can edit the fields under this category.

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	$properties->{visible} = 0 unless ($properties->{visible} == 1);
	$properties->{editable} = 0 unless ($properties->{editable} == 1);
	$properties->{label} = 'Undefined' if ($properties->{label} =~ /^[\"\']*$/);
	WebGUI::SQL->setRow("userProfileCategory","profileCategoryId",$properties);
}


1;


