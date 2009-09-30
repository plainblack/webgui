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

use Test::MockObject;
my $mocker = Test::MockObject->new();
$mocker->fake_module('WebGUI::Form::File');
$mocker->fake_new('WebGUI::Form::File');

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset::File;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 10;

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
WebGUI::Test->tagsToRollback($versionTag);
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
ok($asset->get('storageId'), 'getStorageLocation updates asset object with storage location');
is($asset->get('storageId'), $asset->getStorageLocation->getId, 'Asset storageId and cached storageId agree');

$asset->update({
	storageId => $storage->getId,
	filename => $filename,
});

is($storage->getId, $asset->get('storageId'), 'Asset updated with correct new storageId');
is($storage->getId, $asset->getStorageLocation->getId, 'Cached Asset storage location updated with correct new storageId');

$versionTag->commit;

############################################
#
# getStorageFromPost
#
############################################

my $fileStorage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($fileStorage);
$mocker->set_always('getValue', $fileStorage->getId);
my $fileFormStorage = $asset->getStorageFromPost();
isa_ok($fileFormStorage, 'WebGUI::Storage', 'Asset::File::getStorageFromPost');

############################################
#
# www_view
#
############################################

$session->config->set('enableStreamingUploads', '0');
$asset->www_view;
is($session->http->getRedirectLocation, $storage->getUrl('someScalarFile.txt'), 'www_view: sets a redirect');

$session->config->set('enableStreamingUploads', '1');
$session->http->setRedirectLocation('');
$asset->www_view;
is($session->http->getRedirectLocation, '', '... redirect not set when enableStreamingUploads is set');
