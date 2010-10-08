package WebGUI::Asset::Wobject::Thingy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use JSON;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::Text;
use WebGUI::Form::File;
use WebGUI::DateTime;
use base 'WebGUI::Asset::Wobject';
use Data::Dumper;
use PerlIO::eol qw/NATIVE/;


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

    my $self       = shift;
    my $field      = shift;
    my $isImport   = shift;
    my $dbDataType = shift || $self->_getDbDataType($field->{fieldType});
    my $session    = $self->session;
    my $db         = $session->db;
    my $error      = $session->errorHandler;
    my ($oldFieldId, $newFieldId,$useAssetId,$useSequence);

    $error->info("Adding Field, label: ".$field->{label}.", fieldId: ".$field->{fieldId}.",thingId: ".$field->{thingId});

    if ($isImport){
        $oldFieldId = $field->{fieldId};
    }
    else {
        $useAssetId = 1;
        #$useSequence = 1;
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

=head2 addThing ( thing, isImport )

Adds a new thing.

=head3 thing

A hashref containing the properties of the new thing.

=head3 isImport

If isImport is true the new thing will keep the thingId and assetId in the properties hashref.

=cut

sub addThing {
    
    my $self = shift;
    my $thing = shift;
    my $isImport = shift;
    my $db = $self->session->db;
    my $error = $self->session->errorHandler;
    my ($oldThingId, $newThingId,$useAssetId);

    $error->info("Adding Thing, label: ".$thing->{label}.", id: ".$thing->{thingId});
    
    if ($isImport){
        $oldThingId = $thing->{thingId};
    }
    else{
        $useAssetId = 1;
    }

    $thing->{thingId} = "new";
    $newThingId = $self->setCollateral("Thingy_things","thingId",$thing,0,$useAssetId);

    if ($isImport){
        $db->write("update Thingy_things set thingId = ".$db->quote($oldThingId)
        ." where thingId = ".$db->quote($newThingId));
        $newThingId = $oldThingId;
    }
    else{
        # Set this Thingy assets defaultThingId if this is its first Thing.
        my ($numberOfThings) = $db->quickArray('select count(*) from Thingy_things where assetId=?'
            ,[$self->getId]);
        if ($numberOfThings == 1){
            $self->update({defaultThingId => $newThingId});
        }
    }

    $db->write("create table ".$db->dbh->quote_identifier("Thingy_".$newThingId)."(
        thingDataId CHAR(22) binary not null,
        dateCreated int not null,
        createdById CHAR(22) not null,
        updatedById CHAR(22) not null,
        updatedByName CHAR(255) not null,
        lastUpdated int not null,
        ipAddress CHAR(255),
        primary key (thingDataId)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8");
    
    return $newThingId;
}


#-------------------------------------------------------------------

=head2 appendThingsVars ( vars, currentThingId )

Appends the list of things to a set of template vars.

=head3 vars

A hashref containing template variables.

=head3 currentThingId

A thingId. Will set the isCurrent flag in these template variables for the thing that the user is currently working with.

=cut

sub appendThingsVars {
    my ($self, $vars, $currentThingId) = @_;
    my $things = $self->getThings;
    my @thingLoop = ();
    while (my $thing = $things->hashRef) {
        push @thingLoop, {
            name        => $thing->{label},
            canView     => $self->hasPrivileges($thing->{groupIdView}),
            search_url  => $self->getUrl('func=search;thingId='.$thing->{thingId}),
            isCurrent   => ($currentThingId eq $thing->{thingId}),
            };
    }
    $vars->{listOfThings} = \@thingLoop;
}

#-------------------------------------------------------------------

=head2 canViewThing ( thingId, [ groupId ] )

Can the current user view the specified thing.

=head3 thingId

The unique id for a thing.

=head3 groupId

Pass in the groupId if you already have the view group for the thing.

=cut

sub canViewThing {
    my ($self, $thingId, $groupId) = @_;
    if ($groupId eq "") {
        $groupId = $self->session->db->quickScalar("select groupIdView from Thingy_things where thingId=?", [$thingId]);
    }
    return $self->hasPrivileges($groupId);
}

#-------------------------------------------------------------------

=head2 badOtherThing ( tableName, fieldName )

Checks that the table and field for the other Thing are okay.  Returns 0 if okay,
otherwise, returns an i18n message appropriate for the type of error, like the
table or the field in the table not existing.

=head3 tableName

The table name for the other thing.

=head3 fieldName

The field in the other thing to check for.

=cut

sub badOtherThing {
    my ($self, $tableName, $fieldName) = @_;
    my $session = $self->session;
    my $db      = $session->db;
    my $i18n    = WebGUI::International->new($session, 'Asset_Thingy');
    my ($otherThingTableExists) = $db->quickArray('show tables like ?',[$tableName]);
    return $i18n->get('other thing missing message') unless $otherThingTableExists;
    my ($otherThingFieldExists) = $db->quickArray(
        sprintf('show columns from %s like ?', $db->dbh->quote_identifier($tableName)),
        [$fieldName]);
    return $i18n->get('other thing field missing message') unless $otherThingFieldExists;
    return undef;
}

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for Thingy instances. If you choose to "autoGenerateForms", the
getEditForm method is unnecessary/redundant/useless.  

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, 'Asset_Thingy');
	my %properties;
	tie %properties, 'Tie::IxHash';
	
    %properties = (
		templateId =>{
			fieldType=>"template",  
			defaultValue=>'ThingyTmpl000000000001',
			tab=>"display",
			noFormPost=>0,  
			namespace=>"Thingy", 
			hoverHelp=>$i18n->get('thingy template description'),
			label=>$i18n->get('thingy template label'),
		},
        defaultThingId => {
            autoGenerate => 0,
            default=>undef,
            fieldType=>"selectBox",
        },
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'thingy.gif',
		autoGenerateForms=>1,
		tableName=>'Thingy',
		className=>'WebGUI::Asset::Wobject::Thingy',
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 duplicate ( )

Duplicates a Thingy, including the definitions of the Things in this Thingy and their fields.

=cut

sub duplicate {
	my $self = shift;
    my $options = shift;
	my $newAsset = $self->SUPER::duplicate($options);
    my $db = $self->session->db;
    my $assetId = $self->get("assetId");
    my $fields;

    my $otherThingFields = $db->buildHashRefOfHashRefs(
        "select fieldType, fieldId, right(fieldType,22) as otherThingId, fieldInOtherThingId from Thingy_fields
        where fieldType like 'otherThing_%' and assetId = ?",
        [$assetId],'fieldInOtherThingId'
    );

    my $things = $self->getThings;
    while ( my $thing = $things->hashRef) {
        my $oldSortBy   = $thing->{sortBy};
        my $oldThingId  = $thing->{thingId};
        my $newThingId  = $newAsset->addThing($thing,0);
        $fields = $db->buildArrayRefOfHashRefs('select * from Thingy_fields where assetId=? and thingId=?'
            ,[$assetId,$oldThingId]);
        foreach my $field (@$fields) {
            # set thingId to newly created thing's id.
            $field->{thingId} = $newThingId;
        
            my $originalFieldId = $field->{fieldId};

            my $newFieldId = $newAsset->addField($field,0);
            if ($originalFieldId eq $oldSortBy){
                $self->session->db->write( "update Thingy_things set sortBy = ? where thingId = ?",
                    [ $newFieldId, $newThingId ] );
            }

            if ($otherThingFields->{$originalFieldId}){
                $otherThingFields->{$originalFieldId}->{newFieldType}   = 'otherThing_'.$newThingId;
                $otherThingFields->{$originalFieldId}->{newFieldId}     = $newFieldId;
            }
        }
    }
    foreach my $otherThingField (keys %$otherThingFields){
        $db->write('update Thingy_fields set fieldType = ?, fieldInOtherThingId = ?
                    where fieldInOtherThingId = ? and assetId = ?',
                    [$otherThingFields->{$otherThingField}->{newFieldType},
                    $otherThingFields->{$otherThingField}->{newFieldId},
                    $otherThingFields->{$otherThingField}->{fieldInOtherThingId}, $newAsset->get('assetId')]);
    }
    return $newAsset;
}

#-------------------------------------------------------------------

=head2 duplicateThing ( thingId )

Duplicates a thing.

=head3 thingId

The id of the Thing that will be duplicated.

=cut

sub duplicateThing {

    my $self        = shift;
    my $oldThingId  = shift;
    my $db          = $self->session->db;

    my $thingProperties = $self->getThing($oldThingId);
    $thingProperties->{thingId} = 'new';
    $thingProperties->{label}   = $thingProperties->{label}.' (copy)';

    my $newThingId = $self->addThing($thingProperties);
    my $fields = $db->buildArrayRefOfHashRefs('select * from Thingy_fields where assetId=? and thingId=?'
            ,[$self->getId,$oldThingId]);
    foreach my $field (@$fields) {
        # set thingId to newly created thing's id.
        $field->{thingId} = $newThingId;
        $self->addField($field,0);
    }

    return $newThingId;

}


#-------------------------------------------------------------------

=head2 deleteField ( fieldId , thingId )

Deletes a field from Collateral and drops the fields column in the thingy table.

=head3 fieldId

The id of the field that should be deleted.

=head3 thingId

The id of the thing to which the field to be deleted belongs.

=head3 keepSequenceNumbers

Boolean indicating that the sequence numbers should not be changed. This is used by importAssetCollateralData.

=cut

sub deleteField {

    my $self = shift;
    my $fieldId = shift;
    my $thingId = shift;
    my $keepSequenceNumbers = shift;
    my $db = $self->session->db;
    my $error = $self->session->errorHandler;
    my $deletedSequenceNumber;

    if ($keepSequenceNumbers ne "1"){
        ($deletedSequenceNumber) = $db->quickArray("select sequenceNumber from Thingy_fields where fieldId = ?"
            ,[$fieldId]);
    }
    $self->deleteCollateral("Thingy_fields","fieldId",$fieldId);
    if ($keepSequenceNumbers ne "1"){
       $db->write("update Thingy_fields set sequenceNumber = sequenceNumber -1 where sequenceNumber > ?"
            ,[$deletedSequenceNumber]);
    }

    my ($columnExists) = $db->quickArray("show columns from ".$db->dbh->quote_identifier("Thingy_".$thingId)
        ." like ".$db->quote("field_".$fieldId));
    if ($columnExists){
        $db->write("ALTER TABLE ".$db->dbh->quote_identifier("Thingy_".$thingId)." DROP "
            .$db->dbh->quote_identifier("field_".$fieldId));
    }
    $error->info("Deleted field: $fieldId in thing: $thingId.");
    return undef;
}

#-------------------------------------------------------------------

=head2 copyThingData ( )

Copies data in a Thing.

=head3 thingId

The id of the Thing that should be copied.

=head3 thingDataId

The id of row of data that should be copied.

=cut

sub copyThingData {
    my $self        = shift;
    my $thingId     = shift;
    my $thingDataId = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    return undef unless $self->canEditThingData($thingId, $thingDataId);

    my $origCollateral = $self->getCollateral("Thingy_".$thingId, "thingDataId", $thingDataId);
    $origCollateral->{thingDataId} = "new";
    ##Get all fields
    my $fields = $db->buildArrayRefOfHashRefs('select * from Thingy_fields where assetId=? and thingId=?'
            ,[$self->getId,$thingId]);
    my @storage_field_ids = ();
    ##Check to see if any of them are File or Image
    foreach my $field (@{ $fields }) {
        if ($field->{fieldType} eq 'File' or $field->{fieldType} eq 'Image') {
            push @storage_field_ids, $field->{fieldId};
        }
    }
    ##Instance the storage object and duplicate it
    foreach my $fieldId (@storage_field_ids) {
        my $currentId = $origCollateral->{"field_". $fieldId};
        my $storage   = WebGUI::Storage->get($session, $currentId);
        my $new_store = $storage->copy;
        ##Update the copy with the new storageId.
        $origCollateral->{"field_". $fieldId} = $new_store->getId;
    }
    ##Update the copy
    $self->setCollateral("Thingy_".$thingId, "thingDataId", $origCollateral, 0, 0);

    return undef;
}


#-------------------------------------------------------------------

=head2 deleteThingData ( )

Deletes data in a Thing.

=head3 thingId

The id of the Thing that should be deleted.

=head3 thingDataId

The id of row of data that should be deleted.

=cut

sub deleteThingData {

    my $self        = shift;
    my $thingId     = shift;
    my $thingDataId = shift;
    my $session     = $self->session;
    my $db          = $session->db;

    return undef unless $self->canEditThingData($thingId, $thingDataId);

    my ($onDeleteWorkflowId) = $db->quickArray("select onDeleteWorkflowId from Thingy_things where thingId=?"
            ,[$thingId]);
    if ($onDeleteWorkflowId){
        $self->triggerWorkflow($onDeleteWorkflowId, $thingId,$thingDataId);
    }

    my $origCollateral = $self->getCollateral("Thingy_".$thingId, "thingDataId", $thingDataId);
    $self->deleteCollateral("Thingy_".$thingId,"thingDataId",$thingDataId);
    my $fields = $db->buildArrayRefOfHashRefs('select * from Thingy_fields where assetId=? and thingId=?'
            ,[$self->getId,$thingId]);
    my @storage_field_ids = ();
    ##Check to see if any of them are File or Image
    foreach my $field (@{ $fields }) {
        if ($field->{fieldType} eq 'File' or $field->{fieldType} eq 'Image') {
            push @storage_field_ids, $field->{fieldId};
        }
    }
    foreach my $fieldId (@storage_field_ids) {
        my $currentId = $origCollateral->{"field_". $fieldId};
        my $storage   = WebGUI::Storage->get($session, $currentId);
        $storage->delete;
    }

    return undef;
}

#-------------------------------------------------------------------

=head2 deleteThing ( thingId )

Deletes a Thing and its fields from Collateral and drops the things table.

=head3 thingId

The id of the Thing that should be deleted.

=cut

sub deleteThing {

    my $self = shift;
    my $thingId = shift;
    my $session = $self->session;
    my $error = $session->errorHandler;

    $self->deleteCollateral("Thingy_things","thingId",$thingId);
    $self->deleteCollateral("Thingy_fields","thingId",$thingId);
    $session->db->write("drop table if exists ".$session->db->dbh->quote_identifier("Thingy_".$thingId));
    
    $error->info("Deleted thing: $thingId.");
    return undef;
}

#-------------------------------------------------------------------

=head2 editThingDataSave ( )

Saves a row of thing data and triggers the appropriate workflow triggers.

=head3 thingId

The id of the Thing which this row of data is an instance of.

=head3 thingDataId

The id of the row of data. This can be an existing id or 'new'.

=head3 thingData

An optional hashref containing the new data. This will override values passed in by a form post. 
Use this hashref for testing purposes.

=cut

sub editThingDataSave {

    my $self = shift;
    my $thingId = shift;
    my $thingDataId = shift;
    my $thingData = shift;
    my $session = $self->session;
    my (%thingData,$fields,@errors,$hadErrors,$newThingDataId);
    my $i18n = WebGUI::International->new($session, 'Asset_Thingy');
    
    if ($thingDataId eq "new"){
        $thingData{dateCreated} = time();
        $thingData{createdById} = $session->user->userId;
        $thingData{ipAddress} = $session->env->getIp;
    }
    else {
        %thingData = $session->db->quickHash("select * from ".$session->db->dbh->quote_identifier("Thingy_".$thingId)
            ." where thingDataId = ?",[$thingDataId]);
    }

    %thingData = ( %thingData, 
        thingDataId=>$thingDataId,
        updatedById=>$session->user->userId,
        updatedByName=>$session->user->username,
        lastUpDated=>time(),
    );
    
    $fields = $session->db->read('select * from Thingy_fields where assetId = ? and thingId = ? order by sequenceNumber',
        [$self->get("assetId"),$thingId]);
    while (my $field = $fields->hashRef) {
        my $fieldName = 'field_'.$field->{fieldId};
        my $fieldValue;
        if ($field->{status} eq "required" || $field->{status} eq "editable"){
            my $fieldType = $field->{fieldType};
            $fieldType = "" if ($fieldType =~ m/^otherThing/x);
            # Modify the defaultValue for certain field types. For most types we want to use
            # the default in the database, for these we want the last known value for this thingData
            if ( $fieldType eq "File" || $fieldType eq "Image" ) {
                $field->{ defaultValue } = $thingData{ "field_" . $field->{ fieldId } };
            }
            $fieldValue = $thingData->{$fieldName} || $session->form->process($fieldName,$fieldType,$field->{defaultValue},$field);
        }
        if ($field->{status} eq "required" && ($fieldValue =~ /^\s$/x || $fieldValue eq "" || !(defined $fieldValue))) {
            push (@errors,{
                "error_message"=>$field->{label}." ".$i18n->get('is required error').".",
                });
            #$hadErrors = 1;
        }
        if ($field->{status} eq "hidden") {
            $fieldValue = $field->{defaultValue};
            WebGUI::Macro::process($self->session,\$fieldValue);
        }
        if ($field->{status} eq "visible") {
            $fieldValue = $field->{defaultValue};
            #WebGUI::Macro::process($self->session,\$fieldValue);
        }
        $thingData{$fieldName} = $fieldValue;
    }

    $newThingDataId = $self->setCollateral("Thingy_".$thingId,"thingDataId",\%thingData,0,0);

    # trigger workflow
    if($thingDataId eq "new"){
        my ($onAddWorkflowId) = $session->db->quickArray("select onAddWorkflowId from Thingy_things where thingId=?"
            ,[$thingId]);
        if ($onAddWorkflowId){
            $self->triggerWorkflow($onAddWorkflowId,$thingId,$newThingDataId);
        }
    }else{
        my ($onEditWorkflowId) = $session->db->quickArray("select onEditWorkflowId from Thingy_things where thingId=?"
            ,[$thingId]);
        if ($onEditWorkflowId){
            $self->triggerWorkflow($onEditWorkflowId,$thingId,$newThingDataId);
        }
    }

    return($newThingDataId,\@errors);	
}

#-------------------------------------------------------------------

=head2 exportAssetData ( )

See WebGUI::AssetPackage::exportAssetData() for details.

=cut

sub exportAssetData {
    my $self = shift;
    my $data = $self->SUPER::exportAssetData;
    my $db = $self->session->db;
    my $assetId = $self->get("assetId");

    $data->{things} = $db->buildArrayRefOfHashRefs('select * from Thingy_things where assetId = ?',[$assetId]);
    $data->{fields} = $db->buildArrayRefOfHashRefs('select * from Thingy_fields where assetId = ?',[$assetId]);

    return $data;
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

=head2 getEditFieldForm ( )

returns the form that will be used in the edit dialog for Thingy_fields.

=cut

sub getEditFieldForm {

    my $self = shift;
    my $session = $self->session;
    my $field = shift;
    my (%fieldStatus, $f, %fieldTypes, $things);
    my $fieldId = $field->{fieldId} || "new";
    my $i18n = WebGUI::International->new($session, 'Asset_Thingy');
    my $defaultValue;
    tie %fieldStatus, 'Tie::IxHash';
    tie %fieldTypes, 'Tie::IxHash';
    
    %fieldStatus = (
        "hidden" => $i18n->get('fieldstatus hidden label'),
        "visible" => $i18n->get('fieldstatus visible label'),
        "editable" => $i18n->get('fieldstatus editable label'),
        "required" => $i18n->get('fieldstatus required label'),
    );
    
    %fieldTypes = %{WebGUI::Form::FieldType->new($session)->getTypes}; 
    %fieldTypes = WebGUI::Utility::sortHash(%fieldTypes);
    
    $things = $self->session->db->read('select thingId, Thingy_things.label, count(*) from Thingy_things '
        .'left join Thingy_fields using(thingId) where Thingy_things.assetId = ? and fieldId != "" '
        .'group by thingId',[$self->getId]);
    while (my $thing = $things->hashRef) {
        my $fieldType = "otherThing_".$thing->{thingId};
        $fieldTypes{$fieldType} = $thing->{label};
    }
    
    my $dialogPrefix;
    if ($field->{oldFieldId}){
        $dialogPrefix = "edit_".$field->{oldFieldId}."_Dialog_copy";
    }
    elsif($fieldId eq "new"){
        $dialogPrefix = "addDialog";
    }
    else{
        $dialogPrefix = "edit_".$fieldId."_Dialog";
    }
    
    $f = WebGUI::HTMLForm->new($self->session,{
            action=>$self->getUrl,
            tableExtras=>' cellpadding="0" cellspacing="0"'
            });
    $f->hidden(
        -name => "fieldId",
        -value => $fieldId,
    );
    $f->hidden(
        -name => "thingId",
        -value => $field->{thingId},
    );
    $f->hidden(
        -name => "func",
        -value => "editFieldSave"
    );
    $f->text(
        -name=>"label",
        -label=>$i18n->get('field label label'),
        -hoverHelp=>$i18n->get('field label description'),
        -value=>$field->{label}
    );
    $f->selectBox(
        -name=>"fieldType",
        -label=>$i18n->get('field type label'),
        -hoverHelp=>$i18n->get('field type description'),
        -value=>$field->{fieldType} || "Text",
        -options=>\%fieldTypes,
        -id=>$dialogPrefix."_fieldType_formId",
        );
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_fieldInThing_module"));

    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_defaultFieldInThing_module"));
    unless ($field->{fieldType} =~ m/^otherThing/x){
        $defaultValue = $field->{defaultValue};
    }
    my $defaultValueForm = WebGUI::Form::Textarea($self->session, {
                name=>"defaultValue",
                value=>$defaultValue,
                subtext=>'<br />'.$i18n->get('default value subtext'),
                width=>200,
                height=>40,
                resizable=>0,
            });
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_defaultValue_module",$defaultValueForm,
        $i18n->get('default value label'),$i18n->get('default value description')));
   
    $f->text(
        -name=>"pretext",
        -value=>$field->{pretext},
        -label=>$i18n->get('pretext label'),
        -hoverHelp=>$i18n->get('pretext description'),
        );
    $f->text(
        -name=>"subtext",
        -value=>$field->{subtext},
        -label=>$i18n->get('subtext label'),
        -hoverHelp=>$i18n->get('subtext description'),
        );
    $f->selectBox(
        -name=>"status",
        -options=>\%fieldStatus,
        -label=>$i18n->get('field status label'),
        -hoverHelp=>$i18n->get('field status description'),
        -value=> [ $field->{status} || "editable" ] ,
        ); 
    
    my $widthForm = WebGUI::Form::Integer($self->session, {
            name=>"width",
            value=>($field->{width} || 250),
            size=>10,
        });
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_width_module",$widthForm,$i18n->get('width label'),
        $i18n->get('width description')));

    my $sizeForm = WebGUI::Form::Integer($self->session, {
            name=>"size",
            value=>($field->{size} || 25),
            size=>10,
        });
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_size_module",$sizeForm,$i18n->get('size label'),
        $i18n->get('size description'),));

    my $heightForm = WebGUI::Form::Integer($self->session, {
            name=>"height",
            value=>$field->{height} || 40,
            label=>$i18n->get('height label'),
            size=>10,
        });
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_height_module",$heightForm,$i18n->get('height label'),
        $i18n->get('height description')));

    my $verticalForm = WebGUI::Form::YesNo($self->session, {
            name=>"vertical",
            value=>$field->{vertical},
            label=>$i18n->get('vertical label'),
        });
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_vertical_module",$verticalForm,$i18n->get('vertical label'),
        $i18n->get('vertical description')));
    
    my $valuesForm = WebGUI::Form::Textarea($self->session, { 
            name=>"possibleValues",
            value=>$field->{possibleValues},
            width=>200,
            height=>60,
            resizable=>0,
        });
    $f->raw($self->getHtmlWithModuleWrapper($dialogPrefix."_values_module",$valuesForm,$i18n->get('possible values label'),
        $i18n->get('possible values description')));
    $f->text(
        -name=>"extras",
        -value=>$field->{extras},
        -label=>$i18n->get('extras label'),
        -hoverHelp=>$i18n->get('extras description'),
        );

    #unless ($dialogPrefix eq "addDialog") {
    #    $f->raw('<script type="text/javascript">initHoverHelp("'.$dialogPrefix.'");</script>');
    #}
    return $f;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the tabform object that will be used in generating the edit page for Thingy's.
