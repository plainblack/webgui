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

##The goal of this test is to test www_editThingDataSaveViaAjax, particularly those things not tested in Thingy.t

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 4; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thingy Test"});
WebGUI::Test->addToCleanup($versionTag);
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


#################################################################
#
# www_editThingDataSaveViaAjax
#
#################################################################

$session->request->setup_body({
    thingId     => $thingId,
    thingDataId => 'new',
    "field_".$field1Id => 'test value', 
    "field_".$field2Id => 'required', # required

});

$session->user({userId => '3'});
$session->response->status(200);
my $json = $thingy->www_editThingDataSaveViaAjax();
is $json, '{}', 'www_editThingDataSaveViaAjax: Empty JSON hash';
is $session->response->status, 200, '... http status=200';


$session->request->setup_body({   
	thingId     => $thingId,
	thingDataId => 'new',
	"field_".$field1Id => 'test value',
	"field_".$field2Id => '',
});

my $json = from_json( $thingy->www_editThingDataSaveViaAjax());



cmp_bag ($json,
      [
	superhashof ({
			field_name => "field_".$field2Id,
                     }),
      ],
      'checking for field_name in error json'
) or diag Dumper($json);





$fieldProperties{status} = 'required';
$fieldProperties{label}  = 'Required2';
my $field3Id = $thingy->addField(\%fieldProperties, 0);

$fieldProperties{status} = 'required';
$fieldProperties{label}  = 'Required3';
my $field4Id = $thingy->addField(\%fieldProperties, 0);


$session->request->setup_body({
        thingId     => $thingId,
        thingDataId => 'new',
        "field_".$field1Id => 'test value',
        "field_".$field2Id => '',
	"field_".$field3Id => '',
	"field_".$field4Id => '',

});



$json = from_json( $thingy->www_editThingDataSaveViaAjax());


cmp_bag ($json,
      [
       	superhashof ({
                       	field_name => "field_".$field2Id,
                     }),
       	superhashof ({
                       	field_name => "field_".$field3Id,
                     }),
       	superhashof ({
                       	field_name => "field_".$field4Id,
                     }),
      ],
      'checking for field_name in error json (3 required fields)'
) or diag Dumper($json);




