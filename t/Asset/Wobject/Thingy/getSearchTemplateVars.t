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

##The goal of this test is to test getSearchTemplateVariables

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
    groupIdView       => '7',
    viewTemplateId    => "ThingyTmpl000000000002",
    defaultView       => 'searchThing',
    searchScreenTitle => 'Search',
    searchDescription => 'description_search',
    groupIdSearch     => '7',
    groupIdExport     => $groupIdEdit,
    groupIdImport     => $groupIdEdit,
    searchTemplateId  => "ThingyTmpl000000000004",
    thingsPerPage     => 25,
);
my $thingId = $thingy->addThing(\%thingProperties);
%thingProperties = %{ $thingy->getThing($thingId) };

my $field1Id = $thingy->addField({
    thingId         => $thingId,
    fieldId         => "new",
    label           => "textual",
    dateCreated     => time(),
    fieldType       => "text",
    status          => "editable",
    display         => 1,
    searchIn        => 1,
    displayInSearch => 1,
}, 0);

is $thingy->getThings->rows, 1, 'Thingy has 1 thing';

my $fields = $session->db->quickScalar('select count(*) from Thingy_fields where assetId=? and thingId=?',[$thingy->getId, $thingId]);
is $fields, '1', 'Thingy has 1 field';

$thingy->editThingDataSave($thingId, 'new', {
    thingDataId       => 'new',
    "field_$field1Id" => 'texty',
});

$thingy->editThingDataSave($thingId, 'new', {
    thingDataId       => 'new',
    "field_$field1Id" => 'crusty',
});

$session->request->setup_body({
    thingId => $thingId,
});

my $vars;
$vars = $thingy->getSearchTemplateVars();
my @results;
@results = map { $_->{searchResult_field_loop}->[0]->{field_value} } @{ $vars->{searchResult_loop} };
cmp_bag(\@results, [qw/texty crusty/], 'with no func set, returns all data');

$session->request->setup_body({
    thingId => $thingId,
    func    => 'search',
    'field_'.$field1Id => 'texty',
});
$vars = $thingy->getSearchTemplateVars();
@results = map { $_->{searchResult_field_loop}->[0]->{field_value} } @{ $vars->{searchResult_loop} };
cmp_bag(\@results, [qw/texty/], 'with no func=search, returns only what we searched for');

$session->request->setup_body({
    thingId => $thingId,
    func    => 'searchViaAjax',
    'field_'.$field1Id => 'crusty',
});
$vars = $thingy->getSearchTemplateVars();
@results = map { $_->{searchResult_field_loop}->[0]->{field_value} } @{ $vars->{searchResult_loop} };
cmp_bag(\@results, [qw/crusty/], 'with no func=searchViaAjax, returns only what we searched for');