Adds the defaultThingId selectBox to the tabform object, because the options for this selectBox depends on already
existing Things. The rest of the form is auto-generated.

=cut

sub getEditForm {

    my $self = shift;
    my $i18n = WebGUI::International->new($self->session, 'Asset_Thingy');

    my $tabform = $self->SUPER::getEditForm();

    my $things = $self->session->db->buildHashRef('select thingId, label from Thingy_things where assetId = ?',[$self->get("assetId")]);

    if (scalar(keys(%{$things}))) {
    	$tabform->getTab("display")->selectBox(
	    	-name=>"defaultThingId",
            -value=>$self->get("defaultThingId"),
    		-label=>$i18n->get("default thing label"),
            -options=>$things,
    	);
    }

	
	return $tabform;
}

#-------------------------------------------------------------------

=head2 getFieldValue ( value, field )

Processes the field value for date(Time) fields and Other Thing fields.

=head3 value

The value as stored in the database.

=head3 field

A reference to a hash containing the fields properties.

=cut

sub getFieldValue {

    my $self = shift;
    my $value = shift;
    my $field = shift;
    my $dateFormat = shift || "%z";
    my $dateTimeFormat = shift;
    my $processedValue = $value;    
    my $dbh = $self->session->db->dbh;

    if (lc $field->{fieldType} eq "date"){
        $processedValue = $self->session->datetime->epochToHuman($value,$dateFormat);
    }
    elsif (lc $field->{fieldType} eq "datetime"){
        $processedValue = $self->session->datetime->epochToHuman($value,$dateTimeFormat);
    }
    # TODO: The otherThing field type is probably also handled by getFormPlugin, so the elsif below can probably be
    # safely removed. However, this requires more testing than I can provide right now, so for now this stays the
    # way it was.
    elsif ($field->{fieldType} =~ m/^otherThing/x) {
        my $otherThingId = $field->{fieldType};
        $otherThingId =~ s/^otherThing_//x;
        my $tableName = 'Thingy_'.$otherThingId;
        my $fieldName = 'field_'.$field->{fieldInOtherThingId};
        my $badThing  = $self->badOtherThing($tableName, $fieldName);
        if (! $badThing){
            ($processedValue) = $self->session->db->quickArray('select '
                .$dbh->quote_identifier($fieldName)
                .' from '.$dbh->quote_identifier($tableName)
                .' where thingDataId = ?',[$value]);
        }
    }
    else {
        $field->{ value          } = $value;
        $field->{ defaultValue   } = $value;
        my $plugin      = $self->getFormPlugin( $field );
        $processedValue = $plugin->getValueAsHtml;
    }

    return $processedValue;
}

#-------------------------------------------------------------------

=head2 getFormElement ( data )

Returns the form element tied to this field.

=head3 data

A hashref containing the properties of this field.

=cut

sub getFormElement {
    my $self = shift;

    return $self->getFormPlugin( @_, 1 )->toHtml;
}

#-------------------------------------------------------------------

=head2 getFormPlugin ( properties, [ useFormPostData ] )

Returns an instanciated WebGUI::Form::* plugin.

=head3 properties

The properties to configure the form plugin with. The fieldType key should contain the type of the form plugin.

=head3 useFormPostData

If set to true, the value of the form element will be set to the data posted by it if available.

=cut

sub getFormPlugin {
    my $self            = shift;
    my $data            = shift;
    my $useFormPostData = shift;

    my %param;
    my $session = $self->session;
    my $db      = $session->db;
    my $dbh     = $db->dbh;
    my $i18n    = WebGUI::International->new($session,"Asset_Thingy");

    $param{name} = "field_".$data->{fieldId};
    my $name     = $param{name};
    $name =~ s/\^.*?\;//xgs ; # remove macro's from user input
    $param{value}     = $data->{value} || $data->{defaultValue};
    $param{size}      = $data->{size};
    $param{height}    = $data->{height};
    $param{width}     = $data->{width};
    $param{extras}    = $data->{extras};
    $param{vertical}  = $data->{vertical};
    $param{fieldType} = $data->{fieldType};

    if ($data->{fieldType} eq "Checkbox") {
        $param{value} = 1;
        if ($data->{value} == 1){
            $param{checked} = 1;
        }
    }

    if ( WebGUI::Utility::isIn( $data->{fieldType}, qw(SelectList CheckList SelectBox Attachments) ) ) {
        my @values;
        if ( $useFormPostData && $session->form->param($name) ) {
            $param{ value } = [ $session->form->process( $name, $data->{fieldType} ) ];
        }
        elsif ( $data->{ value } ) {
            foreach (split(/\n/x, $data->{value})) {
                s/\s+$//x; # remove trailing spaces
                push(@values, $_);
            }
            $param{value} = \@values;
        }
    }
    elsif ( $useFormPostData && $session->form->param($name) ) {
        $param{value} = $session->form->process( $name, $data->{fieldType} );
    }

    my $class = 'WebGUI::Form::'. ucfirst $data->{fieldType};
    eval { WebGUI::Pluggable::load($class) };
    if ($class->isa('WebGUI::Form::List')) {
        delete $param{size};
        my $values = WebGUI::Operation::Shared::secureEval($session,$data->{possibleValues});
        $param{options} = $values;
    }

    if ($data->{fieldType} eq "YesNo") {
        if ($data->{defaultValue} =~ /yes/xi) {
            $param{value} = 1;
        }
        elsif ($data->{defaultValue} =~ /no/xi) {
            $param{value} = 0;
        }
    }

    if ($data->{fieldType} =~ m/^otherThing/x){
        my $otherThingId  =  $data->{fieldType}; 
        $otherThingId     =~ s/^otherThing_(.*)/$1/x;
        $param{fieldType} =  "SelectList"; 
        $class      = 'WebGUI::Form::'. $param{fieldType};
        my $options = ();

        my $tableName    = 'Thingy_'.$otherThingId;
        my $fieldName    = 'field_'.$data->{fieldInOtherThingId};
        my $errorMessage = $self->badOtherThing($tableName, $fieldName);
        return $errorMessage if $errorMessage;

        my $sth = $session->db->read('select thingDataId, '
            .$dbh->quote_identifier($fieldName)
            .' from '.$dbh->quote_identifier($tableName));
    
        while (my $result = $sth->hashRef){
            if ($self->canViewThingData($otherThingId,$result->{thingDataId})){
                $options->{$result->{thingDataId}} = $result->{$fieldName}
            }
        }
 
        my $value = $data->{value} || $data->{defaultValue};
        ($param{value}) = $db->quickArray('select '
            .$dbh->quote_identifier($fieldName)
            .' from '.$dbh->quote_identifier($tableName)
            .' where thingDataId = ?',[$value]);
        $param{size}     = 1;
        $param{multiple} = 0;
        $param{options}  = $options;
        $param{value}    = $data->{value} || $data->{defaultValue};
    }

    my $formElement =  eval { WebGUI::Pluggable::instanciate($class, "new", [$session, \%param ])};
    return $formElement;
}

