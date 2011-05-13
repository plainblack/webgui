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
use Test::More tests => 6; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Test->asset;
my $thingy = $node->addChild({className=>'WebGUI::Asset::Wobject::Thingy'});

# Test adding a new Thing
my $i18n        = WebGUI::International->new($session, "Asset_Thingy");
my $groupIdEdit = $thingy->get("groupIdEdit");
my %thingProperties = (
    thingId           => "new",
    label             => $i18n->get('assetName'),
    editScreenTitle   => $i18n->get('edit screen title label'),
    editInstructions  => '',
    groupIdAdd        => $groupIdEdit,
    groupIdEdit       => $groupIdEdit,
    saveButtonLabel   => $i18n->get('default save button label'),
    afterSave         => 'searchThisThing',
    editTemplateId    => "ThingyTmpl000000000003",
    groupIdView       => $groupIdEdit,
    viewTemplateId    => "ThingyTmpl000000000002",
    defaultView       => 'searchThing',
    searchScreenTitle => $i18n->get('search screen title label'),
    searchDescription => '',
    groupIdSearch     => $groupIdEdit,
    groupIdExport     => $groupIdEdit,
    groupIdImport     => $groupIdEdit,
    searchTemplateId  => "ThingyTmpl000000000004",
    thingsPerPage     => 25,
);

my $thingId = $thingy->addThing(\%thingProperties,0); 

# Test adding a field

my %fieldProperties = (
    thingId     => $thingId,
    fieldId     => "new",
    label       => "Optional",
    dateCreated => time(),
    fieldType   => "text",
    status      => "editable",
    display     => 1,
);

my $field1Id = $thingy->addField(\%fieldProperties, 0);
$fieldProperties{status} = 'required';
$fieldProperties{label}  = 'Required';
my $field2Id = $thingy->addField(\%fieldProperties, 0);

# Test adding, editing, getting and deleting thing data

my ($newThingDataId, $errors);
($newThingDataId, $errors) = $thingy->editThingDataSave($thingId, 'new',
    {
        "field_".$field1Id => 'test value',
        "field_".$field2Id => 'test value',
    },
);

cmp_deeply(
    $errors,
    [],
    'no errors for a valid thing data save'
);

ok $session->id->valid($newThingDataId), 'valid GUID for saved field'; 

my $row_exists = $session->db->quickScalar('select count(*) from `Thingy_'.$thingId.'`');
is $row_exists, 1, 'data written to the database';

($newThingDataId, $errors) = $thingy->editThingDataSave($thingId, 'new',
    {
        "field_".$field1Id => 'another test value',
    },
);

is scalar @{ $errors }, 1, 'one error due to missing, required field';
is $newThingDataId, '', '... no row id returned';

$row_exists = $session->db->quickScalar('select count(*) from `Thingy_'.$thingId.'`');
is $row_exists, 1, '... no new data written to the datbase';
