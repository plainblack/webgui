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
use lib "$FindBin::Bin/../../../lib";

##The goal of this test is to test editThingDataSave, particularly those things not tested in Thingy.t

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 2; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use WebGUI::Search;
use WebGUI::Search::Index;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
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

# Test indexThing, without needing a real thing
my $groupIdEdit = $thingy->get("groupIdEdit");
my %thingProperties = (
    thingId           => "THING_RECORD",
    label             => 'Label',
    editScreenTitle   => 'Edit',
    editInstructions  => 'instruction_edit',
    groupIdAdd        => $groupIdEdit,
    groupIdEdit       => $groupIdEdit,
    saveButtonLabel   => 'save',
    afterSave         => 'searchThisThing',
    editTemplateId    => "ThingyTmpl000000000003",
    groupIdView       => '2',
    viewTemplateId    => "ThingyTmpl000000000002",
    defaultView       => 'searchThing',
    searchScreenTitle => 'Search',
    searchDescription => 'description_search',
    groupIdSearch     => $groupIdEdit,
    groupIdExport     => $groupIdEdit,
    groupIdImport     => $groupIdEdit,
    searchTemplateId  => "ThingyTmpl000000000004",
    thingsPerPage     => 25,
);
my $thingId = $thingy->addThing(\%thingProperties);
%thingProperties = %{ $thingy->getThing($thingId) };

my $field1Id = $thingy->addField({
    thingId      => $thingId,
    fieldId      => "new",
    label        => "dated",
    dateCreated  => time(),
    fieldType    => "Date",
    defaultValue => '2011-07-04',
    status       => "editable",
    display      => 1,
}, 0);

my $field1 = $thingy->getFields($thingId)->hashRef;

note 'getFieldValue';
is $thingy->getFieldValue(WebGUI::Test->webguiBirthday, $field1), '8/16/2001', 'with epoch as default';
is $thingy->getFieldValue('2011-07-04', $field1), '7/3/2011', 'with mysql date as default';
