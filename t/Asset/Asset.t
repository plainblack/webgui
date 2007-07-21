#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Navigation;

use Test::More tests => 28; # increment this value for each test you create
use Test::MockObject;

my $session = WebGUI::Test->session;

# Test the default constructor
my $defaultAsset = WebGUI::Asset->getDefault($session);
is(ref $defaultAsset, 'WebGUI::Asset::Wobject::Layout','default constructor');

# Test the new constructor
my $assetId = "PBnav00000000000000001"; # one of the default nav assets

# - explicit class
my $asset = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Wobject::Navigation');
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation','new constructor explicit - ref check');
is ($asset->getId, $assetId, 'new constructor explicit - returns correct asset');

# - new by hashref properties
$asset = undef;
$asset = WebGUI::Asset->newByPropertyHashRef($session, {
                                                          className=>"WebGUI::Asset::Wobject::Navigation",
		                                                  assetId=>$assetId
													    });
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation', 'new constructor newByHashref - ref check');
is ($asset->getId, $assetId, 'new constructor newByHashref - returns correct asset');

# - implicit class
$asset = undef;
$asset = WebGUI::Asset::Wobject::Navigation->new($session, $assetId);
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation', 'new constructor implicit - ref check');
is ($asset->getId, $assetId, 'new constructor implicit - returns correct asset');

# - die gracefully
my $deadAsset = 1;

# -- no asset id
$deadAsset = WebGUI::Asset->new($session, '', 'WebGUI::Asset::Wobject::Navigation');
is ($deadAsset, undef,'new constructor with no assetId returns undef');

# -- no class
my $primevalAsset = WebGUI::Asset->new($session, $assetId);
isa_ok ($primevalAsset, 'WebGUI::Asset');

# Test the newByDynamicClass Constructor
$asset = undef;

$asset = WebGUI::Asset->newByDynamicClass($session, $assetId);
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation', 'newByDynamicClass constructor - ref check');
is ($asset->getId, $assetId, 'newByDynamicClass constructor - returns correct asset');

# - die gracefully
$deadAsset = 1;

# -- invalid asset id
$deadAsset = WebGUI::Asset->newByDynamicClass($session, 'RoysNonExistantAssetId');
is ($deadAsset, undef,'newByDynamicClass constructor with invalid assetId returns undef');

# -- no assetId
$deadAsset = 1;
$deadAsset = WebGUI::Asset->newByDynamicClass($session);
is ($deadAsset, undef, 'newByDynamicClass constructor with no assetId returns undef');

# Root Asset
my $rootAsset = WebGUI::Asset->getRoot($session);
isa_ok($rootAsset, 'WebGUI::Asset');
is($rootAsset->getId, 'PBasset000000000000001', 'Root Asset ID check');

# getMedia Constructor

my $mediaFolder = WebGUI::Asset->getMedia($session);
isa_ok($mediaFolder, 'WebGUI::Asset::Wobject::Folder');
is($mediaFolder->getId, 'PBasset000000000000003', 'Media Folder Asset ID check');

# getImportNode Constructor

my $importNode = WebGUI::Asset->getImportNode($session);
isa_ok($importNode, 'WebGUI::Asset::Wobject::Folder');
is($importNode->getId, 'PBasset000000000000002', 'Import Node Asset ID check');
is($importNode->getParent->getId, $rootAsset->getId, 'Import Nodes parent is Root Asset');

################################################################
#
# urlExists
#
################################################################

##We need an asset with a URL for this one.

my $importUrl = $importNode->get('url');
my $importId  = $importNode->getId;

ok(  WebGUI::Asset->urlExists($session, $importUrl),      'url for import node exists');
ok(  WebGUI::Asset->urlExists($session, uc($importUrl)),  'url for import node exists, case insensitive');
ok( !WebGUI::Asset->urlExists($session, '/foo/bar/baz'),  'made up url does not exist');

ok( !WebGUI::Asset->urlExists($session, $importUrl,     {assetId => $importId}),       'url for import node only exists at specific id');
ok( !WebGUI::Asset->urlExists($session, '/foo/bar/baz', {assetId => $importId}),       'imaginary url does not exist at specific id');
ok(  WebGUI::Asset->urlExists($session, $importUrl,     {assetId => 'notAnWebGUIId'}), 'imaginary url does not exist at wrong id');

################################################################
#
# addEditLabel
#
################################################################

my $i18n = WebGUI::International->new($session, 'Asset_Wobject');
is($importNode->addEditLabel, $i18n->get('edit').' '.$importNode->getName, 'addEditLabel, default mode is edit mode');

my $origRequest = $session->{_request};
my $newRequest = Test::MockObject->new();
my $func;
$newRequest->set_bound('body', \$func);
$session->{_request} = $newRequest;
$func = 'add';
is($importNode->addEditLabel, $i18n->get('add').' '.$importNode->getName, 'addEditLabel, use add mode');
$session->{_request} = $origRequest;
