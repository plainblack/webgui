package WebGUI::ProfileField;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Form::DynamicField;
use WebGUI::Operation::Shared;
use WebGUI::HTML;
use WebGUI::User;
use WebGUI::Utility;


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
	my $self = shift;
	my $category = shift;
        my ($sth, $i, $id);
        $sth = $self->session->db->read("select fieldName from userProfileField where profileCategoryId=".$self->session->db->quote($category)." order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;
                $self->session->db->write("update userProfileField set sequenceNumber='$i' where fieldName=".$self->session->db->quote($id));
        }
        $sth->finish;
}

#-------------------------------------------------------------------

=head2 isReservedFieldName ( fieldName )

Return true iff fieldName is reserved and therefore not usable as a profile field name.

=cut

sub isReservedFieldName {
	my $class = shift;
	my $fieldName = shift;
	return isIn($fieldName, ('func', 'op'));
}

#-------------------------------------------------------------------

=head2 create ( session, fieldName [, properties, categoryId] )

Add a new field to the system. Returns a WebGUI::ProfileField object if created successfully, otherwise returns undef.

=head3 session

A reference to the current session.

=head3 fieldName

The unique name of this field.

=head3 properties

A hash reference containing the properties of this field. See the set() method for details.

=head3 categoryId

The unique id of the category to assign this field to. Defaults to "1" (misc).

=cut

