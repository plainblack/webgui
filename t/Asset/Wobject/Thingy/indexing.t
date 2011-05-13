#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Test::MockTime qw/:all/;
use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";

##The goal of this test is to test editThingDataSave, particularly those things not tested in Thingy.t

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 24; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use WebGUI::Search;
use WebGUI::Search::Index;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

set_relative_time(-60);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thingy Test"});
WebGUI::Test->addToCleanup($versionTag);
my $thingy = $node->addChild({
    className   => 'WebGUI::Asset::Wobject::Thingy',
    groupIdView => 7,
    url         => 'some_thing',
    tagId       => $versionTag->getId,
    status      => "pending",
});
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 0, 'no records yet';
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
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 1, 'committing the asset adds a record';

$thingy->indexThing(\%thingProperties);

is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 2, 'indexThing: adds a record to the assetIndex';

my $record;

$record = $session->db->quickHashRef('select * from assetIndex where assetId=?',[$thingy->getId]);
cmp_deeply(
    $record,
    superhashof({
        subId       => 'THING_RECORD',
        url         => $thingy->getUrl('func=search;thingId=THING_RECORD'),
        title       => 'Label',
        groupIdView => 2,
        keywords    => all(
            re('Label'),
            re('Edit'),
            re('instruction_edit'),
            re('Search'),
            re('description_search'),
        ),
    }),
    '... correct record entered via indexThing'
);

$thingy->deleteThingIndex('THING_RECORD');
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 1, 'deleteThingIndex removes the record of the Thing from assetIndex';

$thingy->indexThing(\%thingProperties);
$thingProperties{saveButtonLabel} = 'Save';
$thingy->indexThing(\%thingProperties);
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 2, 'indexThing safely handles updating the same record';

$thingy->deleteThingIndex('THING_RECORD');

my $thingId = $thingy->addThing(\%thingProperties);
%thingProperties = %{ $thingy->getThing($thingId) };
$thingy->indexThing(\%thingProperties);
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 2, 'two index entries, setup for indexThingData';

my $field1Id = $thingy->addField({
    thingId     => $thingId,
    fieldId     => "new",
    label       => "textual",
    dateCreated => time(),
    fieldType   => "text",
    status      => "editable",
    display     => 1,
}, 0);

$thingy->indexThingData($thingId, {
    thingDataId => 'THING_DATA',
    "field_$field1Id" => 'texty',
});
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 2, 'indexThingData added no records, displayInSearch=0';

$thingy->deleteField($field1Id, $thingId);
$field1Id = $thingy->addField({
    thingId         => $thingId,
    fieldId         => "new",
    label           => "textual",
    dateCreated     => time(),
    fieldType       => "text",
    status          => "editable",
    display         => 1,
    displayInSearch => 1,
}, 0);

$thingy->indexThingData($thingId, {
    thingDataId       => 'THING_DATA',
    "field_$field1Id" => 'texty',
});
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 3, 'indexThingData added one record, displayInSearch=1';

$thingy->indexThingData($thingId, {
    thingDataId       => 'THING_DATA',
    "field_$field1Id" => 'texty',
});
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 3, 'indexThingData added 1 record';
my $search;
$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'texty'});
is @{ $search->getAssetIds }, 1, '... verify that it is the right record';
cmp_deeply(
    $search->getPaginatorResultSet->getPageData,
    [
    {
        assetId      => $thingy->getId,
        className    => 'WebGUI::Asset::Wobject::Thingy',
        creationDate => ignore(),
        groupIdEdit  => $groupIdEdit,
        groupIdView  => 2, ##From the thing
        ownerUserId  => 3,
        revisionDate => ignore(),
        score        => ignore(),
        synopsis     => ignore(),
        title        => 'Label', ##From the Thing's label
        url          => $thingy->getUrl('func=viewThingData;thingId='.$thingId.';thingDataId=THING_DATA'),
    }
    ],
    'Checking indexed data for the thingData'
);