#-------------------------------------------------------------------

=head2 getHtmlWithModuleWrapper  ( id , formElement, formDescription  )

Returns a table row containing a form element in a yui module.

=head3 id

An id for the module div.

=head3 formElement

The from element rendered as html.

=head3 formDescription

The description of the from element.

=cut

sub getHtmlWithModuleWrapper {

    my $self = shift;
    my $id = shift;
    my $formElement = shift;
    my $formDescription = shift;
    my $hoverHelp = shift;

    $hoverHelp &&= '<div class="wg-hoverhelp">' . $hoverHelp . '</div>';
    my $html =  "\n<tr><td colspan='2'>\n";
    $html .=    "\t<div id='".$id."'>\n";
    $html .=    "\t<div class='bd' style='padding:0px;'>\n";
    $html .=    "\t<table cellpadding='0' cellspacing='0' style='width: 100%;'>\n";
    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>";
    $html .=    $formDescription.$hoverHelp."</td>";
    $html .=    "<td valign='top' class='tableData' style='padding-left:4px'>";
    $html .=    $formElement."</td>";
    $html .=    "\t\n</tr>\n";
    $html .=    "\t</table>";
    $html .=    "\t\n</div>\t\n</div>\n";
    $html .=    "</td></tr>";

    return $html;

}

#-------------------------------------------------------------------

=head2 getThing  ( thingId )

Returns a hash reference of the properties of a thing.

=head3 thingId

The unique id of a thing.

=cut

sub getThing {
    my ($self, $thingId) = @_;
    return $self->session->db->quickHashRef("select * from Thingy_things where thingId=?",[$thingId]);
}

#-------------------------------------------------------------------

=head2 getViewThingVars  (  )

Returns the field values of a thing instance and the title for its view screen in a tmpl var hashref. 
If a tmpl var hashref is supplied tmpl_var's will be appended to that.

=cut

sub getViewThingVars {
    my ($self, $thingId, $thingDataId,$var) = @_;
    my $db = $self->session->db;
    my (@field_loop, @viewScreenTitleFields, $viewScreenTitle);

    return undef unless ($thingId && $thingDataId);
    
    my %thingData = $db->quickHash("select * from ".$db->dbh->quote_identifier("Thingy_".$thingId)
        ." where thingDataId = ?",[$thingDataId]);

    if (%thingData) {
        my $fields = $db->read('select * from Thingy_fields where assetId = ? and thingId = ? order by sequenceNumber',
            [$self->get('assetId'),$thingId]);
        while (my %field = $fields->hash) {
            next unless ($field{display} eq '1');
            my $hidden = ($field{status} eq "hidden" && !$self->session->var->isAdminOn);

            my $originalValue = $thingData{"field_".$field{fieldId}};
            my $value = $self->getFieldValue($originalValue,\%field);

            my $otherThingUrl;
            if ($field{fieldType} =~ m/^otherThing/x) {
                my $otherThingId = $field{fieldType};
                $otherThingId =~ s/^otherThing_//x;
                if($self->canViewThing($otherThingId)){
                    $otherThingUrl = $self->session->url->append(
                        $self->getUrl,
                        "func=viewThingData;thingId=$otherThingId;thingDataId=$originalValue"
                    );
                }
            }

            my %fieldProperties = (
                "id" => $field{fieldId},
                "name" => "field_".$field{fieldId},
                "type" => $field{fieldType},
                "value" => $value,
                "label" => $field{label},
                "isHidden" => $hidden,
                "url" => $otherThingUrl,
                "isVisible" => ($field{status} eq "visible" && !$hidden),
                "isRequired" => ($field{status} eq "required" && !$hidden),
                "pretext" => $field{pretext},
                "subtext" => $field{subtext},
            );
            push(@viewScreenTitleFields,$value) if ($field{viewScreenTitle});
            push(@field_loop, { map {("field_".$_ => $fieldProperties{$_})} keys(%fieldProperties) });
        }
        $var->{viewScreenTitle} = join(" ",@viewScreenTitleFields);
        $var->{field_loop} = \@field_loop;
        return $var;
    }
    else{
        return undef;
    }

}

#-------------------------------------------------------------------

=head2 getThings  (  )

Returns a result set with all the things in the database.

=cut

sub getThings {
    my ($self) = @_;
    return $self->session->db->read("select * from Thingy_things where assetId=?",[$self->getId]);
}


#-------------------------------------------------------------------

=head2 hasEnteredMaxPerUser

Check whether the current user has entered the maximum number of entries allowed for this thing.

=head3 thingId

The unique id of a thing.

=cut

sub hasEnteredMaxPerUser {
    my ($self,$thingId) = @_;
    my $session         = $self->session;
    my $db              = $session->db;

    my $maxEntriesPerUser = $db->quickScalar("select maxEntriesPerUser from Thingy_things where thingId=?",[$thingId]);

    return 0 unless $maxEntriesPerUser;
     
    my $numberOfEntries = $session->db->quickScalar("select count(*) "
        ."from ".$session->db->dbh->quote_identifier("Thingy_".$thingId)." where createdById=?",[$session->user->userId]);   

    if($numberOfEntries < $maxEntriesPerUser){
        return 0;
    }
    else{
        return 1;
    }
}

#-------------------------------------------------------------------

=head2 hasPrivileges  ( groupId )

Checks if the current user has a certain privilege on a Thing.
A user that can edit a Thingy asset has all rights on every Thing by definition.

=head3 groupId

The id of the group that has the privileges that are to be checked.

=cut

sub hasPrivileges {

    my $self = shift;
    my $privilegedGroupId = shift;
    return ($self->session->user->isInGroup($privilegedGroupId) || $self->canEdit);

}

#-------------------------------------------------------------------

=head2 importAssetCollateralData ( data )

Imports Things and fields that where exported with a Thingy asset.

=head3 data

Hashref containing the Thingy's exported data.

=cut

sub importAssetCollateralData {
    
    my $self = shift;
    my $session = $self->session;
    my $error = $session->errorHandler;
    my $data = shift;
    my $id = $data->{properties}{assetId};
    my $class = $data->{properties}{className};
    my $version = $data->{properties}{revisionDate};
    my $assetExists = WebGUI::Asset->assetExists($self->session, $id, $class, $version);
    
    $error->info("Importing Things for Thingy ".$data->{properties}{title});
    my @importThings;
    foreach my $thing (@{$data->{things}}) {
        push(@importThings,$thing->{thingId});
        my ($thingIdExists) = $session->db->quickArray("select thingId from Thingy_things where thingId = ?",
            [$thing->{thingId}]);
        if ($assetExists && $thingIdExists){
            # update existing thing
            $error->info("Updating Thing, label: ".$thing->{label}.", id: ".$thing->{thingId});
            $self->setCollateral("Thingy_things","thingId",$thing,0,0);
        }
        else{
            # add new thing
            $self->addThing($thing,1);
        }
    }
    # delete deleted things
    my $thingsInDatabase = $self->getThings;
    while (my $thingInDataBase = $thingsInDatabase->hashRef) {
        if (!WebGUI::Utility::isIn($thingInDataBase->{thingId},@importThings)){
        # delete thing
            $self->deleteThing($thingInDataBase->{thingId});
        }
    }

    my @importFields;
    foreach my $field (@{$data->{fields}}) {
        push(@importFields,$field->{fieldId});
        my $dbDataType = $self->_getDbDataType($field->{fieldType});
        my ($fieldIdExists) = $session->db->quickArray("select fieldId from Thingy_fields where fieldId = ? and thingId = ? ",[$field->{fieldId},$field->{thingId}]);
        if ($assetExists && $fieldIdExists){
            # update existing field
            $error->info("Updating Field, label: ".$field->{label}.", id: ".$field->{fieldId}.",seq :"
                .$field->{sequenceNumber});
            $self->_updateFieldType($field->{fieldType},$field->{fieldId},$field->{thingId},$field->{assetId},$dbDataType);
            $self->setCollateral("Thingy_fields","fieldId",$field,1,0,"","",1);
        }
        else{
            # Add field as Collateral, retain fieldId.
            $self->addField($field,1,$dbDataType);
        }
    }
    # delete deleted fields
    my $fieldsInDatabase = $session->db->read('select fieldId, thingId from Thingy_fields where assetId = ?',
        [$self->get("assetId")]);
    while (my $fieldInDataBase = $fieldsInDatabase->hashRef) {
        if (!WebGUI::Utility::isIn($fieldInDataBase->{fieldId},@importFields)){
            # delete field
            $self->deleteField($fieldInDataBase->{fieldId},$fieldInDataBase->{thingId},"1");        
        }
    }

    return undef;
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
    return undef;
}


#-------------------------------------------------------------------

=head2 purge ( )

Removes collateral data and drops tables associated with a Thingy asset when the system
purges it's data.   

=cut

sub purge {
	my $self = shift;
    my $session = $self->session;
	my $db = $self->session->db;
    my @thingIds = $db->buildArray("select thingId from Thingy_things where assetId = ?", [$self->getId]);
    foreach my $thingId (@thingIds){
        $db->write("drop table if exists ".$db->dbh->quote_identifier("Thingy_".$thingId));        
    }
    $db->write("delete from Thingy_things where assetId = ?",[$self->getId]);
    $db->write("delete from Thingy_fields where assetId = ?",[$self->getId]);

    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 triggerWorkflow ( workflowId, thingId, thingDataId )

Runs the specified workflow when this Thingy changes.

=head3 workflowId

The id of the workflow that has to be triggered.

=cut

sub triggerWorkflow {

    my $self = shift;
    my $workflowId = shift;
    my $thingId = shift ;
    my $thingDataId = shift ;
    my $workflowInstance = WebGUI::Workflow::Instance->create($self->session, {
        workflowId=>$workflowId,
        className=>"WebGUI::Asset::Wobject::Thingy",
        methodName=>"new",
        parameters=>$self->getId
        });
    $workflowInstance->setScratch("thingId", $thingId);
    $workflowInstance->setScratch("thingDataId",$thingDataId);
    $workflowInstance->start;
    return undef;
}

#-------------------------------------------------------------------

=head2 _updateFieldType ( fieldType, fieldId, thingId, assetId, dbDataType )

Alters a column for a field if the field's fieldType has changed.

=head3 fieldType

The new fieldType for the field that has to be changed.

=head3 fieldId

The id of the field of which should be changed.

=head3 thingId

The id of the Thing to which the field belongs.

=head3 assetId

The id of the Thingy asset to which the field belongs.

=head3 dbDataType

The data type that the field should have in the database.

=cut

sub _updateFieldType {

        my $self = shift;
        my $session = $self->session;
        my $error = $session->errorHandler;
        
        my $newFieldType = shift;
        my $fieldId = shift;
        my $thingId = shift;
        my $assetId = shift;
        my $dbDataType = shift;
        my $db = $session->db;

        my ($fieldType) = $self->session->db->quickArray("select fieldType from Thingy_fields where fieldId = "
        .$db->quote($fieldId)." and  assetId = ".$db->quote($assetId)
        ." and thingId = ".$db->quote($thingId));

        if($newFieldType ne $fieldType){
            my $thingyTableName = "Thingy_".$thingId;
            my $columnName = "field_".$fieldId;
            $error->info("changing column: $columnName, table: $thingyTableName");
            $self->session->db->write(
                "ALTER TABLE ".$db->dbh->quote_identifier($thingyTableName).
                " CHANGE ".$db->dbh->quote_identifier($columnName)." "
                .$db->dbh->quote_identifier($columnName)." ".$dbDataType
            );
        }
    return undef;
}
#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
	my $self = shift;
    my $session = $self->session;
    my $db = $self->session->db;
    my $i18n = WebGUI::International->new($self->session,"Asset_Thingy");
    my ($defaultThingId,$defaultView);

	my $var = $self->get;
    my $url = $self->getUrl;
	
    $var->{canEditThings} = $self->canEdit;
    $var->{"addThing_url"} = $session->url->append($url, 'func=editThing;thingId=new');
    $var->{"manage_url"} = $session->url->append($url, 'func=manage');

    #Get this Thingy's default thing
    $defaultThingId = $self->get("defaultThingId");
    $self->appendThingsVars($var, $defaultThingId);

    if ($defaultThingId ne ""){
        # get default view
        ($defaultView) = $db->quickArray("select defaultView from Thingy_things where thingId=?",[$defaultThingId]);
        my $thingProperties = $self->getThing($defaultThingId);
        if ($defaultView eq "searchThing"){
            return $i18n->get("no permission to search") if( ! $self->canSearch($defaultThingId, $thingProperties));
            return $self->search($defaultThingId,$thingProperties) 
        }
        elsif ($defaultView eq "addThing"){
            return $i18n->get("no permission to edit") if( ! $self->canEditThingData($defaultThingId, "new", $thingProperties));
            return $self->editThingData($defaultThingId,"new", $thingProperties);
        }
        else{
            return $self->processTemplate($var, undef, $self->{_viewTemplate});
        }
    }
    else{
	    return $self->processTemplate($var, undef, $self->{_viewTemplate});
    }
}
#-------------------------------------------------------------------

=head2 www_deleteFieldConfirm ( )

Deletes a field definition. Drops the column of a Thing's table that holds the data of this field.

=cut