sub create {
        my $class = shift;
	my $session = shift;
	my $fieldName = shift;
        my $properties = shift;
	my $categoryId = shift || "1";
	my ($fieldNameExists) = $session->db->quickArray("select count(*) from userProfileField where fieldName=".$session->db->quote($fieldName));
	return undef if ($fieldNameExists);
	return undef if $class->isReservedFieldName($fieldName);

        my $id = $session->db->setRow("userProfileField","fieldName",{fieldName=>"new"},$fieldName);
        my $self = $class->new($session,$id);
	$self->setCategory($categoryId);
        $self->set($properties);
        return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this field and all user data attached to it.

=cut

sub delete {
	my $self = shift;
	$self->session->db->write("delete from userProfileData where fieldName=".$self->session->db->quote($self->getId));
	$self->session->db->deleteRow("userProfileField","fieldName",$self->getId);
}

#-------------------------------------------------------------------
sub _formProperties {
	my $self = shift;
	my $properties = shift || {};
	$properties->{label} = $self->getLabel unless $properties->{label};
	$properties->{fieldType} = $self->get("fieldType");
	$properties->{name} = $self->getId;
	my $values = WebGUI::Operation::Shared::secureEval($self->session,$self->get("possibleValues"));
	unless (ref $values eq 'HASH') {
		if ($self->get('possibleValues') =~ /\S/) {
			$self->session->errorHandler->warn("Could not get a hash out of possible values for profile field ".$self->getId);
		}
		$values = {};
	}
	my $orderedValues = {};
	tie %{$orderedValues}, 'Tie::IxHash';
	foreach my $ov (sort keys %{$values}) {
		$orderedValues->{$ov} = $values->{$ov};
	}
	$properties->{options} = $orderedValues;
	$properties->{forceImageOnly} = $self->get("forceImageOnly");
	return $properties;
}

=head2 formField ( [ formProperties, withWrapper, userObject ] )

Returns an HTMLified form field element.

=head3 formProperties

Optionally pass in a list of properties to override the default properties of any form element. You cannot override the pieces specified as part of the form field like field type, label, options, etc.

=head3 withWrapper

An integer indicating whether to return just the field's form input, or the field with a table label wrapper (1), or just the field value (2).

=head3 userObject

A WebGUI::User object reference to use instead of the currently logged in user.

=cut

sub formField {
	my $self = shift;
	my $properties = $self->_formProperties(shift);
	my $withWrapper = shift;
	my $u = shift;
	my $skipDefault = shift;
	my $default;
	if ($skipDefault) {
	} elsif (defined $self->session->form->process($properties->{name})) {
		$default = $self->session->form->process($properties->{name});
	} elsif (defined $u && defined $u->profileField($properties->{name})) {
		$default = $u->profileField($properties->{name});
	} elsif (!defined $u && defined $self->session->user->profileField($properties->{name})) {
		$default = $self->session->user->profileField($properties->{name});
	} else {
		$default = WebGUI::Operation::Shared::secureEval($self->session,$properties->{dataDefault});
	}
	$properties->{value} = $default;
	if ($withWrapper == 1) {
		return WebGUI::Form::DynamicField->new($self->session,%{$properties})->displayFormWithWrapper;
	} elsif ($withWrapper == 2) {
		return WebGUI::Form::DynamicField->new($self->session,%{$properties})->displayValue;
	} else {
		return WebGUI::Form::DynamicField->new($self->session,%{$properties})->displayForm;
	}
}


#-------------------------------------------------------------------

=head2 formProcess ( )

Returns the value retrieved from a form post.

=cut

sub formProcess {
	my $self = shift;
	my $result = $self->session->form->process($self->getId,$self->get("fieldType"),WebGUI::Operation::Shared::secureEval($self->session,$self->get("dataDefault")), $self->_formProperties);
	if (ref $result eq "ARRAY") {
		my @results = @$result;
		for (my $count=0;$count<scalar(@results);$count++) {
			$results[$count] = 	WebGUI::HTML::filter($results[$count], "javascript");
		}
		$result = \@results;
	} else {
		$result = WebGUI::HTML::filter($result, "javascript");
	}
	return $result;
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

=head2 getCategory ( )

Returns a WebGUI::ProfileCategory object for the category that this profile field belongs to.

=cut

sub getCategory {
	my $self = shift;
	return WebGUI::ProfileCategory->new($self->session,$self->get("profileCategoryId"));
}


#-------------------------------------------------------------------

=head2 getId ( )

Returns the unique fieldName for this field.

B<NOTE:> This method is named getId for consistency amongst other packages even though technically profile fields have field names rather than ids.

=cut

sub getId {
        my $self = shift;
        return $self->get("fieldName");
}

#-------------------------------------------------------------------

=head2 getLabel ( )

Returns the eval'd label for this field.

=cut

sub getLabel {
        my $self = shift;
        return WebGUI::Operation::Shared::secureEval($self->session,$self->get("label"));
}

#-------------------------------------------------------------------

sub _listFieldsWhere {
	my $class = shift;
	my $session = shift;
	my $whereClause = shift;
	return [map{$class->new($session, $_)} $session->db->buildArray(<<"SQL")];
  SELECT f.fieldName
    FROM userProfileField AS f
         LEFT JOIN userProfileCategory AS c ON f.profileCategoryId = c.profileCategoryId
   WHERE $whereClause
   ORDER BY c.sequenceNumber, f.sequenceNumber
SQL
}

#-------------------------------------------------------------------

=head2 getEditableFields ( session )

Returns an array reference of WebGUI::ProfileField objects that are marked "editable" or "required". This is a class method.

=cut

sub getEditableFields {
        my $class = shift;
	my $session = shift;
	return $class->_listFieldsWhere($session, "f.required = 1 OR f.editable = 1");
}

#-------------------------------------------------------------------

=head2 getFields ( session )

Returns an array reference of WebGUI::ProfileField objects. This is a class method.

=cut

sub getFields {
        my $class = shift;
	my $session = shift;
	return $class->_listFieldsWhere($session, "1");
}

#-------------------------------------------------------------------

=head2 getRequiredFields ( session )

Returns an array reference of WebGUI::ProfileField objects that are marked "required". This is a class method.

=cut

sub getRequiredFields {
	my $class = shift;
	my $session = shift;
	return $class->_listFieldsWhere($session, "f.required = 1");
}

#-------------------------------------------------------------------

=head2 getRegistrationFields ( session )

Returns an array reference of profile field objects to use during anonymous registration.  Class method.

=cut

sub getRegistrationFields {
	my $class = shift;
	my $session = shift;
	return $class->_listFieldsWhere($session, "f.showAtRegistration = 1");
}

=head2 getPasswordRecoveryFields ( session )

Returns an array reference of profile field objects that are required
for password recovery.  Class method.

=cut

sub getPasswordRecoveryFields {
	my $class = shift;
	my $session = shift;
	return $class->_listFieldsWhere($session, "f.requiredForPasswordRecovery = 1");
}

#-------------------------------------------------------------------

=head2 isEditable ( )

Returns a boolean indicating whether this field may be editable by a user.

=cut

sub isEditable {
        my $self = shift;
        return $self->get("editable") || $self->isRequired;
}


#-------------------------------------------------------------------

=head2 isProtected ( )

Returns a boolean indicating whether this field may be deleted.

=cut

sub isProtected {
        my $self = shift;
        return $self->get("protected");
}

#-------------------------------------------------------------------

=head2 isRequired ( )

Returns a boolean indicating whether this field is required when a user creates an account or updates their account.

=cut

sub isRequired {
        my $self = shift;
        return $self->get("required");
}

#-------------------------------------------------------------------

=head2 isViewable ( )

Returns a boolean indicating whether this field may be viewed by a user.

=cut

sub isViewable {
        my $self = shift;
        return $self->get("viewable");
}

#-------------------------------------------------------------------

=head2 moveDown ( )

Moves this field down one position within it's category.

=cut

sub moveDown {
	my $self = shift;
 	my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = $self->session->db->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".$self->session->db->quote($self->getId));
        ($id) = $self->session->db->quickArray("select fieldName from userProfileField where profileCategoryId=".$self->session->db->quote($profileCategoryId)." and sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                $self->session->db->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".$self->session->db->quote($self->getId));
                $self->session->db->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".$self->session->db->quote($id));
                $self->_reorderFields($profileCategoryId);
        }
}

#-------------------------------------------------------------------

=head2 moveUp ( )

Moves this field up one position within it's category.

=cut

sub moveUp {
	my $self = shift;
	my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = $self->session->db->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".$self->session->db->quote($self->getId));
        ($id) = $self->session->db->quickArray("select fieldName from userProfileField where profileCategoryId=".$self->session->db->quote($profileCategoryId)." and sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                $self->session->db->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".$self->session->db->quote($self->getId));
                $self->session->db->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".$self->session->db->quote($id));
                $self->_reorderFields($profileCategoryId);
        }
}


