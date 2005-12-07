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
use WebGUI::ProfileCategory;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Form;
use WebGUI::FormProcessor;


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
sub _reorderFields {
	my $category = shift;
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select fieldName from userProfileField where profileCategoryId=".quote($category)." order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;   
                WebGUI::SQL->write("update userProfileField set sequenceNumber='$i' where fieldName=".quote($id));
        }               
        $sth->finish;   
}    

#-------------------------------------------------------------------

=head2 create ( fieldName [, properties, categoryId] ) 

Add a new field to the system. Returns a WebGUI::ProfileField object if created successfully, otherwise returns undef.

=head3 fieldName

The unique name of this field.

=head3 properties

A hash reference containing the properties of this field. See the set() method for details.

=head3 categoryId

The unique id of the category to assign this field to. Defaults to "1" (misc).

=cut

sub create {
        my $class = shift;
	my $fieldName = shift;
        my $properties = shift;
	my $categoryId = shift;
	my ($fieldName) = WebGUI::SQL->quickArray("select count(*) from userProfileField where fieldName=".quote($fieldName));
	return undef if ($fieldName);
        my $id = WebGUI::SQL->setRow("userProfileField","fieldName",{fieldName=>"new"},undef,$fieldName);
        my $self = $class->new($id);
	$self->setCategory($categoryId || "1");
        $self->update($properties);
        return $self;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this field and all user data attached to it.

=cut

sub delete {
	my $self = shift;
	WebGUI::SQL->write("delete from userProfileData where fieldName=".quote($self->getId));
	WebGUI::SQL->deleteRow("userProfileField","fieldName",$self->getId);
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
        my $self = shift;
        my $propertyName = shift;
        if (defined $propertyName) {
                return $self->{_properties}{$propertyName};
        }
        return $self->{_properties};
}

#-------------------------------------------------------------------

=head2 getCategory ()

Returns a WebGUI::ProfileCategory object for the category that this profile field belongs to.

=cut

sub getCategory {
	my $self = shift;
	return WebGUI::ProfileCategory->new($self->get("categoryId"));
}


#-------------------------------------------------------------------

=head2 getId ()

Returns the unique fieldName for this field. 

B<NOTE:> This method is named getId for consistency amongst other packages even though technically profile fields have field names rather than ids.
        
=cut    
        
sub getId {
        my $self = shift;
        return $self->get("fieldName");
}

#-------------------------------------------------------------------

=head2 moveDown ()

Moves this field down one position within it's category.

=cut

sub moveDown {
	my $self = shift;
 	my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($self->getId));
        ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=".quote($profileCategoryId)." and sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($self->getId));
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($id));
                _reorderFields($profileCategoryId);
        }
}

#-------------------------------------------------------------------

=head2 moveUp ()

Moves this field up one position within it's category.

=cut

sub moveUp {
	my $self = shift;
	my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($self->getId));
        ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=".quote($profileCategoryId)." and sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($self->getId));
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($id));
                _reorderFields($profileCategoryId);
        }
}


#-------------------------------------------------------------------

=head2 new ( fieldName )

Constructor

=head3 fieldName

The unique name of this field.

=cut

sub new {
        my $class = shift;
        my $id = shift;
        return undef unless ($id);
        my $properties = WebGUI::SQL->getRow("userProfileField","fieldName",$id);
        bless {_properties=>$properties}, $class;
}

#-------------------------------------------------------------------

=head2 rename ( newFieldName )

Renames this field. Returns a 1 if successful and a 0 if not.

=head3 newFieldName

The new name this field should take.

=cut

sub rename {
	my $self = shift;
	my $newName = shift;
	my ($fieldNameExists) = WebGUI::SQL->quickArray("select count(*) from userProfileField where fieldName=".quote($newName));
	return 0 if ($fieldNameExists);
	WebGUI::SQL->write("update userProfileData set fieldName=".quote($newName)." where fieldName=".quote($self->getId));
	WebGUI::SQL->write("update userProfileField set fieldName=".quote($newName)." where fieldName=".quote($self->getId));
	$self->{_properties}{fieldName} = $newName;
	return 1;
}


#-------------------------------------------------------------------

=head2 set ( properties )

Update the profile field properties.

=head3 properties

A hash reference containing the properties to be updated.

=head4 label

A perl structure that will return a scalar. Defaults to 'Undefined'.

=head4 visible

A boolean indicating whether this field should be visible when a user views a user's profile. Defaults to 0.

=head4 required

A boolean indicating whether the user must fill out this field in order to create/update his account. Defaults to 0.

=head4 protected

A boolean indicating whether this field may be deleted or not. Defaults to 0.

=head4 editable

A boolean indicating whether this field is editable by the user or not. Defaults to 0.

=head4 fieldType

A scalar indicating the type of field this will be when generated as a form element. Defaults to 'text'.

=head4 possibleValues

A scalar containing a hash reference declaration of possible values. Only used for list type fields.

=head4 defaultValues

A scalar containing an array reference or scalar declaration of defaultly selected value(s). 

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	$properties->{visible} = 0 unless ($properties->{visible} == 1);
	$properties->{editable} = 0 unless ($properties->{editable} == 1);
	$properties->{protected} = 0 unless ($properties->{protected} == 1);
	$properties->{required} = 0 unless ($properties->{required} == 1);
	$properties->{label} = 'Undefined' if ($properties->{label} =~ /^[\"\']*$/);
	$properties->{fieldType} = 'text' unless ($properties->{fieldType});
	if ($properties->{defaultValues} && $properties->{fieldType}=~/List$/) {
                unless ($properties->{defaultValues} =~ /^\[/) {
                        $properties->{defaultValues} = "[".$properties->{defaultValues};
                }
                unless ($properties->{defaultValues} =~ /\]$/) {
                        $properties->{defaultValues} .= "]";
                }
        }
	WebGUI::SQL->setRow("userProfileCategory","profileCategoryId",$properties);
	foreach my $key (keys %{$properties}) {
		$self->{_property}{$key} = $properties->{$key};
	}
}

#-------------------------------------------------------------------

=head2 setCategory ( id )

Assigns this field to a new category.

=head3 id

The unique ID of a category to assign this field to.

=cut

sub setCategory {
	my $self = shift;
	my $categoryId = shift;
	return undef unless ($categoryId);
	my $currentCategoryId = $self->get("profileCategoryId");
        my ($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from userProfileField where profileCategoryId=".quote($categoryId));
	WebGUI::SQL->setRow("userProfileField","fieldName",{fieldName=>$self->getId, profileCategoryId=>$categoryId, sequenceNumber=>$sequenceNumber+1});
	$self->{_property}{profileCategoryId} = $categoryId;
	$self->{_property}{sequenceNumber} = $sequenceNumber+1;
	_reorderFields($currentCategoryId) if ($currentCategoryId);
	_reorderFields($categoryId);
}

1;


