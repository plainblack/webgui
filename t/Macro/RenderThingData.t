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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::Macro::RenderThingData;
use WebGUI::Asset::Wobject::Thingy;

use Test::More; # increment this value for each test you create
use Test::MockObject;
use Test::Deep;

my $templateId = 'PICKLANGUAGE_TEMPLATE_';
my $templateId = 'VIEW_THING_DATA_TEMPL8T';
my $templateUrl = 'view_thing_data_template';
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
my $templateProcessed = 0;
$templateMock->mock('process', sub { $templateVars = $_[1]; $templateProcessed = 1; } );
my $session = WebGUI::Test->session;
WebGUI::Test->mockAssetId($templateId,   $templateMock);
WebGUI::Test->mockAssetUrl($templateUrl, $templateMock);

WebGUI::Test->addToCleanup(sub {
    WebGUI::Test->unmockAssetId($templateId);
    WebGUI::Test->unmockAssetUrl($templateUrl);
});

plan tests => 7;

my $node = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thingy Test"});
WebGUI::Test->addToCleanup($versionTag);
my $thingy = $node->addChild({
    className   => 'WebGUI::Asset::Wobject::Thingy',
    groupIdView => 7,
    url         => 'some_thing',
});
$versionTag->commit;
$thingy = $thingy->cloneFromDb;

my %thingProperties = (
    thingId           => "THING_RECORD",
    label             => 'Label',
    editScreenTitle   => 'Edit',
    editInstructions  => 'instruction_edit',
    groupIdAdd        => '3',
    groupIdEdit       => '3',
    saveButtonLabel   => 'save',
    afterSave         => 'searchThisThing',
    editTemplateId    => "ThingyTmpl000000000003",
    groupIdView       => '7',
    viewTemplateId    => "ThingyTmpl000000000002",
    defaultView       => 'searchThing',
    searchScreenTitle => 'Search',
    searchDescription => 'description_search',
    groupIdSearch     => '7',
    groupIdExport     => '7',
    groupIdImport     => '7',
    searchTemplateId  => "ThingyTmpl000000000004",
    thingsPerPage     => 25,
);
my $thingId = $thingy->addThing(\%thingProperties);
my $field1Id = $thingy->addField({
    thingId         => $thingId,
    fieldId         => "new",
    label           => "textual",
    dateCreated     => time(),
    fieldType       => "text",
    status          => "editable",
    display         => 1,
    displayInSearch => 1,
}, 0);

my ($thingDataId) = $thingy->editThingDataSave($thingId, 'new', {
    thingDataId       => 'new',
    "field_$field1Id" => 'texty',
});

my $thing_url = $thingy->getUrl('thingId='.$thingId.';thingDataId='.$thingDataId);
my $output;

$output = WebGUI::Macro::RenderThingData::process($session, $thing_url);
like $output, qr/specify a template/, 'returns an error message if no template is offered';
ok !$templateProcessed, 'template not processed';
$templateProcessed = 0;

$output = WebGUI::Macro::RenderThingData::process($session, $thing_url, $templateId);
ok $templateProcessed, 'passed templateId, template processed';
$templateProcessed = 0;

$output = WebGUI::Macro::RenderThingData::process($session, $thing_url, $templateUrl);
ok $templateProcessed, 'passed template url, template processed';
$templateProcessed = 0;

WebGUI::Test->originalConfig('gateway');
$session->config->set('gateway', '/gated');
my $thing_url = $thingy->getUrl('thingId='.$thingId.';thingDataId='.$thingDataId);

$output = WebGUI::Macro::RenderThingData::process($session, $thing_url, $templateId);
ok $templateProcessed, 'gateway set, passed templateId, template processed';
$templateProcessed = 0;

$output = WebGUI::Macro::RenderThingData::process($session, $thing_url, $templateUrl);
ok $templateProcessed, '... passed template url, template processed';
$templateProcessed = 0;

$output = WebGUI::Macro::RenderThingData::process($session, $thing_url, $templateUrl, "fakeAssetId");
ok $templateVars->{'callerAssetId'} eq 'fakeAssetId', '... passed callerAssetId, template var was passed';
$templateProcessed = 0;