#-------------------------------------------------------------------

=head2 new ( session, fieldName )

Constructor

=head3 session

A reference to the current session.

=head3 fieldName

The unique name of this field.

=cut

sub new {
        my $class = shift;
	my $session = shift;
        my $id = shift;
        return undef unless ($id);
	return undef if $class->isReservedFieldName($id);
        my $properties = $session->db->getRow("userProfileField","fieldName",$id);
	# Reject properties that don't exist.
	return undef unless scalar keys %$properties;
        bless {_session=>$session, _properties=>$properties}, $class;
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
	my ($fieldNameExists) = $self->session->db->quickArray("select count(*) from userProfileField where fieldName=".$self->session->db->quote($newName));
	return 0 if ($fieldNameExists);
	$self->session->db->write("update userProfileData set fieldName=".$self->session->db->quote($newName)." where fieldName=".$self->session->db->quote($self->getId));
	$self->session->db->write("update userProfileField set fieldName=".$self->session->db->quote($newName)." where fieldName=".$self->session->db->quote($self->getId));
	$self->{_properties}{fieldName} = $newName;
	return 1;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
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

=head4 dataDefault

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
	if ($properties->{dataDefault} && $properties->{fieldType}=~/List$/) {
                unless ($properties->{dataDefault} =~ /^\[/) {
                        $properties->{dataDefault} = "[".$properties->{dataDefault};
                }
                unless ($properties->{dataDefault} =~ /\]$/) {
                        $properties->{dataDefault} .= "]";
                }
        }
	$properties->{fieldName} = $self->getId;
	$self->session->db->setRow("userProfileField","fieldName",$properties);
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

	return undef if ($categoryId eq $currentCategoryId);

        my ($sequenceNumber) = $self->session->db->quickArray("select max(sequenceNumber) from userProfileField where profileCategoryId=".$self->session->db->quote($categoryId));
	$self->session->db->setRow("userProfileField","fieldName",{fieldName=>$self->getId, profileCategoryId=>$categoryId, sequenceNumber=>$sequenceNumber+1});
	$self->{_property}{profileCategoryId} = $categoryId;
	$self->{_property}{sequenceNumber} = $sequenceNumber+1;
	$self->_reorderFields($currentCategoryId) if ($currentCategoryId);
	$self->_reorderFields($categoryId);
}

1;


