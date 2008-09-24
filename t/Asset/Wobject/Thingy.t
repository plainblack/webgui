#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::PseudoRequest;
use Test::More tests => 12; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thingy Test"});
my $thingy = $node->addChild({className=>'WebGUI::Asset::Wobject::Thingy'});

# Test for a sane object type
isa_ok($thingy, 'WebGUI::Asset::Wobject::Thingy');

# Test to see if we can set new values
my $newThingySettings = {
	templateId=>'testingtestingtesting1',
	#searchRoot=>'testingtestingtesting2',
	#classLimiter=>'WebGUI::Asset::Wobject::Article',
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
);
my $thingId = $thingy->addThing(\%thingProperties,0); 

my $isValidId = $session->id->valid($thingId);

is($isValidId,1,"addThing returned a valid id: ".$thingId);

my $thingTableName = "Thingy_".$thingId;

my ($thingTableNameCheck) = $session->db->quickArray("show tables like ".$session->db->quote($thingTableName));

is($thingTableNameCheck,$thingTableName,"An empty table: ".$thingTableName." for the new thing exists.");

is($thingy->get('defaultThingId'),$thingId,"The Thingy assets defaultThingId was set correctly.");

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

# Test adding, editing and getting thing data

my ($newThingDataId,$errors) = $thingy->editThingDataSave($thingId,'new',{"field_".$fieldId => 'test value'});

my $isValidThingDataId = $session->id->valid($newThingDataId);

is($isValidId,1,"Adding thing data: editFieldSave returned a valid id: ".$newThingDataId);

my $viewThingVars = $thingy->getViewThingVars($thingId,$newThingDataId);

cmp_deeply(
        $viewThingVars->{field_loop},
        [{
            field_id    => $fieldId,
            field_isHidden => "",
            field_value => 'test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field"
        }],
        'Getting newly added field data: getViewThingVars returns correct field_loop.'
    );

$session->user({userId => 3});
my $json = $thingy->www_viewThingDataViaAjax($thingId,$newThingDataId);
my $dataFromJSON = JSON->new->utf8->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
        field_loop => [{
            field_id    => $fieldId,
            field_isHidden => "", 
            field_value => 'test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field"
            }], 
        viewScreenTitle => "",
        },
        'Getting newly added field data as JSON: www_viewThingDataViaAjax returns correct data as JSON.'
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
            field_label => $i18n->get('assetName')." field"
        }],
        'Getting updated field data: getViewThingVars returns correct field_loop with updated value.'
    );


END {
	# Clean up after thy self
	$versionTag->rollback();
}