sub www_deleteFieldConfirm {
    my $self = shift;
    my $session = $self->session;
    my $fieldId = $session->form->process("fieldId");
    my $thingId = $session->form->process("thingId");
    return $session->privilege->insufficient() unless $self->canEdit;

    $self->deleteField($fieldId,$thingId);

    return 1;
}

#-------------------------------------------------------------------

=head2 www_duplicateThing ( )

Duplicates a Thing.

=cut

sub www_duplicateThing {
    my $self = shift;
    my $session = $self->session;
    my $thingId = $session->form->process("thingId");
    return $session->privilege->insufficient() unless $self->canEdit;

    $self->duplicateThing($thingId);

    return $self->www_manage;
}

#-------------------------------------------------------------------

=head2 www_copyThingData( )

Copies data in a Thing.

=cut

sub www_copyThingData{

    my $self        = shift;
    my $thingId     = $self->session->form->process("thingId");
    my $thingDataId = $self->session->form->process('thingDataId');

    return $self->session->privilege->insufficient() unless $self->canEditThingData($thingId, $thingDataId);
    
    $self->copyThingData($thingId,$thingDataId);
    
    return $self->www_search;
}

#-------------------------------------------------------------------

=head2 www_deleteThingConfirm ( )

Deletes a Thing, including field definitions and instances of this Thing and drops the table that holds the
instances of this Thing.

=cut

sub www_deleteThingConfirm {
    my $self = shift;
    my $thingId = $self->session->form->process("thingId"); 
    return $self->session->privilege->insufficient() unless $self->canEdit;

    $self->deleteThing($thingId);
    
    return $self->www_manage;
}

#-------------------------------------------------------------------

=head2 www_deleteThingDataConfirm ( )

Deletes data in a Thing.

=cut

sub www_deleteThingDataConfirm {

    my $self        = shift;
    my $thingId     = $self->session->form->process("thingId");
    my $thingDataId = $self->session->form->process('thingDataId');

    return $self->session->privilege->insufficient() unless $self->canEditThingData($thingId, $thingDataId);

    $self->deleteThingData($thingId,$thingDataId);

    return $self->www_search;
}

#-------------------------------------------------------------------

=head2 www_deleteThingDataViaAjax ( )

Deletes data in a Thing.

=cut

sub www_deleteThingDataViaAjax {

    my $self 	= shift;
    my $session = $self->session;

    my $thingId     = $self->session->form->process("thingId");
    my $thingDataId = $self->session->form->process('thingDataId');

    $session->http->setMimeType("application/json");

    unless ($thingId && $thingDataId) {
        $session->http->setStatus("400", "Bad Request");
        return JSON->new->encode({message => "Can't get thing data without a thingId and a thingDataId."});
    }

    my $thingProperties = $self->getThing($thingId);
    if ($thingProperties->{thingId}){
        return $session->privilege->insufficient() unless $self->canEditThingData($thingId, $thingDataId
            ,$thingProperties);

        $self->deleteThingData($thingId,$thingDataId);

        $session->http->setMimeType("application/json");
        return JSON->new->encode({message => "Data with thingDataId $thingDataId was deleted."});
    }
    else {
        $session->http->setStatus("404", "Not Found");
        return JSON->new->encode({message => "The thingId you specified can not be found."});
    }
}

#-------------------------------------------------------------------

=head2 www_editThing ( )

Shows a form to edit or add a Thing. General properties of a Thing are stored when the form is submitted. 

When editing fields in a thing some changes are saved immediately. Because of this a table has to be created for a new Thing
before the form is submitted.

=cut

