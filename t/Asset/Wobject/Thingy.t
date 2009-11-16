#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test the creation of Thingy Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 32; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $templateId = 'THING_EDIT_TEMPLATE___';
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thingy Test"});
WebGUI::Test->tagsToRollback($versionTag);
my $thingy = $node->addChild({className=>'WebGUI::Asset::Wobject::Thingy'});

# Test for a sane object type
isa_ok($thingy, 'WebGUI::Asset::Wobject::Thingy');

# Test to see if we can set new values
my $newThingySettings = {
	templateId=>'testingtestingtesting1',
};
$thingy->update($newThingySettings);

foreach my $newSetting (keys %{$newThingySettings}) {
	is ($thingy->get($newSetting), $newThingySettings->{$newSetting}, "updated $newSetting is ".$newThingySettings->{$newSetting});
}

# Test adding a new Thing
my $i18n = WebGUI::International->new($session, "Asset_Thingy");
my $groupIdEdit = $thingy->get("groupIdEdit");
my %thingProperties = (
            thingId=>"new",
            label=>$i18n->get('assetName'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            editInstructions=>'',
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            searchDescription=>'',
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
);
my $thingId = $thingy->addThing(\%thingProperties,0); 

my $isValidId = $session->id->valid($thingId);

is($isValidId,1,"addThing returned a valid id: ".$thingId);

# Test for a sane object type
my $thing = WebGUI::Asset::Wobject::Thingy::Thing->new($session,$thingId);
isa_ok($thing, 'WebGUI::Asset::Wobject::Thingy::Thing');

my $thingTableName = "Thingy_".$thingId;

my ($thingTableNameCheck) = $session->db->quickArray("show tables like ".$session->db->quote($thingTableName));

is($thingTableNameCheck,$thingTableName,"An empty table: ".$thingTableName." for the new thing exists.");

is($thingy->get('defaultThingId'),$thingId,"The Thingy assets defaultThingId was set correctly.");

# Test getting the newly added thing by its thingID as JSON

$session->user({userId => 3});
my $json = $thingy->www_getThingViaAjax($thingId);
my $dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
            assetId=>$thingy->getId,
            thingId=>$thingId,
            label=>$i18n->get('assetName'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            editInstructions=>'',
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            searchDescription=>'',
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
            display=>undef,
            onAddWorkflowId=>undef,
            onEditWorkflowId=>undef,
            onDeleteWorkflowId=>undef,
            sortBy=>undef,
            field_loop=>[],
            exportMetaData=>undef,
            maxEntriesPerUser=>undef,
            dateCreated=>$thing->get('dateCreated'),
            lastUpdated=>$thing->get('lastUpdated'),
            sequenceNumber=>$thing->get('sequenceNumber'),
        },
        'Getting newly added thing as JSON: www_getThingViaAjax returns correct data as JSON.'
    );

# Test getting all things in this Thingy as JSON, this should be an array containing only 
# the newly created thing.

$json = $thingy->www_getThingsViaAjax();
$dataFromJSON = JSON->new->decode($json);