$thingy->deleteThingDataIndex('THING_DATA');
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 2, 'deleteThingDataIndex deleted just 1 record';

my $field2Id = $thingy->addField({
    thingId         => $thingId,
    fieldId         => "new",
    label           => "dated",
    dateCreated     => time(),
    fieldType       => "date",
    status          => "editable",
    display         => 1,
    displayInSearch => 1,
    viewScreenTitle => 1,
}, 0);

my $birthday = WebGUI::Test->webguiBirthday;

$thingy->indexThingData($thingId, {
    thingDataId       => 'THING_DATA',
    "field_$field1Id" => 'texty',
    "field_$field2Id" => $birthday,
});
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?',[$thingy->getId]), 3, 'indexThingData added 1 record';

$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => $birthday});
is @{ $search->getAssetIds }, 0, 'birthday not added as a keyword';
$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'texty'});
is @{ $search->getAssetIds }, 1, 'texty added as a keyword';
$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'texty'});
cmp_deeply(
    $search->getPaginatorResultSet->getPageData,
    [
    {
        assetId      => $thingy->getId,
        className    => 'WebGUI::Asset::Wobject::Thingy',
        creationDate => ignore(),
        groupIdEdit  => $groupIdEdit,
        groupIdView  => 2, ##From the thing
        ownerUserId  => 3,
        revisionDate => ignore(),
        score        => ignore(),
        synopsis     => ignore(),
        title        => '8/16/2001', ##From viewScreenTitle, which is $birthday in user's preferred date format
        url          => $thingy->getUrl('func=viewThingData;thingId='.$thingId.';thingDataId=THING_DATA'),
    }
    ],
    'Checking indexed data for the thingData'
);


$thingy->deleteThingDataIndex('THING_DATA');

my $field3Id = $thingy->addField({
    thingId         => $thingId,
    fieldId         => "new",
    label           => "nailfile",
    dateCreated     => time(),
    fieldType       => "file",
    status          => "editable",
    display         => 1,
    displayInSearch => 1,
}, 0);

my $storage = WebGUI::Storage->create($session);
$storage->addFileFromScalar('filing.txt', 'filings');
WebGUI::Test->addToCleanup($storage);

$thingy->indexThingData($thingId, {
    thingDataId       => 'THING_DATA',
    "field_$field1Id" => 'texty',
    "field_$field2Id" => $birthday,
    "field_$field3Id" => $storage->getId,
});

$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'texty'});
is @{ $search->getAssetIds }, 1, 'texty added as a keyword';
$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'filings'});
is @{ $search->getAssetIds }, 1, 'filings added as a keyword from a file';

restore_time();

##Make a real data entry for indexContent
$thingy->deleteThingDataIndex('THING_DATA');
$thingy->editThingDataSave($thingId, 'new', {
    thingDataId       => 'new',
    "field_$field1Id" => 'texty',
    "field_$field2Id" => $birthday,
    "field_$field3Id" => $storage->getId,
});

$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], });
is @{ $search->getAssetIds }, 3, 'setup for indexContent, start with 3 records...';

my $updateTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($updateTag);
$thingy = $thingy->addRevision({ url => 'wild_thing', tagId => $updateTag->getId, status => "pending" });
$updateTag->commit;
$thingy = $thingy->cloneFromDb;

$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], });
is @{ $search->getAssetIds }, 3, '... end with 3 records';
my $records = $search->getResultSet();
my @urls;
while (my $record = $records->hashRef) {
    push @urls, $record->{url};
}

cmp_deeply(
    \@urls,
    array_each(re('wild_thing')),
    'All search URLs updated on commit'
) or diag Dumper(\@urls);

$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'texty'});
is @{ $search->getAssetIds }, 1, 'setup for deleteField, texty keyword has one hit';

$thingy->deleteField($field1Id, $thingId);

$search = WebGUI::Search->new($session)->search({ lineage => [$thingy->get('lineage')], keywords => 'texty'});
is @{ $search->getAssetIds }, 0, 'deleteField causes the thing to be reindexed';

