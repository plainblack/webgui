package WebGUI::Asset::Wobject::Thingy::Thing;

=head1 LEGAL

 -------------------------------------------------------------------
  Thingy is Copyright 2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Crud';
use Class::InsideOut qw(readonly private id register);
use WebGUI::International;
#use WebGUI::Exception;
#use WebGUI::Inbox;
#use WebGUI::User;

#private user => my %user;


#-------------------------------------------------------------------

=head2 addField ( field, isImport )

Adds a new field.

=head3 field

A hashref containing the properties of the new field.

=head3 isImport

If isImport is true the new field will keep the fieldId and assetId in the properties hashref. The thingId is
always taken from the field hashref.

=cut

sub addField {

    my $self = shift;
    my $field = shift;
    my $isImport = shift;
    my $dbDataType = shift || $self->_getDbDataType($field->{fieldType});
    my $db = $self->session->db;
    my ($oldFieldId, $newFieldId,$useAssetId,$useSequence);

    if ($isImport){
        $oldFieldId = $field->{fieldId};
    }
    else {
        $useAssetId = 1;
    }

    $field->{fieldId} = "new";
    $newFieldId = $self->setCollateral("Thingy_fields","fieldId",$field,1,$useAssetId);

    if ($isImport){
        $db->write("update Thingy_fields set fieldId = ".$db->quote($oldFieldId)
            ." where fieldId = ".$db->quote($newFieldId));
        $newFieldId = $oldFieldId;
    }

    my $thingyTableName = "Thingy_".$field->{thingId};
    my $columnName = "field_".$newFieldId;
    $db->write(
        "ALTER TABLE ".$db->dbh->quote_identifier($thingyTableName)
        ." ADD ".$db->dbh->quote_identifier($columnName)." ". $dbDataType
            );

    return $newFieldId;
}

#-------------------------------------------------------------------

=head2 crud_definition

WebGUI::Crud definition for this class.

=head3 tableName

Thingy_things

=head3 tableKey

thingId

=head3 sequenceKey

None. Things have no sequence amongst themselves.

=cut
sub crud_definition {
    my ($class, $session) = @_;
    my $i18n = WebGUI::International->new($session, "Asset_Thingy");

    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName} = 'Thingy_things';
    $definition->{tableKey} = 'thingId';
    $definition->{sequenceKey} = '';
    $definition->{properties}{assetId} = {
            fieldType       => 'guid',
            defaultValue    => undef,
        };
    $definition->{properties}{label} = {
            fieldType       => 'text',
            defaultValue    => $i18n->get('thing name label'),
        };
    $definition->{properties}{editScreenTitle} = {
            fieldType       => 'text',
            defaultValue    => $i18n->get('edit screen title label'),
        };
    $definition->{properties}{editInstructions} = {
            fieldType       => 'HTMLArea',
            defaultValue    => '',
        };
    $definition->{properties}{groupIdAdd} = {
            fieldType       => 'group',
            defaultValue    => undef,
        };
    $definition->{properties}{groupIdEdit} = {
            fieldType       => 'group',
            defaultValue    => undef,
        };
    $definition->{properties}{saveButtonLabel} = {
            fieldType       => 'text',
            defaultValue    => $i18n->get('default save button label'),
        };
    $definition->{properties}{afterSave} = {
            fieldType       => 'selectBox',
            defaultValue    => 'searchThisThing',
        };
    $definition->{properties}{editTemplateId} = {
            fieldType       => 'template',
            defaultValue    => "ThingyTmpl000000000003",
        };
    $definition->{properties}{onAddWorkflowId} = {
            fieldType       => 'workflow',
            defaultValue    => undef,
        };
    $definition->{properties}{onEditWorkflowId} = {
            fieldType       => 'workflow',
            defaultValue    => undef,
        };
    $definition->{properties}{onDeleteWorkflowId} = {
            fieldType       => 'workflow',
            defaultValue    => undef,
        };
    $definition->{properties}{groupIdView} = {
            fieldType       => 'group',
            defaultValue    => undef,
        };
    $definition->{properties}{viewTemplateId} = {
            fieldType       => 'template',
            defaultValue    => "ThingyTmpl000000000002",
        };
    $definition->{properties}{defaultView} = {
            fieldType       => 'selectBox',
            defaultValue    => 'searchThing',
        };
    $definition->{properties}{searchScreenTitle} = {
            fieldType       => 'text',
            defaultValue    => undef,
        };
    $definition->{properties}{searchDescription} = {
            fieldType       => 'HTMLArea',
            defaultValue    => '',
        };
    $definition->{properties}{groupIdSearch} = {
            fieldType       => 'group',
            defaultValue    => undef,
        };
    $definition->{properties}{groupIdExport} = {
            fieldType       => 'group',
            defaultValue    => undef,
        };
    $definition->{properties}{groupIdImport} = {
            fieldType       => 'group',
            defaultValue    => undef,
        };
    $definition->{properties}{searchTemplateId} = {
            fieldType       => 'template',
            defaultValue    => "ThingyTmpl000000000004",
        };
    $definition->{properties}{thingsPerPage} = {
            fieldType       => 'int',
            defaultValue    => 25,
        };
    $definition->{properties}{sortBy} = {
            fieldType       => 'selectBox',
            defaultValue    => undef,
        };
    $definition->{properties}{exportMetaData} = {
            fieldType       => 'yesNo',
            defaultValue    => undef,
        };
    $definition->{properties}{maxEntriesPerUser} = {
            fieldType       => 'int',
            defaultValue    => undef,
        };
    return $definition;
}