my $thingPropertiesHashRef = {            
            assetId=>$thingy->getId,
            thingId=>$thingId,
            label=>$i18n->get('assetName'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            editInstructions=>'',
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            searchDescription=>'',
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
            display=>undef,
            onAddWorkflowId=>undef,
            onEditWorkflowId=>undef,
            onDeleteWorkflowId=>undef,
            sortBy=>undef,
            canEdit=>1,
            canAdd=>1,
            canSearch=>1,
            exportMetaData=>undef,
            maxEntriesPerUser=>undef,
            dateCreated=>$thing->get('dateCreated'),
            lastUpdated=>$thing->get('lastUpdated'),
            sequenceNumber=>$thing->get('sequenceNumber'),
        };

cmp_deeply(
        $dataFromJSON,
        [$thingPropertiesHashRef
        ],
        'Getting all things in Thingy as JSON: www_getThingsViaAjax returns correct data as JSON.'
    );

    

# Test adding a field

my %fieldProperties = (
    thingId=>$thingId,
    fieldId=>"new",
    label=>$i18n->get('assetName')." field",
    dateCreated=>time(),    
    fieldType=>"textarea",
    status=>"editable",
    display=>1,
);

my $fieldId = $thingy->addField(\%fieldProperties,0);

$isValidId = $session->id->valid($fieldId);

is($isValidId,1,"Adding a textarea field: addField returned a valid id: ".$fieldId);

my ($fieldLabel, $columnType, $Null, $Key, $Default, $Extra) = $session->db->quickArray("show columns from "
                                                                .$session->db->dbh->quote_identifier($thingTableName)
                                                                ." like ".$session->db->quote("Field_".$fieldId));

is($fieldLabel,"field_".$fieldId,"A column for the new field Field_$fieldId exists.");
is($columnType,"longtext","The columns is the right type");

# Test export function

my $exportData = $thingy->exportAssetData;

delete $exportData->{properties};
delete $exportData->{storage};

my $thingDatabasePropertiesHashRef = $thingPropertiesHashRef;
delete $thingDatabasePropertiesHashRef->{canAdd};
delete $thingDatabasePropertiesHashRef->{canEdit};
delete $thingDatabasePropertiesHashRef->{canSearch};

my $field = $session->db->quickHashRef('select * from Thingy_fields where fieldId=?',[$fieldId]);

cmp_deeply(
        $exportData,
        {
            things=>[
                $thingDatabasePropertiesHashRef
            ],
            fields=>[
                $field
            ]
        },
        'Export returns correct data.'
    );


# Test duplicating and deleting a Thing

my $duplicateThingId = $thingy->duplicateThing($thingId);

$isValidId = $session->id->valid($duplicateThingId);

is($isValidId,1,"duplicating a Thing: duplicateThing returned a valid id: ".$duplicateThingId);

my $duplicateThing = WebGUI::Asset::Wobject::Thingy::Thing->new($session, $duplicateThingId);
if (defined $duplicateThing) {
    $duplicateThing->delete;
}

my @things = @{ WebGUI::Asset::Wobject::Thingy::Thing->getAllIds($session,{constraints => [
                    {"assetId=?" => $thingy->getId},
                ]}) };
is(scalar @things,1,'Duplicated thing was deleted succesfully');

my ($thingTableCheck) = $session->db->quickArray("show tables like ?",['Thingy_'.$duplicateThingId]);

is($thingTableCheck,undef,"New table for duplicate Thing was deleted.");

# Test adding, editing, getting and deleting thing data

is($thing->hasEnteredMaxPerUser,0,"hasEnteredMaxPerUser returns 0 before adding a record");

my ($newThingDataId,$errors) = $thingy->editThingDataSave($thingId,'new',{"field_".$fieldId => 'test value'});
ok( ! $thing->hasEnteredMaxPerUser, 'hasEnteredMaxPerUser: returns false when maxEntriesPerUser=0 and 1 entry added');

my $isValidThingDataId = $session->id->valid($newThingDataId);

ok($isValidThingDataId, "Adding thing data: editFieldSave returned a valid id: ".$newThingDataId);

my $viewThingVars = $thingy->getViewThingVars($thingId,$newThingDataId);

cmp_deeply(
        $viewThingVars->{field_loop},
        [{
            field_id    => $fieldId,
            field_isHidden => "",
            field_value => 'test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field",
            field_isRequired => '',
            field_isVisible => '',
            field_pretext => undef,
            field_subtext => undef,
            field_type => "textarea",
        }],
        'Getting newly added thing data: getViewThingVars returns correct field_loop.'
    );

$json = $thingy->www_viewThingDataViaAjax($thingId,$newThingDataId);
$dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
        field_loop => [{
            field_id    => $fieldId,
            field_isHidden => "", 
            field_value => 'test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field",
            field_isRequired => '',
            field_isVisible => '',
            field_pretext => undef,
            field_subtext => undef,
            field_type => "textarea",
            }], 
        viewScreenTitle => "",
        },
        'Getting newly added thing data as JSON: www_viewThingDataViaAjax returns correct data as JSON.'
    );  

my ($updatedThingDataId,$errors) = $thingy->editThingDataSave($thingId,$newThingDataId,{"field_".$fieldId => 'new test value'});

my $viewThingVars = $thingy->getViewThingVars($thingId,$newThingDataId);

cmp_deeply(
        $viewThingVars->{field_loop},
        [{
            field_id    => $fieldId,
            field_isHidden => "",
            field_value => 'new test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field",
            field_isRequired => '',
            field_isVisible => '',
            field_pretext => undef,
            field_subtext => undef,
            field_type => "textarea",
        }],
        'Getting updated thing data: getViewThingVars returns correct field_loop with updated value.'
    );


$thingy->deleteThingData($thingId,$newThingDataId);

my @thingDataIds = @{WebGUI::Asset::Wobject::Thingy::ThingRecord->getAllIds($session)};

is(WebGUI::Utility::isIn(@thingDataIds,$newThingDataId),'0','Thing data was succesfully deleted');

=cut
$json = $thingy->www_viewThingDataViaAjax($thingId,$newThingDataId);
$dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
            message => "The thingDataId you requested can not be found.",
        },
        'Getting thing data as JSON after deleting: www_viewThingDataViaAjax returns correct message.'
    );

($newThingDataId,$errors) = $thingy->editThingDataSave($thingId,'new',{"field_".$fieldId => 'second test value'});
=cut

#################################################################
#
# maxEntriesPerUser
#
#################################################################

