#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use Test::More tests => 6; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use WebGUI::Search;
use WebGUI::Search::Index;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Test->asset;

my $thingy = $node->addChild({
    className   => 'WebGUI::Asset::Wobject::Thingy',
    groupIdView => 7,
    url         => 'some_thing',
});
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 0, 'no records yet';
$thingy->commit;

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
    thingId     => $thingId,
    fieldId     => "new",
    label       => "textual",
    dateCreated => time(),
    fieldType   => "text",
    status      => "editable",
    display     => 1,
}, 0);

is $thingy->getThings->rows, 1, 'Thingy has 1 thing';

my $fields = $session->db->prepare('select fieldId from Thingy_fields where assetId=?');
$fields->execute([$thingy->getId]);
is $fields->rows, '1', 'Thingy has 1 field';

my $duplicated = $thingy->duplicate;
WebGUI::Test->addToCleanup($duplicated);
is $thingy->getThings->rows, 1, 'Thingy still has 1 thing';
is $duplicated->getThings->rows, 1, 'Duplicated thingy has 1 thing, too';

$fields->execute([$duplicated->getId]);
is $fields->rows, '1', 'Duplicated thingy has 1 field';