#-------------------------------------------------------------------

=head2 create ( thingy, [ properties ], [ options ])

Extend the method from WebGUI::Crud to handle creating a table for the new Thing and setting
some default values based on the parent Thingy's properties.

=head3 thingy

A reference to a Thingy object

=head3 properties

A hashref containing the properties of the new thing.

=head3 options

A hash reference of creation options.

=head4 id

A guid. Use this to force the row's table key to a specific ID.

=cut

sub create {
    my ($class, $thingy, $properties, $options) = @_;
    my $session = $thingy->session; 
    
    my $groupIdEdit = $thingy->get("groupIdEdit");
    $properties->{groupIdEdit}      = $groupIdEdit;
    $properties->{groupIdAdd}       = $groupIdEdit;
    $properties->{groupIdSearch}    = $groupIdEdit;
    $properties->{groupIdExport}    = $groupIdEdit;
    $properties->{groupIdImport}    = $groupIdEdit;

    my $newThing = $class->SUPER::create($session,$properties,$options);

    $session->db->write("create table ".$session->db->dbh->quote_identifier("Thingy_".$newThing->getId)."(
        thingDataId CHAR(22) binary not null,
        dateCreated DATETIME not null,
        createdById CHAR(22) not null,
        updatedById CHAR(22) not null,
        updatedByName CHAR(255) not null,
        lastUpdated DATETIME not null,
        ipAddress CHAR(255),
        sequenceNumber INT(11),
        primary key (thingDataId)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8");    

    return $newThing;
}

#-------------------------------------------------------------------

=head2 delete ( )

Extend the method from WebGUI::Crud to handle deleting the Thing's table and fields.

=cut

sub delete {
    my ($self)  = @_;
    my $db      = $self->session->db;

    $db->write("delete from Thingy_fields where thingId =?",[$self->getId]);
    $db->write("drop table if exists ".$db->dbh->quote_identifier("Thingy_".$self->getId));

    return $self->SUPER::delete;
}

#-------------------------------------------------------------------

=head2 _getDbDataType ( fieldType )

returns the database data type for a field based on the fieldType.

=head3 fieldType

The fieldType for which the database data type should be returned.

=cut

sub _getDbDataType {

    my $self = shift;
    my $fieldType = shift;
    my $session = $self->session;

    my ($dbDataType, $formClass);

    if ($fieldType =~ m/^otherThing/x){
        $dbDataType = "CHAR(22)";
    }
    else{
        $formClass   = 'WebGUI::Form::' . ucfirst $fieldType;
        my $formElement = eval { WebGUI::Pluggable::instanciate($formClass, "new", [$session]) };
        $dbDataType = $formElement->getDatabaseFieldType;
    }
    return $dbDataType;

}

#-------------------------------------------------------------------

=head2 hasEnteredMaxPerUser

Check whether the current user has entered the maximum number of entries allowed for this thing.

=cut

sub hasEnteredMaxPerUser {
    my ($self)  = @_;
    my $session = $self->session;
    my $db      = $session->db;

    return 0 unless $self->get('maxEntriesPerUser');

    my $numberOfEntries = $db->quickScalar(
        "select count(*) from ".$db->dbh->quote_identifier("Thingy_".$self->getId)." where createdById=?",
        [$session->user->userId]);

    if($numberOfEntries < $self->get('maxEntriesPerUser')){
        return 0;
    }
    else{
        return 1;
    }
}

1;
