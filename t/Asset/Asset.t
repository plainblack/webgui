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

use Test::More tests => 39; # increment this value for each test you create
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

# tempspace Constructor

my $tempNode = WebGUI::Asset->getTempspace($session);
isa_ok($tempNode, 'WebGUI::Asset::Wobject::Folder');
is($tempNode->getId, 'tempspace0000000000000', 'Tempspace Asset ID check');
is($tempNode->getParent->getId, $rootAsset->getId, 'Tempspace parent is Root Asset');

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

################################################################
#
# fixUrl
#
################################################################

is($importNode->fixUrl('1234'.'-'x235 . 'abcdefghij'), '1234'.'-'x235 . 'abcdefghij', 'fixUrl leaves long URLs under 250 characters alone');
is($importNode->fixUrl('1234'.'-'x250 . 'abcdefghij'), '1234'.'-'x216, 'fixUrl truncates long URLs over 250 characters to 220 characters');

my $origExtras   = $session->config->get('extrasURL');
my $origUploads  = $session->config->get('uploadsURL');
my $origPassthru = $session->config->get('passthruUrls');

$session->config->set('extrasURL',    '/extras');
$session->config->set('uploadsURL',   '/uploads');
$session->config->set('passthruUrls', [qw/pass1 pass2/]);

is($importNode->fixUrl('/extras'),  '_extras',  'underscore prepended to URLs that match the extrasURL');
is($importNode->fixUrl('/uploads'), '_uploads', 'underscore prepended to URLs that match the uploadsURL');
is($importNode->fixUrl('/pass1'),   '_pass1',   'underscore prepended to URLs that match any passthruUrl 1');
is($importNode->fixUrl('/pass2'),   '_pass2',   'underscore prepended to URLs that match any passthruUrl 2');

#Now that we have verified that extrasURL and uploadsURL both work, just test one.
$session->config->set('extrasURL',  '/extras1/');
is($importNode->fixUrl('/extras1'), '_extras1', 'trailing underscore in extrasURL does not defeat the check');

$session->config->set('extrasURL',  'http://mysite.com/extras2');
is($importNode->fixUrl('/extras2'), '_extras2', 'underscore prepended to URLs that match the extrasURL, even with http://');

END: {

    $session->config->set('extrasURL',    $origExtras);
    $session->config->set('uploadsURL',   $origUploads);
    if (defined $origPassthru) {
        $session->config->set('passthruUrls', $origPassthru);
    }
    else {
        $session->config->delete('passthruUrls');
    }
}