sub www_editThing {
    my $self = shift;
    my $warning = shift;
    my $session = $self->session;
    my ($tabForm, $output, %properties, $tab, %afterSave, %defaultView, $fields, %editViewOptions);
    my ($fieldsHTML, $fieldsViewScreen, $fieldsSearchScreen);
    my (@hasHeightWidth,@hasSize,@hasVertical,@hasValues);
    tie %afterSave, 'Tie::IxHash';
    tie %editViewOptions, 'Tie::IxHash';
    return $session->privilege->insufficient() unless $self->canEdit;
    my $i18n = WebGUI::International->new($session, "Asset_Thingy");

    my $thingId = $session->form->process("thingId");
    return $self->www_view unless ($thingId);

    if($thingId eq "new"){
        my $groupIdEdit = $self->get("groupIdEdit");
        %properties = (
            thingId=>$thingId,
            label=>$i18n->get('thing name label'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
            exportMetaData=>undef, 
            maxEntriesPerUser=>undef,
        );
        $thingId = $self->addThing(\%properties,0);
    }
    else{
        %properties = %{$self->getThing($thingId)};
    }

    $tabForm = WebGUI::TabForm->new($self->session, undef, undef, $self->getUrl('func=view'));
    $tabForm->hidden({
        name    => 'func',
        value   => 'editThingSave'
    });
    $tabForm->hidden({
        name    => 'thingId',
        value   => $thingId
    });
    
    $tabForm->addTab('fields', $i18n->get('fields tab label'));

    $self->session->style->setScript($self->session->url->extras('yui/build/utilities/utilities.js'), {type => 
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=> 
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/connection/connection-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('wobject/Thingy/thingy.js'), {type=>
    'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('wobject/Thingy/thingy.css'), {type
    =>'text/css', rel=>'stylesheet'});

    $tab = $tabForm->getTab('fields');
    foreach my $fieldType ( keys %{ WebGUI::Form::FieldType->new($session)->getTypes }) {
        my $form = eval { WebGUI::Pluggable::instanciate("WebGUI::Form::".$fieldType, "new", [$session]) };
        if ($@) {
            $session->errorHandler->error($@);
            next;
        }
        my $definition = $form->definition($session);
        if ($form->get("height")){
            push(@hasHeightWidth, $fieldType);
        }
        if ($form->get("size")){
            push(@hasSize, $fieldType);
        }
        if (defined $definition->[0]->{vertical}->{defaultValue}){
            push(@hasVertical, $fieldType);
        }
        if ($form->areOptionsSettable){
            push(@hasValues, $fieldType);
        }
    }
    $tab->raw("<script type='text/javascript'>\n");
    $tab->raw('var hasHeightWidth = {'.join(", ",map {'"'.$_.'": true'} @hasHeightWidth).'};');
    $tab->raw('var hasSize = {'.join(", ",map {'"'.$_.'": true'} @hasSize).'};');
    $tab->raw('var hasVertical = {'.join(", ",map {'"'.$_.'": true'} @hasVertical).'};');
    $tab->raw('var hasValues = {'.join(", ",map {'"'.$_.'": true'} @hasValues).'};');
    if ($session->form->process("thingId") eq 'new'){
        $tab->raw("var newThingId = '$thingId';\n");
        $tab->raw("YAHOO.util.Event.onDOMReady(setCancelButton);\n");
    }
    $tab->raw("</script>");

    $tab->text(
        -name   => 'label',
        -label  => $i18n->get('thing name label'),
        -hoverHelp  => $i18n->get('thing name description'),
        -value  => $properties{label},
        -maxlength => 64,
    );

    $fieldsHTML = "</tr>\n"
        ."</tbody></table>\n"
        ."<fieldset>\n"
        ."<legend>".$i18n->get('fields label')."</legend>\n"
        ."<table><tbody>\n"
        ."<tr>\n"
        ."  <td>\n"
        ."  <div id='user_actions'>"
        ."  <input id='showAddFormButton' value='".$i18n->get('add field label')."' type='button'>"
        ."  </div>\n"
        ."  </td>\n"
        ."</tr>\n"
        ."<tr id='fields_row'>\n"
        ."  <td valign='top' colspan='2'>\n"
        ."  <div class='workarea'>\n"
        ."  <ul id='ul1' class='draglist'>\n";
    
    $fieldsViewScreen = "</tbody></table>\n<fieldset>"
                        ."<legend>".$i18n->get('fields label')."</legend>"
                        ."<table><tbody id='view_fields_table'>\n"
                        ."<tr>\n"
                        ."  <td></td>\n"
                        ."  <td class='formDescription'>".$i18n->get('display label')."</td>"
                        ."  <td class='formDescription'>".$i18n->get('view screen title label')."</td>\n"
                        ."</tr>";

    $fieldsSearchScreen = "</tbody></table>\n<fieldset>\n"
                        ."<legend>".$i18n->get('fields label')."</legend>\n"
                        ."<table><tbody id='search_fields_table'>\n"
                        ."<tr>\n"
                        ."  <td></td>\n"
                        ."  <td class='formDescription'>".$i18n->get('display label')."</td>\n"
                        ."  <td class='formDescription'>".$i18n->get('search label')."</td>\n"
                        ."  <td class='formDescription'>".$i18n->get('sort by label')."</td>\n"
                        ."</tr>\n";
    
    $fields = $self->session->db->read('select * from Thingy_fields where assetId = '.$self->session->db->quote($self->get("assetId")).' and thingId = '.$self->session->db->quote($thingId).' order by sequenceNumber');
    while (my $field = $fields->hashRef) {
        my $formElement;
        if ($field->{fieldType} eq "File"){
            $formElement = "<input type='file' name='file'>";
        }
        if ($field->{fieldType} eq "Image"){
            $formElement = "<input type='file' name='image'>";
        }
        else{
            $formElement = $self->getFormElement($field);     
        }
        if ($field->{pretext}){
            $formElement = '<span class="formPretext">'.$field->{pretext}.'</span><br />'.$formElement;
        }
        if ($field->{subtext}){
            $formElement .= '<br /><span class="formSubtext">'.$field->{subtext}.'</span>';
        }

        $fieldsHTML .= "<li class='list1' id='$field->{fieldId}'>"
            ."\n<table>\n<tr>\n"
            ."  <td style='width:100px;' valign='top' class='formDescription'>".$field->{label}."</td>\n"
            ."  <td style='width:370px;'>".$formElement."</td>\n"
            ."  <td style='width:120px;' valign='top'> <input onClick=\"editListItem('".$self->session->url->page()
            ."?func=editField;fieldId=".$field->{fieldId}.";thingId=".$thingId."','".$field->{fieldId}."')\" value='Edit' type='button'>"
            ." <input onClick=\"editListItem('".$self->session->url->page()
            ."?func=editField;copy=1;fieldId=".$field->{fieldId}.";thingId=".$thingId."','".$field->{fieldId}
            ."','copy')\" value='Copy' type='button'>"
            ."<input onClick=\"deleteListItem('".$self->session->url->page()."','".$field->{fieldId}."','".$thingId."')\" " 
            ."value='".$i18n->get('Delete','Icon')."' type='button'></td>\n</tr>\n</table>\n</li>\n";

        $fieldsViewScreen .= "<tr id='view_tr_".$field->{fieldId}."'>"
            ."<td class='formDescription' style='width:180px;' id='view_label_".$field->{fieldId}."'>".$field->{label}
            ."</td><td valign='top' class='tableData'>";
        $fieldsViewScreen .= WebGUI::Form::checkbox($self->session, {                 
                checked => $field->{display},
                name  => "display_".$field->{fieldId},
                value => 1,
            });
        $fieldsViewScreen .= "</td>\n<td valign='top' class='tableData'>";
        $fieldsViewScreen .= WebGUI::Form::checkbox($self->session, {
                checked => $field->{viewScreenTitle},
                name  => "viewScreenTitle_".$field->{fieldId},
                value => 1,
            });
        $fieldsViewScreen .= "</td>\n</tr>\n</fieldset>";

        $fieldsSearchScreen .= "<tr id='search_tr_".$field->{fieldId}."'>\n"      
            ."<td class='formDescription' style='width:180px;' id='search_label_".$field->{fieldId}."'>".$field->{label}
            ."</td>\n<td valign='top' class='tableData'>";
        $fieldsSearchScreen .= WebGUI::Form::checkbox($self->session, {
                checked => $field->{displayInSearch},
                name  => "displayInSearch_".$field->{fieldId},
                value => 1,
            });
        $fieldsSearchScreen .= "</td>\n<td valign='top' class='tableData'>";
        $fieldsSearchScreen .= WebGUI::Form::checkbox($self->session, {
                checked => $field->{searchIn},
                name  => "searchIn_".$field->{fieldId},
                value => 1,
            });
        my $sortBy;
        $sortBy = 1 if ($properties{sortBy} eq $field->{fieldId});
        $fieldsSearchScreen .= "</td>\n<td valign='top' class='tableData'>";
        $fieldsSearchScreen .= WebGUI::Form::radio($self->session, {
                checked => $sortBy,
                name  => "sortBy",
                value => $field->{fieldId},
            });
        $fieldsSearchScreen .= "</td>\n</tr>\n</fieldset>";
    }

    $fieldsHTML .= "</ul>\n"
        ."</div>\n"
        ."</td>\n"
        ."</fieldset>\n";

    $tab->raw($fieldsHTML);

    $tabForm->addTab('edit', $i18n->get('edit screen tab label'));
    $tab = $tabForm->getTab('edit');

    $tab->text(
        -name   => 'editScreenTitle',
        -label  => $i18n->get('edit screen title label'),
        -hoverHelp  => $i18n->get('edit screen title description'),
        -value  => $properties{editScreenTitle},
        -maxlength => 64,
    );
    $tab->HTMLArea(
        -name   => 'editInstructions',
        -label  => $i18n->get('edit instructions label'),
        -hoverHelp  => $i18n->get('edit instructions description'),
        -value  => $properties{editInstructions},
        -maxlength => 64,
        -width => 300,
        -height => 200,
    );
    $tab->integer(
        -name=> "maxEntriesPerUser",
        -value=> $properties{maxEntriesPerUser},
        -hoverHelp=> $i18n->get('max entries per user description'),
        -label => $i18n->get('max entries per user label')
    );
    $tab->group(
        -name=> "groupIdAdd",
        -value=> $properties{groupIdAdd},
        -hoverHelp=> $i18n->get('who can add description'),
        -label => $i18n->get('who can add label')
    );

    # create the options hash for the 'Who can edit' and 'Who can view' selectBoxes.
    %editViewOptions = ('owner'=>$i18n->get('owner'),$session->db->buildHash(
        "select groupId,groupName from groups where showInForms=1 order by groupName"
    ));

    $tab->selectBox(
        -name=> "groupIdEdit",
        -value=> $properties{groupIdEdit},
        -hoverHelp=> $i18n->get('who can edit description'),
        -label => $i18n->get('who can edit label'),
        -options => \%editViewOptions,
    );
    $tab->text(
        -name   => 'saveButtonLabel',
        -label  => $i18n->get('save button label label'),
        -hoverHelp  => $i18n->get('save button label description'),
        -value  => $properties{saveButtonLabel} || $i18n->get('default save button label'),
        -maxlength => 64,
    );
    %afterSave = (
        "searchThisThing" => $i18n->get('search this thing label'),
        "viewLastEdited" => $i18n->get('view last edited label'),
        "addThing" => $i18n->get('add thing label'),
        "thingyDefault" => $i18n->get('view thingy default label'),
        );
    my $otherThings = $session->db->read("select thingId, label from Thingy_things where thingId != ? and assetId =?",
        [$thingId,$self->getId]);
    while (my $otherThing = $otherThings->hashRef) {
        $afterSave{'searchOther_'.$otherThing->{thingId}} = $i18n->get('search other thing label').$otherThing->{label};
        $afterSave{'addOther_'.$otherThing->{thingId}} = $i18n->get('add other thing label').$otherThing->{label};
    }

    $tab->selectBox(
        -name=>"afterSave",
        -options=>\%afterSave,
        -label=>$i18n->get('after save label'),
        -hoverHelp=>$i18n->get('after save description'),
        -value=>[ $properties{afterSave} || 'searchThisThing' ]
        );
    $tab->template(
        -name=>"editTemplateId",
        -value=>$properties{editTemplateId},
        -namespace=>"Thingy/EditThing",
        -label=>$i18n->get('edit template label'),
        -hoverHelp=>$i18n->get('edit template description'),
        );

    
    $tab->workflow(
        -name=>"onAddWorkflowId",
        -value=>$properties{onAddWorkflowId} || "",
        -type=>"WebGUI::Asset::Wobject::Thingy",
        -label=>$i18n->get('on add workflow label'),
        -none=>1,
        -hoverHelp=>$i18n->get('on add workflow description'),
        );

    $tab->workflow(
        -name=>"onEditWorkflowId",
        -value=>$properties{onEditWorkflowId} || "",
        -type=>"WebGUI::Asset::Wobject::Thingy",
        -label=>$i18n->get('on edit workflow label'),
        -none=>1,
        -hoverHelp=>$i18n->get('on edit workflow description'),
        );

    $tab->workflow(
        -name=>"onDeleteWorkflowId",
        -value=>$properties{onDeleteWorkflowId} || "",
        -type=>"WebGUI::Asset::Wobject::Thingy",
        -label=>$i18n->get('on delete workflow label'),
        -none=>1,
        -hoverHelp=>$i18n->get('on delete workflow description'),
        );

    $tabForm->addTab('view', $i18n->get('view screen tab label'));
    $tab = $tabForm->getTab('view');
    $tab->selectBox(
        -name=> "groupIdView",
        -value=> $properties{groupIdView},
        -hoverHelp=> $i18n->get('who can view description'),
        -label => $i18n->get('who can view label'),
        -options => \%editViewOptions,
    );
    $tab->template(
        -name=>"viewTemplateId",
        -value=>$properties{viewTemplateId},
        -namespace=>"Thingy/ViewThing",
        -label=>$i18n->get('view template label'),
        -hoverHelp=>$i18n->get('view template description')
        );
    %defaultView = (
        "searchThing" => $i18n->get('search thing label'),
        "addThing" => $i18n->get('add thing label'),
        );
    $tab->selectBox(
        -name=>"defaultView",
        -options=>\%defaultView,
        -label=>$i18n->get('default view label'),
        -hoverHelp=>$i18n->get('default view description'),
        -value=>[ $properties{defaultView} || 'searchThing' ]
        );

    $tab->raw($fieldsViewScreen);

    $tabForm->addTab('search', $i18n->get('search screen tab label'));
    $tab = $tabForm->getTab('search');    
    $tab->text(
        -name   => 'searchScreenTitle',
        -label  => $i18n->get('search screen title label'),
        -hoverHelp  => $i18n->get('search screen title description'),
        -value  => $properties{searchScreenTitle},
        -maxlength => 64,
    );

    $tab->HTMLArea(
        -name   => 'searchDescription',
        -label  => $i18n->get('search description label'),
        -hoverHelp  => $i18n->get('search description description'),
        -value  => $properties{searchDescription},
        -maxlength => 64,
        -width => 300,
        -height => 200,
    );

    $tab->group(
        -name=> "groupIdSearch",
        -value=> $properties{groupIdSearch},
        -hoverHelp=> $i18n->get('who can search description'),
        -label=> $i18n->get('who can search label')
    );
    $tab->group(
        -name=> "groupIdImport",
        -value=> $properties{groupIdImport},
        -hoverHelp=> $i18n->get('who can import description'),
        -label=> $i18n->get('who can import label')
    );
    $tab->group(
        -name=> "groupIdExport",
        -value=> $properties{groupIdExport},
        -hoverHelp=> $i18n->get('who can export description'),
        -label=>$i18n->get('who can export label')
    );
    $tab->yesNo(
        -name=> "exportMetaData",
        -value=> $properties{exportMetaData},
        -hoverHelp=> $i18n->get('export metadata description'),
        -label=>$i18n->get('export metadata label')
    );
    $tab->template(
        -name=>"searchTemplateId",
        -value=>$properties{searchTemplateId},
        -namespace=>"Thingy/SearchThing",
        -label=>$i18n->get('search template label'),
        -hoverHelp=>$i18n->get('search template description')
        );
    $tab->integer(
        -name=>'thingsPerPage',
        -label=>$i18n->get('things per page label'),
        -hoverHelp  => $i18n->get('things per page description'),
        -value  => $properties{thingsPerPage},
    );
    $tab->raw($fieldsSearchScreen);
    if($warning){$output .= "$warning";}
    $output .= $tabForm->print;
    
    my $dialog = "<div id='addDialog'>\n"
                ."<div class='hd'>".$i18n->get('add field label')."</div>\n"
                ."<div class='bd'>\n";

    my %fieldProperties;
    $fieldProperties{thingId} = $thingId;
    my $dialogBody = $self->getEditFieldForm(\%fieldProperties);
    $dialog .= $dialogBody->print;

    $dialog .= "</div>\n"
            ."</div>";

    $output = $self->getAdminConsole->render($output, $i18n->get('edit thing title'));
    $output .= $dialog;
    return $output;
}

#-------------------------------------------------------------------

=head2 www_editThingSave ( )

Processes and saves the general properties of a Thing and some field properties that are not persisted to the
database immediately. 

=cut

sub www_editThingSave {

    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $form = $self->session->form;
    my ($thingId, $fields);
    $thingId = $self->session->form->process("thingId");

    $fields = $self->session->db->read('select * from Thingy_fields where assetId = '.$self->session->db->quote($self->get("assetId")).' and thingId = '.$self->session->db->quote($thingId).' order by sequenceNumber');

        
    $self->setCollateral("Thingy_things","thingId",{
        thingId=>$thingId,
        label=>$form->process("label"),
        editScreenTitle=>$form->process("editScreenTitle"),
        editInstructions=>$form->process("editInstructions"),
        groupIdAdd=>$form->process("groupIdAdd"),
        groupIdEdit=>$form->process("groupIdEdit"),
        saveButtonLabel=>$form->process("saveButtonLabel"),
        afterSave=>$form->process("afterSave"),
        editTemplateId=>$form->process("editTemplateId") || 1,
        onAddWorkflowId=>$form->process("onAddWorkflowId"),
        onEditWorkflowId=>$form->process("onEditWorkflowId"),
        onDeleteWorkflowId=>$form->process("onDeleteWorkflowId"),
        groupIdView=>$form->process("groupIdView"),
        viewTemplateId=>$form->process("viewTemplateId") || 1,
        defaultView=>$form->process("defaultView"),
        searchScreenTitle=>$form->process("searchScreenTitle"),
        searchDescription=>$form->process("searchDescription"),
        groupIdSearch=>$form->process("groupIdSearch"),
        groupIdImport=>$form->process("groupIdImport"),
        groupIdExport=>$form->process("groupIdExport"),
        searchTemplateId=>$form->process("searchTemplateId") || 1,
        thingsPerPage=>$form->process("thingsPerPage") || 25,
        sortBy=>$form->process("sortBy") || '',
        exportMetaData=>$form->process("exportMetaData") || '',
        maxEntriesPerUser=>$form->process("maxEntriesPerUser") || '',
        },0,1);
    
    if($fields->rows < 1){
        $self->session->log->warn("Thing failed to create because it had no fields");
        my $i18n = WebGUI::International->new($self->session, "Asset_Thingy");
        return $self->www_editThing($i18n->get("thing must have fields"));
    }
    
    while (my $field = $fields->hashRef) {
        my $display = $self->session->form->process("display_".$field->{fieldId}) || 0;
        my $viewScreenTitle = $self->session->form->process("viewScreenTitle_".$field->{fieldId}) || 0;
        my $displayInSearch = $self->session->form->process("displayInSearch_".$field->{fieldId}) || 0;
        my $searchIn = $self->session->form->process("searchIn_".$field->{fieldId}) || 0;

        $self->session->db->write("update Thingy_fields set display = ".$display.", viewScreenTitle = ".$viewScreenTitle.", displayinSearch = ".$displayInSearch.", searchIn = ".$searchIn." where fieldId = ".$self->session->db->quote($field->{fieldId})." and thingId = ".$self->session->db->quote($thingId));
    }
    return $self->www_manage;
}
#-------------------------------------------------------------------

=head2 www_editField ( )

Returns the html for a pop-up dialog to add or edit a field.

=cut

sub www_editField {

    my $self    = shift;
    my $session = $self->session;
    my (%properties,$thingId,$fieldId,$dialogBody);
    return $session->privilege->insufficient() unless $self->canEdit;
    $fieldId = $session->form->process("fieldId");
    $thingId = $session->form->process("thingId");
    %properties = $session->db->quickHash("select * from Thingy_fields where thingId=? and fieldId=? and assetId=?",
        [$thingId,$fieldId,$self->get("assetId")]);
    if($session->form->process("copy")){
        $properties{oldFieldId} = $properties{fieldId};
        $properties{fieldId}    = 'new';
        $properties{label}      = $properties{label}.' (copy)';
    }
    $dialogBody = $self->getEditFieldForm(\%properties);

    # Make sure we send debug information along with the field edit screen.
    $session->log->preventDebugOutput;

    $self->session->output->print($dialogBody->print);
    return "chunked";
}
#-------------------------------------------------------------------

=head2 www_editFieldSave ( )

Processes and saves a field. Returns the edited/added fieldId and the inner html for a list item on the fields tab of the edit Thing screen.

=cut

sub www_editFieldSave {

    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    my ($fieldId, $fieldTypeChanged, $newFieldId, $formClass, $dbDataType, $thingyTableName, $columnName);
    my (%properties,$listItemHTML,$formElement);
    my $i18n    = WebGUI::International->new($session, "Asset_Thingy");
    my $label   = $session->form->process("label");
    my $thingId = $session->form->process("thingId");
    my $log     = $session->log;
    my $defaultValue = $session->form->process("defaultValue");
    my $fieldType    = $session->form->process("fieldType") || "ReadOnly";

    if ($fieldType =~ m/^otherThing/){
        $defaultValue = $session->form->process("defaultFieldInThing");
    }
    
    $fieldId = $session->form->process("fieldId");
    %properties = (
        fieldId             => $fieldId,
        thingId             => $thingId,
        label               => $label,
        fieldType           => $fieldType,
        defaultValue        => $defaultValue,
        possibleValues      => $session->form->process("possibleValues"),
        pretext             => $session->form->process("pretext"),
        subtext             => $session->form->process("subtext"),
        status              => $session->form->process("status"),
        size                => $session->form->process("size"),
        width               => $session->form->process("width"),
        height              => $session->form->process("height"),
        vertical            => $session->form->process("vertical"),
        extras              => $session->form->process("extras"),
        display             => $session->form->process("display")             || 1,
        viewScreenTitle     => $session->form->process("viewScreenTitle")     || 0,
        fieldInOtherThingId => $session->form->process("fieldInOtherThingId") || "",
    );
    # Get the field's data type
    $dbDataType = $self->_getDbDataType($properties{fieldType});

    if ($fieldId eq "new") {
        $properties{dateCreated} = time();
        $properties{createdBy} = $session->user->userId;
        $newFieldId = $self->addField(\%properties,0,$dbDataType);
    }
    else{
        $properties{dateUpdated} = time();
        $properties{updatedBy} = $session->user->userId;
        # Check if column has to be altered for existing fields.
        $self->_updateFieldType($fieldType,$fieldId,$thingId,$self->get('assetId'),$dbDataType);
        $newFieldId = $self->setCollateral("Thingy_fields","fieldId",\%properties,1,1,"thingId",$thingId);
    }

    if ($properties{fieldType} eq "File"){ 
        $formElement = "<input type='file' name='file'>";
    }
    elsif ($properties{fieldType} eq "Image"){ 
        $formElement = "<input type='file' name='image'>";
    }
    else{
        $formElement = $self->getFormElement(\%properties);
    }
    if ($properties{pretext}){
        $formElement = '<span class="formSubtext">'.$properties{pretext}.'</span><br />'.$formElement;
    }
    if ($properties{subtext}){
        $formElement .= '<br /><span class="formSubtext">'.$properties{subtext}.'</span>';
    }

    $listItemHTML = "<table>\n<tr>\n<td style='width:100px;' valign='top' class='formDescription'>".$label."</td>\n"
        ."<td style='width:370px;'>".$formElement."</td>\n"
        ."<td style='width:120px;' valign='top'> <input onClick=\"editListItem('".$session->url->page()
        ."?func=editField;fieldId=".$newFieldId.";thingId=".$properties{thingId}."','".$newFieldId."')\" value='".$i18n->get('Edit','Icon')."' type='button'>"
        ."<input onClick=\"deleteListItem('".$session->url->page()."','".$newFieldId
        ."','".$properties{thingId}."')\" value='".$i18n->get('Delete','Icon')."' type='button'></td>\n</tr>\n</table>";

    # Make sure we send debug information along with the field.
    $log->preventDebugOutput;

    $session->output->print($newFieldId.$listItemHTML);
    return "chunked";
}

#-------------------------------------------------------------------

=head2 www_editThingData ( )

Shows a form to edit a things data.

=cut

sub www_editThingData {
    my $self = shift;
    return $self->processStyle($self->editThingData(@_));
}

#-------------------------------------------------------------------

=head2 canEditThingData ( )

Checks if the user can edit thing data.

=head3 thingId

The unique id of a thing.

=head3 thingDataId

The unique id of a row of thing data.

=head3 thingProperties

A hashRef containing the properties of a thing.

=cut

sub canEditThingData {
    my $self = shift;
    my $session = $self->session;
    my $thingId = shift || $session->form->process('thingId');
    my $thingDataId = shift || $session->form->process('thingDataId') || "new";
    my $thingProperties = shift || $self->getThing($thingId);
    
    my ($privilegedGroup);
    if ($thingDataId eq "new"){
        $privilegedGroup = $thingProperties->{groupIdAdd};
    }
    else {
        if ($thingProperties->{groupIdEdit} eq 'owner'){
            my $owner = $session->db->quickScalar("select createdById "
                ."from ".$session->db->dbh->quote_identifier("Thingy_".$thingId)
                ." where thingDataId = ?",[$thingDataId]);
            if ($session->user->userId eq $owner || $self->canEdit){
                return 1;
            }
            else{
                return undef;
            }
        }
        else{
            $privilegedGroup = $thingProperties->{groupIdEdit};
        }
    }
    return $self->hasPrivileges($privilegedGroup);
}

#-------------------------------------------------------------------

=head2 canViewThingData ( )

Checks if the user can view a specific row of thing data.

=head3 thingId

The unique id of a thing.

=head3 thingDataId

The unique id of a row of thing data.

=head3 thingProperties

A hashRef containing the properties of a thing.

=cut


sub canViewThingData {
    my $self = shift;
    my $session = $self->session;
    my $thingId = shift || $session->form->process('thingId');
    my $thingDataId = shift || $session->form->process('thingDataId') || "new";
    my $thingProperties = shift || $self->getThing($thingId);

    if ($thingProperties->{groupIdView} eq 'owner'){
        my $owner = $session->db->quickScalar("select createdById "
            ."from ".$session->db->dbh->quote_identifier("Thingy_".$thingId)
            ." where thingDataId = ?",[$thingDataId]);
        if ($session->user->userId eq $owner || $self->canEdit){
            return 1;
        }
        else{
            return undef;
        }
    }
    else{
        return $self->hasPrivileges($thingProperties->{groupIdView});
    }
}


#-------------------------------------------------------------------

=head2 editThingData ( )

Shows a form to edit a things data.

=cut

sub editThingData {

    my $self            = shift;
    my $session         = $self->session;
    my $thingId         = shift || $session->form->process('thingId');
    my $thingDataId     = shift || $session->form->process('thingDataId') || "new";
    my $thingProperties = shift || $self->getThing($thingId);
    my $errors          = shift;
    my $resetForm       = shift;
    my $i18n            = WebGUI::International->new($self->session, "Asset_Thingy");

    my $canEditThingData = $self->canEditThingData($thingId, $thingDataId, $thingProperties);

    return $session->privilege->insufficient() unless $canEditThingData;

    my (%thingData, $fields,@field_loop,$fieldValue, $privilegedGroup);
    my $var = $self->get;
    my $url = $self->getUrl;
    
    $var->{error_loop} = $errors if ($errors);

    $var->{canEditThings} = $self->canEdit;
    $var->{"addThing_url"} = $session->url->append($url, 'func=editThing;thingId=new');
    $var->{"manage_url"} = $session->url->append($url, 'func=manage');
    $var->{"thing_label"} = $thingProperties->{label};

    if($canEditThingData){
        if ($thingDataId ne "new"){
            $var->{"copy_url"} = $session->url->append($url, 'func=copyThingData;thingId='.$thingId.';thingDataId='.$thingDataId);
        }
    }

    if($canEditThingData){
        if ($thingDataId ne "new"){
            $var->{"delete_url"} = $session->url->append($url, 'func=deleteThingDataConfirm;thingId='
            .$thingId.';thingDataId='.$thingDataId);
        }
        $var->{"delete_confirm"} = "onclick=\"return confirm('".$i18n->get("delete thing data warning")."')\"";
    }

    if($self->hasPrivileges($thingProperties->{groupIdAdd}) && !$self->hasEnteredMaxPerUser($thingId)){    
        $var->{"add_url"} = $session->url->append($url,'func=editThingData;thingId='.$thingId.';thingDataId=new');
    }
    if($self->hasPrivileges($thingProperties->{groupIdSearch})){
        $var->{"search_url"} = $session->url->append($url, 'func=search;thingId='.$thingId);
    }


    $var->{"form_start"} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
    .WebGUI::Form::hidden($self->session,{name=>"func",value=>"editThingDataSave"});
    $var->{"form_start"} .= WebGUI::Form::hidden($self->session,{name=>"thingDataId",value=>$thingDataId});
    $var->{"form_start"} .= WebGUI::Form::hidden($self->session,{name=>"thingId",value=>$thingId});
    $var->{editScreenTitle} = $thingProperties->{editScreenTitle};
    $var->{editInstructions} = $thingProperties->{editInstructions};

    
    if ($thingDataId ne "new"){
        # Get Field Values
        %thingData = $session->db->quickHash("select * from ".$session->db->dbh->quote_identifier("Thingy_".$thingId)
        ." where thingDataId = ?",[$thingDataId]);
    }

    $fields = $session->db->read('select * from Thingy_fields where assetId = ? and thingId = ? order by sequenceNumber'
        ,[$self->getId,$thingId]);
    while (my %field = $fields->hash) {
        my $fieldName = 'field_'.$field{fieldId};
        $fieldValue = undef;
        unless ($resetForm) {
            if ($session->form->process("func") eq "editThingDataSave"){
                $fieldValue = $session->form->process($fieldName,$field{fieldType},$field{defaultValue});
            }
            else{
                $fieldValue = $thingData{"field_".$field{fieldId}};
            }
        }
        $field{value} = $fieldValue || $field{defaultValue};
        my $formElement .= $self->getFormPlugin(\%field,($resetForm eq ""))->toHtml;
        
        my $hidden = ($field{status} eq "hidden" && !$self->session->var->isAdminOn);
        my $value = $field{value};
        $value = $self->getFieldValue($value,\%field);

        my %fieldProperties = (
            "form" => $formElement,
            "name" => "field_".$field{fieldId},
            "value" => $value,
            "label" => $field{label},
            "isHidden" => $hidden,
            "isVisible" => ($field{status} eq "visible" && !$hidden),
            "isRequired" => ($field{status} eq "required" && !$hidden),
            "pretext" => $field{pretext},
            "subtext" => $field{subtext},
        );
        push(@field_loop, { map {("field_".$_ => $fieldProperties{$_})} keys(%fieldProperties) });
    }
    $var->{field_loop} = \@field_loop;
    $var->{"form_submit"} = WebGUI::Form::submit($self->session,{value => $thingProperties->{saveButtonLabel}});
    $var->{"form_end"} = WebGUI::Form::formFooter($self->session);
    $self->appendThingsVars($var, $thingId);

    if($thingDataId eq 'new' && $self->hasEnteredMaxPerUser($thingId)){
        delete $var->{form_start};
        delete $var->{form_end};
        delete $var->{form_submit};
        delete $var->{field_loop};
        $var->{editInstructions} = $i18n->get("has entered max per user message");
    }
    return $self->processTemplate($var,$thingProperties->{editTemplateId});
}

#-------------------------------------------------------------------

=head2 www_editThingDataSave ( )

Processes and saves data for a Thing.

=cut

sub www_editThingDataSave {

    my $self        = shift;
    my $session     = $self->session;
    my $thingId     = $session->form->process('thingId');
    my $thingDataId = $session->form->process('thingDataId');
    my $i18n        = WebGUI::International->new($session, "Asset_Thingy");
    
    my ($var,$newThingDataId, $fields,%thingData,@errors,$errors,$otherThingId);
    my ($privilegedGroup,$workflowId);

    my $thingProperties = $self->getThing($thingId);
    return $session->privilege->insufficient() unless $self->canEditThingData($thingId, $thingDataId
        ,$thingProperties);

    if($thingDataId eq 'new' && $self->hasEnteredMaxPerUser($thingId)){
        return $i18n->get("has entered max per user message");
    }

    ($newThingDataId,$errors) = $self->editThingDataSave($thingId,$thingDataId);

    if (scalar @$errors > 0){
        return $self->www_editThingData($thingId,$thingDataId,'',$errors);        
    }	

    if ($thingProperties->{afterSave} eq "searchThisThing") {
        return $self->www_search($thingId);
    }
    elsif ($thingProperties->{afterSave} eq "viewLastEdited"){
        return $self->www_viewThingData($thingId,$newThingDataId);
    }
    elsif ($thingProperties->{afterSave} eq "addThing") {
        return $self->www_editThingData($thingId,"new",undef,undef,"resetForm");
    }
    elsif ($thingProperties->{afterSave} =~ m/^searchOther_/x){
        $otherThingId = $thingProperties->{afterSave};
        $otherThingId =~ s/^searchOther_//x;
        return $self->www_search($otherThingId);
    }
    elsif ($thingProperties->{afterSave} =~ m/^addOther_/x){
        $otherThingId = $thingProperties->{afterSave};
        $otherThingId =~ s/^addOther_//x;
        return $self->www_editThingData($otherThingId,"new",undef,undef,"resetForm");
    }
    # if afterSave is thingy default or in any other case return www_view()
    else {
        return $self->www_view();
    }
}

#-------------------------------------------------------------------

=head2 www_editThingDataSaveViaAjax ( )

Returns a thing instance as JSON data.

=head3 thingId

The unique id of a thing.

=head3 thingDataId

The unique id of a row of thing data. When this is 'new' a new row of data will be added.

=cut

sub www_editThingDataSaveViaAjax {

    my $self        = shift;
    my $session     = $self->session;
    my $thingId     = shift || $session->form->process('thingId');
    my $thingDataId = shift || $session->form->process('thingDataId');
    my $i18n        = WebGUI::International->new($self->session, "Asset_Thingy");

    unless ($thingId && $thingDataId) {
        $session->http->setStatus("400", "Bad Request");
        return JSON->new->encode({message => "Can't get thing data without a thingId and a thingDataId."});
    }

    my $thingProperties = $self->getThing($thingId);
    if ($thingProperties->{thingId}){
        return $session->privilege->insufficient() unless $self->canEditThingData($thingId, $thingDataId
            ,$thingProperties);

        if($thingDataId eq 'new' && $self->hasEnteredMaxPerUser($thingId)){
            $session->http->setStatus("400", "Bad Request");
            return JSON->new->encode({message => $i18n->get("has entered max per user message")});
        }

    	my ($newThingDataId,$errors) = $self->editThingDataSave($thingId,$thingDataId);

    	if (@{ $errors }) {
            $session->http->setStatus("400", "Bad Request");
            return JSON->new->encode($errors);
    	}
        $session->http->setStatus("200");
        return '{}';
    }
    else {
        $session->log->warn("thingId ".$thingProperties->{thingId}." not found in thingProperties");
        $session->http->setStatus("404", "Not Found");
        return JSON->new->encode({message => "The thingId you requested can not be found."});
    }
}

#-------------------------------------------------------------------

=head2 www_export ( )

Exports search results as csv.

=cut

sub www_export {
    my $self = shift;
    my $session = $self->session;
    my ($query,$sth,$out,$fields,@fields,$fileName,@fieldLabels);
    my $thingId = $session->form->process('thingId');

    my $thingProperties = $self->getThing($thingId);
    return $session->privilege->insufficient() unless $self->hasPrivileges($thingProperties->{groupIdExport});
   
    $fields = $session->db->read('select * from Thingy_fields where assetId =? and thingId = ? order by sequenceNumber',
        [$self->get("assetId"),$thingId]);
    while (my $field = $fields->hashRef) {
        if ($field->{displayInSearch}){
            push(@fields, {
                fieldId => $field->{fieldId},
                properties => $field,
            });
            push(@fieldLabels,$field->{label});
        }
    }
    my @metaDataFields = ('thingDataId','dateCreated','createdById','updatedById','updatedByName','lastUpdated','ipAddress');
    if ($thingProperties->{exportMetaData}){
        push(@fieldLabels,@metaDataFields)
    }
 
    $query = WebGUI::Cache->new($self->session,"query_".$thingId)->get;
    $sth = $session->db->read($query);

    ### Loop through the returned structure and put it through Text::CSV
    # Column heads
    $out = WebGUI::Text::joinCSV(@fieldLabels);

    # Data lines
    while (my $data = $sth->hashRef) {
        my @fieldValues;
        foreach my $field (@fields){
            my $fieldId = $field->{fieldId};
            # Export date and dateTime fields in an importable format.
            my $value = $self->getFieldValue($data->{"field_".$fieldId},$field->{properties},"%y-%m-%d","%y-%m-%d %j:%n:%s");
            push(@fieldValues, $value);
        }
        foreach my $metaDataField (@metaDataFields){
            push(@fieldValues,$data->{$metaDataField});
        }
        $out .= "\n".WebGUI::Text::joinCSV(
        @fieldValues
        );
    }
    
    $fileName = "export_".$thingProperties->{label}.".csv";
    $self->session->http->setFilename($fileName,"application/octet-stream");
    $self->session->http->sendHeader;
    return $out;

}

#-------------------------------------------------------------------

=head2 www_getThingViaAjax ( )

Returns a things properties as JSON.

=head3 thingId

The unique id of a thing.

=cut

sub www_getThingViaAjax {

    my $self    = shift;
    my $session = $self->session;
    my $thingId = shift || $session->form->process('thingId');
    $session->http->setMimeType("application/json");

    unless ($thingId) {
        $session->http->setStatus("400", "Bad Request");
        return JSON->new->encode({message => "Can't return thing properties without a thingId."});
    }

    my $thingProperties = $self->getThing($thingId);
    if ($thingProperties->{thingId}){
        return $session->privilege->insufficient() unless $self->canViewThing($thingId,
            $thingProperties->{groupIdView});

        my @field_loop;
        my $fields = $session->db->read('select * from Thingy_fields where assetId=? and thingId=? order by sequenceNumber'
        ,[$self->getId,$thingId]);
        while (my $field = $fields->hashRef) {
            $field->{formElement} = $self->getFormElement($field);
            push(@field_loop,$field);
        }
        $thingProperties->{field_loop} = \@field_loop;
        
        $session->http->setMimeType("application/json");
        return JSON->new->encode($thingProperties);
    }
    else {
        $session->http->setStatus("404", "Not Found");
        return JSON->new->encode({message => "The thingId you requested can not be found."});
    }
}

#-------------------------------------------------------------------

=head2 www_getThingsViaAjax ( )

Returns the Things in a Thingy as JSON. 

=cut

sub www_getThingsViaAjax {

    my $self    = shift;
    my $session = $self->session;

    $session->http->setMimeType("application/json");

    my @visibleThings;
    my $things = $self->getThings;
    while (my $thing = $things->hashRef) {
        if ($self->canViewThing($thing->{thingId},$thing->{groupIdView})){
            $thing->{canSearch} = $self->canSearch($thing->{thingId},$thing);
            $thing->{canEdit}   = $self->hasPrivileges($thing->{groupIdEdit}); 
            $thing->{canAdd}    = $self->hasPrivileges($thing->{groupIdAdd});
            push(@visibleThings,$thing);
        }
    }
    if (scalar @visibleThings > 0){
        return JSON->new->encode(\@visibleThings);
    }
    else {
        $session->http->setStatus("404", "Not Found");
        return JSON->new->encode({message => "No visible Things were found in this Thingy."});
    }
}


#-------------------------------------------------------------------

=head2 www_import ( )

Imports data from a .csv file.

=cut

sub www_import {
    my $self = shift;
    my $session = $self->session;
    my $dbh = $session->db->dbh;
    my ($sql,$fields,@fields,$fileName,@insertColumns);
    my ($handleDuplicates,$newThingDataId);

    my $thingId = $session->form->process('thingId');
    my $thingProperties = $self->getThing($thingId);
    return $session->privilege->insufficient() unless $self->hasPrivileges($thingProperties->{groupIdImport});

    $fields = $session->db->read('select label, fieldId, fieldType, fieldInOtherThingId from Thingy_fields '
        .' where assetId = '.$session->db->quote($self->get("assetId"))
        .' and thingId = '.$session->db->quote($thingId)
        .' order by sequenceNumber');
    while (my $field = $fields->hashRef) {
        push(@insertColumns, $field) if ($session->form->process("fileContains_".$field->{fieldId}));
    }

    my $error = $self->session->errorHandler;
    my $storage = WebGUI::Storage->createTemp($self->session);
    $handleDuplicates = $session->form->process("handleDuplicates");

    $storage->addFileFromFormPost("importFile_file",1);
    foreach my $file (sort(@{$storage->getFiles})) {
        next unless ($storage->getFileExtension($file) eq "csv");
        
        $error->info("Found import file $file");
        open my $importFile,"<:raw:eol(NATIVE)",$storage->getPath($file);
        my $lineNumber = 0;
        my @data = ();
        
        while ( my $row = WebGUI::Text::readCSV($importFile) ) {
            if ($lineNumber == 0 && $session->form->process('ignoreFirstLine')){
                $lineNumber++;
                $error->info("Skipping first line");
                next;
            }
            $error->info("Reading line $lineNumber: @{ $row }");
            $lineNumber++;
            @data = @{ $row };
            
            # check for duplicates
            my $fieldNumber = 0;
            my $foundDuplicateId = "";
            my @duplicatesConstraint;

            # Create duplicate constraint
            foreach my $insertColumn (@insertColumns){
                my $insertValue = $data[$fieldNumber];
                if ($session->form->process("checkDuplicates_".$insertColumn->{fieldId})){
                    #$error->info("adding $fieldId to duplicates constraint");
                    push(@duplicatesConstraint,$dbh->quote_identifier("field_".$insertColumn->{fieldId})
                        ." = ".$session->db->quote($insertValue));
                }
                $fieldNumber++;
            }
            
            if((scalar @duplicatesConstraint) > 0){
                my $query = "select thingDataId from ".$dbh->quote_identifier("Thingy_".$thingId)." where ";
                $query .= join(" and ",@duplicatesConstraint);
                $query .= " limit 1";
                ($foundDuplicateId) = $session->db->quickArray($query);
                if ($foundDuplicateId){
                    $error->info("found duplicate record: ".$foundDuplicateId." for data: ". @{ $row });
                }
            }

            my %thingData = ();
            $fieldNumber = 0;

            # Populate thingData hash
            foreach my $insertColumn (@insertColumns){     
                my $fieldValue = $data[$fieldNumber];    
                my $fieldName = "field_".$insertColumn->{fieldId};
                my $fieldType = $insertColumn->{fieldType};
                my $fieldInOtherThingId = $insertColumn->{fieldInOtherThingId};
                # TODO: process dates and otherThing field id's 
                if (lc $fieldType eq "date" || lc $fieldType eq "datetime"){
                    $fieldValue =~ s/\//-/gx;
                    $fieldValue = $session->datetime->setToEpoch($fieldValue);                
                }
                elsif($fieldType =~ m/^otherThing/x){
                    my $otherThingId = $fieldType;
                    $otherThingId =~ s/^otherThing_(.*)/$1/x;
                    ($fieldValue) = $self->session->db->quickArray('select thingDataId '
                        .' from '.$dbh->quote_identifier('Thingy_'.$otherThingId)
                        .' where '.$dbh->quote_identifier('field_'.$fieldInOtherThingId).' = ?',[$fieldValue]);
                }
                $thingData{$fieldName} = $fieldValue;
                $fieldNumber++;
            }
            if ($foundDuplicateId && $handleDuplicates eq "overwrite"){
                $thingData{thingDataId} = $foundDuplicateId;
                $error->info("Overwriting, thingDataId = ".$thingData{thingDataId});
            }
            elsif ($foundDuplicateId eq ""){
                $thingData{thingDataId} = "new";
                $error->info("Importing new line");
            }
            else{
                $error->info("Skipping line");
                next;
            }
            $thingData{lastUpdated} = time();
            $thingData{updatedByName} = $session->user->username;
            $thingData{updatedById} = $session->user->userId;
            $self->setCollateral("Thingy_".$thingId,"thingDataId",\%thingData,0,0) if ($thingData{thingDataId});
        }
        close $importFile;
    }

    return $self->www_search($thingId);
}


#-------------------------------------------------------------------

=head2 www_importForm ( )

Shows the import screen.

=cut

sub www_importForm {
    my $self = shift;
    my $session = $self->session;
    my $db = $session->db;
    my ($i18n,$form,$fields,$fieldOptions,$output);
    my $thingId = $session->form->process('thingId');

    my $thingProperties = $self->getThing($thingId);
    return $session->privilege->insufficient() unless $self->hasPrivileges($thingProperties->{groupIdImport});

    $i18n = WebGUI::International->new($self->session, "Asset_Thingy");
    
    $output = "<h1>".$i18n->get("import label")."</h1>";
    $form = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $form->hidden(
        -name => "thingId",
        -value => $thingId
    );
    $form->hidden(
        -name => "func",
        -value => "import"
    );

    $form->file(
        -name => "importFile",
        -label => $i18n->get("import file label"),
    );

    $form->selectBox(
        -name => "handleDuplicates",
        -label=> $i18n->get("duplicates label"),
        -options=> {
                "skip" => $i18n->get("skip label"),
                "overwrite" => $i18n->get("overwrite label"),
            },
    );
    $form->yesNo(
        -name=>"ignoreFirstLine",
        -label=>$i18n->get("ignore first line label"),
    );

    $fieldOptions = "<table>"
        ."<tr><td></td>"
        ."  <td>".$i18n->get("file contains label")."</td>"
        ."  <td>".$i18n->get("check duplicates label")."</td>"
        ."</tr>";

    $fields = $db->read('select label, fieldId from Thingy_fields where assetId =? and thingId = ? order by sequenceNumber',
        [$self->get("assetId"),$thingId]);
    while (my $field = $fields->hashRef) {
        $fieldOptions .= "<tr><td>".$field->{label}."</td><td>";
        $fieldOptions .= WebGUI::Form::checkbox($self->session, {
                checked => "",
                name  => "fileContains_".$field->{fieldId},
                value => 1,
            });
        $fieldOptions .= "</td><td>";
        $fieldOptions .= WebGUI::Form::checkbox($self->session, {
                checked => "",
                name  => "checkDuplicates_".$field->{fieldId},
                value => 1,
            });
        $fieldOptions .= "</td></tr>";
    }
    $fieldOptions .= "</table>";
    $form->raw($fieldOptions);
    $form->submit;

    $output .= $form->print;
    return $self->processStyle($output);
}

#-------------------------------------------------------------------

=head2 www_manage ( )

Shows the screen to manage things in a Thingy.

=cut

sub www_manage {

    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;

    my $i18n = WebGUI::International->new($self->session,"Asset_Thingy");
    my ($things, @things_loop);
    my $var = $self->get;
    my $url = $self->getUrl;
    
    $var->{canEditThings}  = $self->canEdit;
    $var->{"addThing_url"} = $session->url->append($url, 'func=editThing;thingId=new');
    $var->{"manage_url"}   = $session->url->append($url, 'func=manage');
    $var->{"view_url"}     = $session->url->page;

    #Get things in this Thingy
    $things = $self->getThings;
    while (my $thing = $things->hashRef) {
        my %templateVars = (
            'thing_id' => $thing->{thingId},
            'thing_label' => $thing->{label},
            'thing_deleteUrl' => $session->url->append($url, 'func=deleteThingConfirm;thingId='.$thing->{thingId}),
            'thing_deleteIcon' => $session->icon->delete('func=deleteThingConfirm;thingId='.$thing->{thingId},
                "",$i18n->get('delete thing warning')),
            'thing_editUrl' => $session->url->append($url, 'func=editThing;thingId='.$thing->{thingId}),
            'thing_editIcon' => $session->icon->edit('func=editThing;thingId='.$thing->{thingId}),
            'thing_copyUrl' => $session->url->append($url, 'func=duplicateThing;thingId='.$thing->{thingId}),
            'thing_copyIcon' => $session->icon->copy('func=duplicateThing;thingId='.$thing->{thingId}),
            'thing_addUrl' => $session->url->append($url,
                'func=editThingData;thingId='.$thing->{thingId}.';thingDataId=new'),
            'thing_searchUrl' => $session->url->append($url, 'func=search;thingId='.$thing->{thingId}), 
        );
        # set the url for the view icon to the things default view
        my $viewParams;
        if ($thing->{defaultView} eq "addThing") {
            $viewParams = 'func=editThingData;thingId='.$thing->{thingId}.';thingDataId=new';
        }
        else{
            $viewParams = 'func=search;thingId='.$thing->{thingId};
        }
        $templateVars{'thing_viewIcon'} = $session->icon->view($viewParams);
        push (@things_loop, \%templateVars);
    }

    $var->{"things_loop"} = \@things_loop;

    return $self->processStyle($self->processTemplate($var, $self->get("templateId")));
}

#-------------------------------------------------------------------

=head2 www_moveFieldConfirm ( )

Moves a field up or down in the sequence of fields.

=cut

sub www_moveFieldConfirm {

    my $self = shift;   
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;

    my $error = $self->session->errorHandler;
    my $direction = $session->form->process('direction');
    my $assetId = $self->get('assetId');
    my $fieldId = $session->form->process('fieldId');
    my $targetFieldId = $session->form->process('targetFieldId');
   
    $error->info("moving $fieldId to target  $targetFieldId, direction: $direction"); 
    
    my ($thingId,$originalRank) = $session->db->quickArray(
        "select thingId, sequenceNumber from Thingy_fields where fieldId = ".$session->db->quote($fieldId)." and assetId = ".$session->db->quote($assetId));
    my ($targetRank) = $session->db->quickArray(
         "select sequenceNumber from Thingy_fields where fieldId = ".$session->db->quote($targetFieldId)." and assetId = ".$session->db->quote($assetId));
    
    if($targetRank > $originalRank){
        # seq -- for orig seq < seq =< newseq
        if ($direction eq "up"){
            $targetRank--;
        }
        my $sql = "update Thingy_fields set sequenceNumber = sequenceNumber - 1 where  sequenceNumber > "
        .$originalRank." and sequenceNumber <= ".$targetRank." and assetId = ".$session->db->quote($assetId)
        ." and thingId = ".$session->db->quote($thingId);
        $session->db->write($sql);
    }
    else{
        # seq ++ for newseq  =< seq < orig seq
        if ($direction eq "down") {
            $targetRank++;
        }
        $session->db->write("update Thingy_fields set sequenceNumber = sequenceNumber + 1 where sequenceNumber >= "
        .$targetRank." and sequenceNumber < ".$originalRank." and assetId = ".$session->db->quote($assetId)." and thingId = ".$session->db->quote($thingId));
    }
    # orig seq = target seq
    $self->session->db->write("update Thingy_fields set sequenceNumber = ".$targetRank." where fieldId = ".$self->session->db->quote($fieldId)."  and assetId = ".$self->session->db->quote($assetId)." and thingId = ".$self->session->db->quote($thingId));
    
    $self->session->output->print("fieldMoved");
    return "chunked";

}

#-------------------------------------------------------------------

=head2 www_search ( )

Shows the search screen wrapped in a style.

=cut

sub www_search {
    my $self = shift;
    return $self->processStyle($self->search(@_));
}

#-------------------------------------------------------------------

=head2 www_searchViaAjax ( )

Shows the search screen wrapped in a style.

=head3 thingId

The unique id of a thing.

=head3 thingProperties

A hashref containing the properties of a thing.


=cut

sub www_searchViaAjax {

    my $self            = shift;
    my $session         = $self->session;
    my $thingId         = shift || $session->form->process('thingId');
    my $thingProperties = shift || $self->getThing($thingId);
    my $i18n            = WebGUI::International->new($self->session,"Asset_Thingy");

    unless ($thingId) {
        $session->http->setStatus("400", "Bad Request");
        return JSON->new->encode({message => "Can't perform search without a thingId."});
    }

    if ($thingProperties->{thingId}){

        return $session->privilege->insufficient() unless $self->canViewThing($thingId,
            $thingProperties->{groupIdView});

        my $var = $self->getSearchTemplateVars($thingId,$thingProperties);

        $session->http->setMimeType("application/json");
        return JSON->new->encode($var);
    }
    else {
        $session->http->setStatus("404", "Not Found");
        return JSON->new->encode({message => "The thingId you requested can not be found."});
    }
}

#-------------------------------------------------------------------

=head2 canSearch ( )

Checks if the user can perform a search.

=cut

sub canSearch {
    my $self = shift;
    my $thingId = shift || $self->session->form->process('thingId');
    my $thingProperties = shift || $self->getThing($thingId);
    return $self->hasPrivileges($thingProperties->{groupIdSearch});
}

#-------------------------------------------------------------------

=head2 search ( )

Returns the search screen without style.

=cut

sub search {

    my $self = shift;
    my $thingId = shift || $self->session->form->process('thingId');
    my $thingProperties = shift || $self->getThing($thingId);
    my $i18n = WebGUI::International->new($self->session,"Asset_Thingy");

    return $i18n->get("no permission to search") if( ! $self->canSearch($thingId, $thingProperties));

    my $var = $self->getSearchTemplateVars($thingId,$thingProperties);    
    return $self->processTemplate($var,$thingProperties->{searchTemplateId}); 

}

#-------------------------------------------------------------------

=head2 getSearchTemplateVars ( )

Performs the search and returns the tmpl var hashref.

=cut

sub getSearchTemplateVars {

    my $self = shift;
    my $thingId = shift || $self->session->form->process('thingId');
    my $thingProperties = shift || $self->getThing($thingId);
    my $session = $self->session;
    my $dbh = $session->db->dbh;
    my $i18n = WebGUI::International->new($self->session,"Asset_Thingy");
    my ($var,$url,$orderBy);
    my ($fields,@searchFields_loop,@displayInSearchFields_loop,$query,@constraints);
    my (@searchResult_loop,$searchResults,@searchResults,@displayInSearchFields,$paginatePage,$currentUrl,$p);

    $orderBy = $session->form->process("orderBy") || $thingProperties->{sortBy};
    $var = $self->get;
    $url = $self->getUrl;

    $var->{canEditThings} = $self->canEdit;
    $var->{"addThing_url"} = $session->url->append($url, 'func=editThing;thingId=new');
    $var->{"manage_url"} = $session->url->append($url, 'func=manage');
    $var->{"thing_label"} = $thingProperties->{label};

    if ($self->hasPrivileges($thingProperties->{groupIdExport})){
        $var->{"export_url"} = $session->url->append($url, 'func=export;thingId='.$thingId);
    }
    if ($self->hasPrivileges($thingProperties->{groupIdImport})){
        $var->{"import_url"} = $session->url->append($url, 'func=importForm;thingId='.$thingId);
    }
    if ($self->hasPrivileges($thingProperties->{groupIdAdd}) && !$self->hasEnteredMaxPerUser($thingId)){
        $var->{"add_url"} = $session->url->append($url,'func=editThingData;thingId='.$thingId.';thingDataId=new');
    }
    $var->{searchScreenTitle} = $thingProperties->{searchScreenTitle};    
    $var->{searchDescription} = $thingProperties->{searchDescription};

    $currentUrl = $self->getUrl();
    foreach ($self->session->form->param) {
                                 # if we just saved data from an edit, we do not want to keep any of the params
        last if $_ eq 'func' and $self->session->form->process($_) eq 'editThingDataSave';

        unless ($_ eq "pn" || $_ eq "op" || $_ =~ /identifier/xi || $_ =~ /password/xi || $_ eq "orderBy" ||
$self->session->form->process($_) eq "") {
            $currentUrl = $self->session->url->append($currentUrl,$self->session->url->escape($_)
            .'='.$self->session->url->escape($self->session->form->process($_)));
        }
    }
    
    $fields = $session->db->read('select * from Thingy_fields where assetId =
'.$session->db->quote($self->get("assetId")).' and thingId = '.$session->db->quote($thingId).' order by
sequenceNumber');
    while (my $field = $fields->hashRef) {
        if ($field->{searchIn}){
            my $searchForm = $self->getFormPlugin($field, 1);
            my $searchTextForm = WebGUI::Form::Text($self->session, {
                name=>"field_".$field->{fieldId},
                size=>25,
            });
            my $fieldType;
            if ($field->{fieldType} =~ m/^otherThing/x){
                $fieldType = "OtherThing";
            }
            else{
                $fieldType = ucfirst $field->{fieldType}; 
            }
            push(@searchFields_loop, {
                "searchFields_fieldId" => $field->{fieldId},
                "searchFields_label" => $field->{label},
                "searchFields_form" => $searchForm->toHtml,
                "searchFields_textForm" => $searchTextForm,
                "searchFields_is".$fieldType => 1,
                "searchFields_listType" => $searchForm->isa('WebGUI::Form::List'),
            });

            my @searchValue = $session->form->process("field_".$field->{fieldId});
            my $constraint  = 
                join    ' OR ',
                map     { $dbh->quote_identifier("field_".$field->{fieldId}) . " LIKE " . $dbh->quote('%'.$_.'%') } 
                @searchValue ;        

            push @constraints, " ( $constraint ) " if @searchValue; 
        }
        if($field->{displayInSearch}){
            my $orderByUrl = $self->session->url->append($currentUrl,"orderBy=".$field->{fieldId});
            push(@displayInSearchFields_loop, {
                "displayInSearchFields_fieldId" => $field->{fieldId},
                "displayInSearchFields_label" => $field->{label},
                "displayInSearchFields_orderByUrl" => $orderByUrl,
            });
            push(@displayInSearchFields, {
                fieldId => $field->{fieldId},
                properties => $field,
            });
        }
    }
    my $noFields = 0;    
    if (scalar(@displayInSearchFields)){
        $query = "select thingDataId, ";
        if ($thingProperties->{exportMetaData}){
            $query .= "dateCreated, createdById, updatedById, updatedByName, lastUpdated, ipAddress, ";
        }
        $query .= join(", ",map {$dbh->quote_identifier('field_'.$_->{fieldId})} @displayInSearchFields);
        $query .= " from ".$dbh->quote_identifier("Thingy_".$thingId);
        if($session->form->process('func') eq 'search'){
            # Don't add constraints when the search screen is displayed as an 'after save' option.
            $query .= " where ".join(" and ",@constraints) if (scalar(@constraints) > 0);
        }
        if ($orderBy){
            $query .= " order by ".$dbh->quote_identifier("field_".$orderBy);
        }
    }
    else{
        $self->session->errorHandler->warn("The default Thing has no fields selected to display in the search.");
        $noFields = 1;
    }

    # store query in cache for thirty minutes
    WebGUI::Cache->new($self->session,"query_".$thingId)->set($query,30*60);

    $paginatePage = $self->session->form->param('pn') || 1;
    $currentUrl   = $self->session->url->append($currentUrl, "orderBy=".$orderBy) if $orderBy;

    $p = WebGUI::Paginator->new($self->session,$currentUrl,$thingProperties->{thingsPerPage}, undef, $paginatePage);

    my @visibleResults;
    if (! $noFields) {
        my $sth = $self->session->db->read($query) if ! $noFields;
        while (my $result = $sth->hashRef){
            if ($self->canViewThingData($thingId,$result->{thingDataId})){
                push(@visibleResults,$result);
            }
        }
    }
    $p->setDataByArrayRef(\@visibleResults);

    $searchResults = $p->getPageData($paginatePage);
    foreach my $searchResult (@$searchResults){
        my (@field_loop);
        foreach my $field (@displayInSearchFields){
            my $fieldId = $field->{fieldId};
            my $value = $self->getFieldValue($searchResult->{"field_".$fieldId},$field->{properties});
            push(@field_loop,{
                "field_value" => $value,
                "field_id" => $fieldId,
            });
        }
        my $thingDataId = $searchResult->{thingDataId};
        my %templateVars = (
            "searchResult_id" => $thingDataId,
            "searchResult_view_url" => $session->url->append($url, 'func=viewThingData;thingId=' 
            .$thingId.';thingDataId='.$thingDataId),
            "searchResult_field_loop" => \@field_loop,
        );
        if ($self->canEditThingData($thingId,$thingDataId,$thingProperties)){
            $templateVars{canEditThingData} = 1;
            $templateVars{searchResult_delete_icon} = $session->icon->delete('func=deleteThingDataConfirm;thingId='
            .$thingId.';thingDataId='.$thingDataId,$self->get("url"),$i18n->get('delete thing data warning'));
            $templateVars{searchResult_delete_url} = $session->url->append($url,
                'func=deleteThingDataConfirm;thingId='.$thingId.';thingDataId='.$thingDataId);
            $templateVars{searchResult_edit_icon} = $session->icon->edit('func=editThingData;thingId='
            .$thingId.';thingDataId='.$thingDataId,$self->get("url"));
            $templateVars{searchResult_edit_url} = $session->url->append($url, 
                'func=editThingData;thingId='.$thingId.';thingDataId='.$thingDataId);
            $templateVars{searchResult_copy_icon} = $session->icon->copy('func=copyThingData;thingId='
            .$thingId.';thingDataId='.$thingDataId,$self->get("url"));
            $templateVars{searchResult_copy_url} = $session->url->append($url, 
                'func=copyThingData;thingId='.$thingId.';thingDataId='.$thingDataId,);
        }
        push(@searchResult_loop,\%templateVars);
    }
    $var->{searchResult_loop} = \@searchResult_loop;    
    
    # Also expose the search results in the template as a json-encoded string
    # so that people can e.g. visualise the results via Javascript
    $var->{searchResult_json} = JSON->new->encode(\@searchResult_loop);
    
    $p->appendTemplateVars($var);

    $var->{"form_start"} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl,method=>'GET'})
    .WebGUI::Form::hidden($self->session,{name=>"func",value=>"search"});
    $var->{"form_start"} .= WebGUI::Form::hidden($self->session,{name=>"thingId",value=>$thingId});
    $var->{"form_submit"} = WebGUI::Form::submit($self->session,{value=>$i18n->get("search button label")});
    $var->{"form_end"} = WebGUI::Form::formFooter($self->session);

    $var->{searchFields_loop} = \@searchFields_loop;
    $var->{displayInSearchFields_loop} = \@displayInSearchFields_loop;
    $self->appendThingsVars($var, $thingId);
    return $var;	
}

#-------------------------------------------------------------------

=head2 www_selectDefaultFieldValue ( )

Returns a form element to select a field in a thing.

=cut

sub www_selectDefaultFieldValue {

    my $self = shift;
    my $thingId = $self->session->form->process('thingId');
    my $fieldId = $self->session->form->process('fieldId');
    my $fieldInOtherThingId = $self->session->form->process('fieldInOtherThingId');
    return "" if ($thingId eq "" || $fieldId eq "");

    my $session = $self->session;
    my $dbh = $session->db->dbh;
    my $i18n = WebGUI::International->new($self->session, "Asset_Thingy");

    return $session->privilege->insufficient() unless $self->canViewThing($thingId);

    my $options = $session->db->buildHashRef('select thingDataId, '
        .$dbh->quote_identifier('field_'.$fieldInOtherThingId)
        .' from '.$dbh->quote_identifier('Thingy_'.$thingId)
        .' where '.$dbh->quote_identifier('field_'.$fieldInOtherThingId).' != ""');
    my ($value) = $session->db->quickArray('select defaultValue from Thingy_fields where fieldId=?',[$fieldId]);

    my $formElement;
    if (scalar(keys %$options) > 0){
        $formElement = WebGUI::Form::SelectBox($self->session,{ 
            name => "defaultFieldInThing",
            options => $options,
            value => $value,
            extras => 'style="width: 200px;"',
        });
    }
    else{
        $formElement = $i18n->get('no field values message');
    }
    my $html .=    "\t<table cellpadding='0' cellspacing='0' style='width: 100%;'>\n";
    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>";
    $html .=    $i18n->get("default value label")."</td>";
    $html .=    "<td valign='top' class='tableData' style='padding-left:4px'>";
    $html .=    $formElement."</td>";
    $html .=    "\t\n</tr>\n";
    $html .=    "\t</table>";

    $self->session->output->print($html);
    return "chunked";
}


#-------------------------------------------------------------------

=head2 www_selectFieldInThing ( )

Returns a form element to select a field in a thing.

=cut

sub www_selectFieldInThing {

    my $self = shift;
    my $thingId = $self->session->form->process('thingId');
    my $fieldId = $self->session->form->process('fieldId');
    my $prefix = $self->session->form->process('prefix');
    my $session = $self->session;
    my $i18n = WebGUI::International->new($self->session, "Asset_Thingy");

    return $session->privilege->insufficient() unless $self->canViewThing($thingId);

    my $fields = $session->db->buildHashRef('select fieldId, label from Thingy_fields'
        .' where assetId = ? and thingId = ? and fieldId != ? order by sequenceNumber',
        [$self->get("assetId"),$thingId,$fieldId]);
   
    my ($value) = $session->db->quickArray('select fieldInOtherThingId from Thingy_fields where fieldId = '
    .$session->db->quote($fieldId));
    
    my $formElement = WebGUI::Form::SelectBox($self->session,{             
            name => "fieldInOtherThingId",
            options => $fields,
            id => $prefix."_fieldInOtherThing_formId",
            value => $value,
            extras => 'style="width: 200px;"',
        });

    my $html .=    "\t<table cellpadding='0' cellspacing='0' style='width: 100%;'>\n";
    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>";
    $html .=    $i18n->get("field in other thing label")."</td>";
    $html .=    "<td valign='top' class='tableData' style='padding-left:4px'>";
    $html .=    $formElement."</td>";
    $html .=    "\t\n</tr>\n";
    $html .=    "\t</table>";

    $self->session->output->print($html);
    return "chunked";
}

#-------------------------------------------------------------------

=head2 www_viewThingData ( )

Shows the view screen of a Thing

=head3 thingId

The unique id of a thing.

=head3 thingDataId

The unique id of a row of thing data.

=cut

sub www_viewThingData {

    my $self        = shift;
    my $session     = $self->session;
    my $thingId     = shift || $session->form->process('thingId');
    my $thingDataId = shift || $session->form->process('thingDataId');
    
    my $var     = $self->get;
    my $url     = $self->getUrl;
    my $i18n    = WebGUI::International->new($self->session, "Asset_Thingy");

    my $thingProperties = $self->getThing($thingId);
    return $self->session->privilege->insufficient() unless $self->canViewThingData(
        $thingId, $thingDataId, $thingProperties);

    $var->{canEditThings}   = $self->canEdit;
    $var->{"addThing_url"}  = $session->url->append($url, 'func=editThing;thingId=new');
    $var->{"manage_url"}    = $session->url->append($url, 'func=manage');
    $var->{"thing_label"}   = $thingProperties->{label};

    if($self->hasPrivileges($thingProperties->{groupIdEdit})){
        $var->{"edit_url"} = $session->url->append($url,'func=editThingData;thingId='
        .$thingId.';thingDataId='.$thingDataId);
        $var->{"delete_url"} = $session->url->append($url, 'func=deleteThingDataConfirm;thingId='
        .$thingId.';thingDataId='.$thingDataId);
        $var->{"delete_confirm"} = "onclick=\"return confirm('".$i18n->get("delete thing data warning")."')\"";
    }
    if($self->hasPrivileges($thingProperties->{groupIdAdd}) && !$self->hasEnteredMaxPerUser($thingId)){
        $var->{"add_url"} = $session->url->append($url, 'func=editThingData;thingId='.$thingId.';thingDataId=new');
    }
    if($self->hasPrivileges($thingProperties->{groupIdSearch})){    
        $var->{"search_url"} = $session->url->append($url, 'func=search;thingId='.$thingId);
    }

    $self->getViewThingVars($thingId,$thingDataId,$var);
    $self->appendThingsVars($var, $thingId);
    return $self->processStyle(
        $self->processTemplate($var,$thingProperties->{viewTemplateId})
    );
}

#-------------------------------------------------------------------

=head2 www_viewThingDataViaAjax ( )

Returns a thing instance as JSON data.

=head3 thingId

The unique id of a thing.

=head3 thingDataId

The unique id of a row of thing data.

=cut

sub www_viewThingDataViaAjax {

    my $self        = shift;
    my $session     = $self->session;
    my $thingId     = shift || $session->form->process('thingId');
    my $thingDataId = shift || $session->form->process('thingDataId');

    $session->http->setMimeType("application/json");

    unless ($thingId && $thingDataId) {
        $session->http->setStatus("400", "Bad Request");
        return JSON->new->encode({message => "Can't get thing data without a thingId and a thingDataId."});
    }

    my $thingProperties = $self->getThing($thingId);
    if ($thingProperties->{thingId}){
        return $self->session->privilege->insufficient() unless $self->canViewThingData(
        $thingId, $thingDataId, $thingProperties);

        my $output = $self->getViewThingVars($thingId,$thingDataId);

        if ($output){
            return JSON->new->encode($output);
        }
        else{
            $session->http->setStatus("404", "Not Found");
            return JSON->new->encode({message => "The thingDataId you requested can not be found."});
        }
    }
    else {
        $session->http->setStatus("404", "Not Found");
        return JSON->new->encode({message => "The thingId you requested can not be found."});
    }
}

1;
