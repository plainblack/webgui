package WebGUI::ProfileField;


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

use strict;
use WebGUI::ProfileCategory;
use WebGUI::Form::DynamicField;
use WebGUI::Operation::Shared;
use WebGUI::HTML;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Pluggable;

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
    return isIn($fieldName, qw/userId shop specialState func op wg_privacySettings username authMethod dateCreated lastUpdated karma status referringAffiliate friendsGroup/);
}

#-------------------------------------------------------------------

=head2 fixDataColumnTypes ( session )

Checks the column types of userProfileData against the form fields that they use.  If they
differ then they are updated to match for the form field.  This is to account for bugs in
this module, and changes in Form types.

This is a class method.

=head3 session

A reference to the current session.

=cut

sub fixDataColumnTypes {
    my $class       = shift;
    my $session     = shift;
    
    my $dbh         = $session->db->dbh;

    my $fields = WebGUI::ProfileField->getFields($session);
    foreach my $field ( @{ $fields } ) {
        my $columnInfo = $dbh->column_info(undef, undef, 'userProfileData', $field->getId)->fetchrow_hashref();
        my $formField  = $field->formField(undef, undef, undef, undef, undef, 'returnObject');
        my $columnType = $formField->getDatabaseFieldType();
        $columnType =~ s/\s+\w+$//;
        if ($columnType eq 'BOOLEAN') {
            $columnType = 'TINYINT';  ##Alias for INT(1)
        }
        my $actualType = $columnInfo->{TYPE_NAME};
        if ($columnType =~ m/\(\d+\)/) {
            $actualType = sprintf('%s(%s)', $actualType, $columnInfo->{COLUMN_SIZE});
        }
        if ($actualType ne $columnType) {
            $session->log->warn("Updating ".$field->getId." from $actualType to $columnType");
            $session->db->write('ALTER TABLE userProfileData MODIFY COLUMN '.$dbh->quote_identifier($field->getId).' '.$columnType);
        }
    }

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
    my $class       = shift;
    my $session     = shift;
    my $fieldName   = shift;
    my $properties  = shift;
    my $categoryId  = shift || "1";
    
    my $db          = $session->db;

    ### Check data
    # Check if the field already exists
    $properties->{fieldType} ||= "ReadOnly";
    return undef if $class->exists($session,$fieldName);
    return undef if $class->isReservedFieldName($fieldName);

    ### Data okay, create the field
    # Add the record
    my $id = $session->db->setRow("userProfileField","fieldName",
                {
                    fieldName=>"new",
                    fieldType => $properties->{fieldType},
                },
                $fieldName
    );
    my $self = $class->new($session,$id);
    
    # Get the field's data type
    my $formClass   = $self->getFormControlClass;
    eval { WebGUI::Pluggable::load($formClass) };
    my $dbDataType = $formClass->getDatabaseFieldType;

    # Add the column to the userProfileData table
    $db->write(
        "ALTER TABLE userProfileData ADD " . $db->dbh->quote_identifier($fieldName)
        . $dbDataType
    );
    
    $self->setCategory($categoryId);
    $self->set($properties);
    
    return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this field and all user data attached to it.

=cut

sub delete {
    my $self    = shift;
    my $db      = $self->session->db;
    
    # Remove the column from the userProfileData table
    $db->write("ALTER TABLE userProfileData DROP " . $db->dbh->quote_identifier($self->getId));

    # Remove the record
    $db->deleteRow("userProfileField","fieldName",$self->getId);
}

#-------------------------------------------------------------------

=head2 exists ( session, fieldName )

Class method that returns true if a field with the given name already 
exists. The first argument is a WebGUI::Session object. C<fieldName> is 
the field name to check

=cut

sub exists {
    my ( $class, $session, $fieldName ) = @_;
    
    return 1 if $session->db->quickScalar(
        "SELECT COUNT(*) FROM userProfileField WHERE fieldName=?",
        [$fieldName]
    );
}

#-------------------------------------------------------------------

=head2 formProperties ( hashRef )

Get a hashref of properties to give to a WebGUI::Form::Control. The
hashRef argument allows you to specify some additional items (such as
a value) that are not known by the ProfileField.

=cut

sub formProperties {
    my $self        = shift;
    my $properties  = shift || {};

    # Make a copy of the properties so we don't clobber them
    my %properties     = %{$properties};

    $properties{ label          } = $self->getLabel unless $properties->{label};
    $properties{ fieldType      } = $self->get("fieldType");
    $properties{ name           } = $self->getId;
    my $values 
    = WebGUI::Operation::Shared::secureEval($self->session,$self->get("possibleValues"));
    unless (ref $values eq 'HASH') {
        if ($self->get('possibleValues') =~ /\S/) {
            $self->session->errorHandler->warn("Could not get a hash out of possible values for profile field ".$self->getId);
        }
        $values = {};
    }
    my $orderedValues = {};
    tie %{$orderedValues}, 'Tie::IxHash';
    for my $ov (sort keys %{$values}) {
        $orderedValues->{$ov} = $values->{$ov};
    }
    $properties{ options            } = $orderedValues;
    $properties{ forceImageOnly     } = $self->get("forceImageOnly");
    $properties{ dataDefault        } = $self->get("dataDefault");
    return \%properties;
}

#-- This is here in case people did not understand that _ means private
#-- this can be removed when the API is unlocked.
sub _formProperties { my $self = shift; return $self->formProperties(@_); }

#-------------------------------------------------------------------

=head2 formField ( [ formProperties, withWrapper, userObject, skipDefault, assignedValue ] )

Returns an HTMLified form field element.

=head3 formProperties

Optionally pass in a list of properties to override the default properties of any form element. You cannot override the pieces specified as part of the form field like field type, label, options, etc.

=head3 withWrapper

An integer indicating whether to return just the field's form input, or the field with a table label wrapper (1), or just the field value (2).

=head3 userObject

A WebGUI::User object reference to use instead of the currently logged in user.

=head3 skipDefault

If true, this causes the default value set up for the form field to be ignored.  In choosing default,
skipDefault has the highest priority.

=head3 assignedValue

If assignedValue is defined, it will be used to override the default value set up for the
form.  assignedValue has the next highest priority.

=head3 returnObject

If true, it returns a WebGUI::Form object, instead of returning HTML.

=head3 useFieldDefault

If true, it uses the default setup for the ProfileField, instead of the user's default.  useFieldDefault
has the lowest priority.

=cut

# FIXME This would be better if it returned an OBJECT not the HTML
# TODO add a toHtml sub to take the place of this sub and a getFormControl
# And refactor to not require all these arguments HERE but rather in the 
# constructor or something...
sub formField {
    my $self             = shift;
    my $session          = $self->session;
    my $properties       = $self->formProperties(shift);
    my $withWrapper      = shift;
    my $u                = shift || $session->user;
    my $skipDefault      = shift;
    my $assignedValue    = shift;
    my $returnObject     = shift;
    my $useFieldDefault  = shift;
    
    if ($skipDefault) {
        $properties->{value} = undef;
    }
    elsif (defined $assignedValue) {
        $properties->{value} = $assignedValue;
    }
    elsif ($useFieldDefault) {
        $properties->{value} = WebGUI::Operation::Shared::secureEval($session,$properties->{dataDefault});
    }
    else {
        # start with specified (or current) user's data.  previous data needed by some form types as well (file).
        $properties->{value} = $u->profileField($self->getId);
        #If the fieldId is actually found in the request, try to process the form
        if ($session->form->param($self->getId)) {
            $properties->{value} = $self->formProcess($u);
        }
        #If no value is set, go with the default value
        if(!defined $properties->{value}) {
            $properties->{value} = WebGUI::Operation::Shared::secureEval($session,$properties->{dataDefault});
        }
    }
    my $form = WebGUI::Form::DynamicField->new($session,%{$properties});
    return $form if $returnObject;
    if ($withWrapper == 1) {
        return $form->toHtmlWithWrapper;
    } elsif ($withWrapper == 2) {
        return $form->getValueAsHtml;
    } else {
        return $form->toHtml;
    }
}

#-------------------------------------------------------------------

=head2 formProcess ( [ user ] )

Returns the value retrieved from a form post.

=head3 user

Optional user object to process properties for.  If no user object is passed
in the current user will be used.

=cut

sub formProcess {
    my $self       = shift;
    my $u          = shift || $self->session->user;
    my $userId     = $u->userId;
    
    my $properties  = $self->formProperties({value => $u->profileField($self->getId)});
    my $result      = $self->session->form->process(
        $self->getId,
        $self->get("fieldType"),
        WebGUI::Operation::Shared::secureEval($self->session,$self->get("dataDefault")),
        $properties
    );
    if (ref $result eq "ARRAY") {
        my @results = @$result;
        for (my $count=0;$count<scalar(@results);$count++) {
            $results[$count] =  WebGUI::HTML::filter($results[$count], "javascript");
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
    unless ($self->{_category}) {
        $self->{_category} = WebGUI::ProfileCategory->new($self->session,$self->get("profileCategoryId"));
    }
    return $self->{_category};
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

=head2 getExtras ()

Returns the value of the extras property for this field.

=cut

sub getExtras {
    my $self = shift;
    return $self->get('extras');
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
    return $class->_listFieldsWhere($session, "c.editable=1 AND (f.required = 1 OR f.editable = 1 OR f.showAtRegistration = 1)");
}

#-------------------------------------------------------------------

=head2 getFields ( session )

Returns an array reference of all WebGUI::ProfileField objects. This is a class method.

=cut

sub getFields {
    my $class = shift;
    my $session = shift;
    return $class->_listFieldsWhere($session, "1");
}

#-------------------------------------------------------------------

=head2 getFormControlClass

Returns the full class name of the form control for this profile field.

=cut

sub getFormControlClass {
    my $self    = shift;
    return "WebGUI::Form::" . ucfirst $self->get("fieldType");
}

#-------------------------------------------------------------------

=head2 getPrivacyOptions ( session )

Class method which returns a hash reference containing the privacy options available.

=cut

sub getPrivacyOptions {
    my $class   = shift;
    my $session = shift;
    my $i18n    = WebGUI::International->new($session);
    tie my %hash, "Tie::IxHash";
    %hash = (
        all     => $i18n->get('user profile field private message allow label'),
        friends => $i18n->get('user profile field private message friends only label'),
        none    => $i18n->get('user profile field private message allow none label'),
    );
    return \%hash;
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

#-------------------------------------------------------------------

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

=head2 isDuplicate( fieldValue, userId )

Checks the value of the field to see if it is duplicated in the system.  Returns true of false.

=head3 fieldValue

value to check for duplicates against

=head3 userId

userId to check for duplicates againts

=cut

sub isDuplicate {
    my $self      = shift;
    my $session   = $self->session;
    my $fieldId   = $self->getId;
    my $value     = shift;
    my $userId    = shift || $session->user->userId;

    my $sql       = qq{select count(*) from userProfileData where $fieldId = ? and userId <> ?};
    my $duplicate = $session->db->quickScalar($sql,[$value, $userId]);
    return ($duplicate > 0);
}

#-------------------------------------------------------------------

=head2 isEditable ( )

Returns a boolean indicating whether this field may be editable by a user.

=cut

sub isEditable {
        my $self = shift;
        return $self->getCategory->isEditable && ($self->get("editable") || $self->isRequired);
}


#-------------------------------------------------------------------

=head2 isInRequest ( )

Returns a boolean indicating whether this field was in the posted data.

=cut

sub isInRequest {
    my $self    = shift;
    my $session = $self->session;
    my $form = WebGUI::Form::DynamicField->new($session, 
       fieldType => $self->get('fieldType'),
       name      => $self->getId,
    );
    return $form->isInRequest;
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

=head2 isValid ( [fieldValue] )

Validates the profile field returning true (1) if valid or false(1) if false

=head3 fieldValue

value to validate the field against

=cut

sub isValid {
	my $self       = shift;
    my $fieldValue = shift;

    #If the field value is an array ref, set the value to the first element
    if(ref $fieldValue eq "ARRAY") {
        $fieldValue = $fieldValue->[0];
    }
        
	return !$self->isRequired || ($self->isRequired && $fieldValue ne "");
}

#-------------------------------------------------------------------

=head2 isViewable ( )

Returns a boolean indicating whether this field may be viewed by a user.

=cut

sub isViewable {
    my $self = shift;
    return $self->getCategory->isViewable && $self->get("visible");
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
    my $self        = shift;
    my $newName     = shift;

    my $session     = $self->session;
    my $db          = $session->db;

    ### Check data
    # Make sure the field doesn't exist
    return 0 if $self->exists($session, $newName);

    # Rename the userProfileData column
    my $fieldClass  = $self->getFormControlClass;
    eval { WebGUI::Pluggable::load($fieldClass) };
    my $dbDataType  = $fieldClass->getDatabaseFieldType;

    $self->session->db->write(
        "ALTER TABLE userProfileData "
        . "CHANGE " . $db->dbh->quote_identifier($self->getId) 
        . $db->dbh->quote_identifier($newName) . " " . $dbDataType
    );

    # Update the record
    $self->session->db->write(
        "update userProfileField set fieldName=? where fieldName=?",
        [$newName, $self->getId]
    );
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
    my $self        = shift;
    my $properties  = shift;

    my $session     = $self->session;
    my $db          = $session->db;

    # Set the defaults
    $properties->{visible}   = 0           unless ($properties->{visible}   == 1);
    $properties->{protected} = 0           unless ($properties->{protected} == 1);
    $properties->{required}  = 0           unless ($properties->{required}  == 1);
    $properties->{editable}  = $properties->{required} == 1 ? 1
                             : $properties->{editable} == 1 ? 1
                             : 0;
    $properties->{label}     = 'Undefined' if     ($properties->{label} =~ /^[\"\']*$/);
    $properties->{fieldType} = 'text'      unless ($properties->{fieldType});
    $properties->{extras}    = ''          unless ($properties->{extras});
    if ($properties->{dataDefault} && $properties->{fieldType}=~/List$/) {
        unless ($properties->{dataDefault} =~ /^\[/) {
            $properties->{dataDefault} = "[".$properties->{dataDefault};
        }
        unless ($properties->{dataDefault} =~ /\]$/) {
            $properties->{dataDefault} .= "]";
        }
    }
    $properties->{fieldName} = $self->getId;

    ##Save the fieldType now.  It can't be chacked against getFormControlClass now
    ##because it will return the OLD formControlClass, not the new one that we need
    ##to check against.
    my $originalFieldType = $self->get('fieldType');

    # Update the record
    $db->setRow("userProfileField","fieldName",$properties);
    foreach my $key (keys %{$properties}) {
        $self->{_properties}{$key} = $properties->{$key};
    }

    # If the fieldType has changed, modify the userProfileData column
    if ($properties->{fieldType} ne $originalFieldType) {
        # Create a copy of the new properties so we don't mess them up
        my $fieldClass  = $self->getFormControlClass;
        eval { WebGUI::Pluggable::load($fieldClass) };
        my $dbDataType 
        = $fieldClass->new($session, $self->formProperties($properties))->getDatabaseFieldType;

        my $sql 
        = "ALTER TABLE userProfileData MODIFY COLUMN " 
        . $db->dbh->quote_identifier($self->getId) . q{ }
        . $dbDataType
        ;

        $db->write($sql);
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

    my ($sequenceNumber) = $self->session->db->quickArray("select max(sequenceNumber) from userProfileField where profileCategoryId=?",  [$categoryId]);
    $self->session->db->setRow("userProfileField","fieldName",{fieldName=>$self->getId, profileCategoryId=>$categoryId, sequenceNumber=>$sequenceNumber+1});
    $self->{_property}{profileCategoryId} = $categoryId;
    $self->{_property}{sequenceNumber} = $sequenceNumber+1;
    $self->_reorderFields($currentCategoryId) if ($currentCategoryId);
    $self->_reorderFields($categoryId);
}


1;


