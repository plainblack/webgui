#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use Test::MockObject;
my $mocker = Test::MockObject->new();
$mocker->fake_module('WebGUI::Form::File');
$mocker->fake_new('WebGUI::Form::File');

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset::File;
use JSON;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 18;

#TODO: This script tests certain aspects of WebGUI::Storage and it should not

my $session = WebGUI::Test->session;

##Create a storage location
my $storage = WebGUI::Storage->create($session);

##Save the image to the location
my $filename = "someScalarFile.txt";
$storage->addFileFromScalar($filename, $filename);

##Do a file existance check.

ok((-e $storage->getPath and -d $storage->getPath), 'Storage location created and is a directory');
cmp_bag($storage->getFiles, ['someScalarFile.txt'], 'Only 1 file in storage with correct name');

##Initialize an Image Asset with that filename and storage location

$session->user({userId=>3});
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"File Asset test"});
my $guard1 = WebGUI::Test::addToCleanup($versionTag);
my $properties = {
	#     '1234567890123456789012'
	id => 'FileAssetTest000000012',
	title => 'File Asset Test',
	className => 'WebGUI::Asset::File',
	url => 'file-asset-test',
};
my $defaultAsset = WebGUI::Asset->getDefault($session);
my $asset = $defaultAsset->addChild($properties, $properties->{id});

############################################
#
# getStorageLocation
#
############################################

ok($asset->getStorageLocation, 'File Asset getStorageLocation initialized');
ok($asset->storageId, 'getStorageLocation updates asset object with storage location');
is($asset->storageId, $asset->getStorageLocation->getId, 'Asset storageId and cached storageId agree');

$asset->update({
	storageId => $storage->getId,
	filename => $filename,
});

is($storage->getId, $asset->storageId, 'Asset updated with correct new storageId');
is($storage->getId, $asset->getStorageLocation->getId, 'Cached Asset storage location updated with correct new storageId');

$versionTag->commit;

############################################
#
# getStorageFromPost
#
############################################

my $fileStorage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($fileStorage);
$mocker->set_always('get',      $fileStorage->getId);
$mocker->set_always('getValue', $fileStorage->getId);
my $fileFormStorage = $asset->getStorageFromPost();
isa_ok($fileFormStorage, 'WebGUI::Storage', 'Asset::File::getStorageFromPost');

#----------------------------------------------------------------------------
# Test override of update to set permissions
$asset->update({ ownerUserId => '3', groupIdView => '3' });
my $privs   = JSON->new->decode( $asset->getStorageLocation->getFileContentsAsScalar('.wgaccess') );
cmp_deeply(
    $privs,
    {
        "assets"    => [],
        "groups"    => superbagof( "3" ),
        "users"     => ["3"],
    },
    'update sets the correct permissions in wgaccess',
);

#----------------------------------------------------------------------------
# Add another new revision, changing the privs
my $newRev  = $asset->addRevision( { ownerUserId => '3', groupIdView => '3' }, time + 5 );
WebGUI::Test->addToCleanup( $newRev );
$privs   = JSON->new->decode( $newRev->getStorageLocation->getFileContentsAsScalar('.wgaccess') );
cmp_deeply(
    $privs,
    {
        "assets"    => [],
        "groups"    => superbagof( "3" ),
        "users"     => ["3"],
    },
    'addRevision sets the correct permissions in wgaccess',
);

# Add a new revision, changing the privs
my $newRev  = $asset->addRevision( { groupIdView => '7' }, time + 8 );
WebGUI::Test->addToCleanup( $newRev );
is( $newRev->getStorageLocation->getFileContentsAsScalar('.wgaccess'), undef, "wgaccess doesn't exist" );

#----------------------------------------------------------------------------
# commit on new revision trashes old revision
$newRev->commit;
my $storage = $asset->getStorageLocation;
my $dir = $storage->getPathClassDir();
ok(-e $dir->file('.wgaccess')->stringify, 'commit: .wgaccess file created');
my $privs;
$privs = $storage->getFileContentsAsScalar('.wgaccess');
is ($privs, '{"state":"trash"}', '... correct state');

#----------------------------------------------------------------------------
# trash should update storage location
$asset  = $defaultAsset->addChild( $properties );
$asset->getStorageLocation->addFileFromScalar($filename, $filename);
$asset->update({
    filename => $filename,
});

WebGUI::Test->addToCleanup( $asset );
$asset->trash;
my $storage = $asset->getStorageLocation;
my $dir = $storage->getPathClassDir();
ok(-e $dir->file('.wgaccess')->stringify, 'trash: .wgaccess file created') 
    or note( $dir->file('.wgaccess')->stringify );
my $privs;
$privs = $storage->getFileContentsAsScalar('.wgaccess');
is ($privs, '{"state":"trash"}', '... correct state');

#----------------------------------------------------------------------------
# restore should de-trash storage location
$asset->restore;
unlike( $storage->getFileContentsAsScalar('.wgaccess'), qr{"state"\:"trash"}, "wgaccess not trashed" );

############################################
#
# www_view
#
############################################

$session->config->set('enableStreamingUploads', '0');
$asset->www_view;
is($session->response->location, $storage->getUrl('someScalarFile.txt'), 'www_view: sets a redirect');

$session->config->set('enableStreamingUploads', '1');
$session->response->location('');
$asset->www_view;
is($session->response->location, '', '... redirect not set when enableStreamingUploads is set');