my %otherThingProperties = %thingProperties;
$otherThingProperties{maxEntriesPerUser} = 1;
$otherThingProperties{editTemplateId   } = $templateId;
my $otherThingId = $thingy->addThing(\%otherThingProperties, 0);
my $otherThing = WebGUI::Asset::Wobject::Thingy::Thing->new($session,$otherThingId); 
my %otherFieldProperties = %fieldProperties;
$otherFieldProperties{thingId} = $otherThingId;
my $otherFieldId = $thingy->addField(\%otherFieldProperties, 0);
ok( ! $otherThing->hasEnteredMaxPerUser($otherThingId), 'hasEnteredMaxPerUser: returns false with no data entered');

my @edit_thing_form_fields = qw/form_start form_end form_submit field_loop/;

{
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $thingy->editThingData($otherThingId);
    my %miniVars;
    @miniVars{@edit_thing_form_fields} = @{ $templateVars }{ @edit_thing_form_fields };
    cmp_deeply(
        \%miniVars,
        {
            form_start  => ignore,
            form_end    => ignore,
            form_submit => ignore,
            field_loop  => ignore,
        },
        'thing edit form variables exist, because max entries not reached yet'
    );
}

$thingy->editThingDataSave($otherThingId, 'new', {"field_".$otherFieldId => 'other test value'} );
ok( $otherThing->hasEnteredMaxPerUser($otherThingId), 'hasEnteredMaxPerUser returns true with one row entered, and maxEntriesPerUser=1');

{
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $thingy->editThingData($otherThingId);
    my %miniVars;
    @miniVars{@edit_thing_form_fields} = @{ $templateVars }{ @edit_thing_form_fields };
    my $existance = 0;
    foreach my $tmplVar (@edit_thing_form_fields) {
        $existance ||= exists $templateVars->{$tmplVar}
    }
    ok(
        ! $existance,
        'thing edit form variables do not exist, because max entries was reached'
    );
}

#################################################################
#
# deleteThing
#
#################################################################

$otherThing->delete;
my $count;
$count = $session->db->quickScalar('select count(*) from Thingy_things where thingId=?',[$otherThingId]);
is($count, 0, 'deleteThing: clears thing from Thingy_things');
$count = $session->db->quickScalar('select count(*) from Thingy_fields where thingId=?',[$otherThingId]);
is($count, 0, '... clears thing from Thingy_fields');
my $table = $session->db->dbh->table_info(undef, undef, 'Thingy_'.$otherThingId)->fetchrow_hashref();
is($table, undef, '... drops thing specific table');

#################################################################
#
# thing data permissions, getFormPlugin
#
#################################################################

{
    my %newThingProperties                = %thingProperties;
    $newThingProperties{'groupIdView'} = 3;
    my $newThingId                        = $thingy->addThing(\%newThingProperties, 0); 
    my %newFieldProperties                = %fieldProperties;
    $newFieldProperties{thingId}       = $newThingId;
    my $newFieldId                        = $thingy->addField(\%newFieldProperties, 0);
    $thingy->editThingDataSave($newThingId, 'new', {"field_".$newFieldId => 'value 1'} );
    $thingy->editThingDataSave($newThingId, 'new', {"field_".$newFieldId => 'value 2'} );
    $thingy->editThingDataSave($newThingId, 'new', {"field_".$newFieldId => 'value 3'} );

    my $andy = WebGUI::User->create($session);
    WebGUI::Test->usersToDelete($andy);
    $session->user({userId => $andy->userId});

    my $form = $thingy->getFormPlugin({
        name                => 'fakeFormForTesting',
        fieldType           => 'otherThing_'.$newThingId,
        fieldInOtherThingId => $newFieldId,
    });

    cmp_deeply(
        $form->get('options'),
        {},
        'getFormPlugin: form has no data since the user does not have viewing privileges'
    );
}

#################################################################
#
# getFieldValue
#
#################################################################
{
    my %newThingProperties             = %thingProperties;
    my $newThingId                     = $thingy->addThing(\%newThingProperties, 0); 
    my %newFieldProperties             = %fieldProperties;
    $newFieldProperties{thingId}       = $newThingId;
    $newFieldProperties{fieldType}     = 'Date';

    my $date = $thingy->getFieldValue(WebGUI::Test->webguiBirthday, \%newFieldProperties);
    like($date, qr{\d+/\d+/\d+}, "getFieldValue: Date field type returns data in user's format");

    $newFieldProperties{fieldType}     = 'DateTime';
    my $datetime = $thingy->getFieldValue(WebGUI::Test->webguiBirthday, \%newFieldProperties);
    like($datetime, qr{^\d+/\d+/\d+\s+\d+:\d+}, "... DateTime field also returns data in user's format");
}

