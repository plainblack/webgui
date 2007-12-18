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
use lib "$FindBin::Bin/../../lib";

use Test::MockObject;
my $mocker;
BEGIN {
    $mocker = Test::MockObject->new();
    $mocker->fake_module('WebGUI::Form::Image');
    $mocker->fake_new('WebGUI::Form::Image');
}

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Image;
use WebGUI::Storage::Image;
use WebGUI::Asset::File::Image;
use WebGUI::Form::File;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 7;

my $session = WebGUI::Test->session;

my $square = WebGUI::Image->new($session, 100, 100);
$square->setBackgroundColor('#0000FF');

##Create a storage location
my $storage = WebGUI::Storage::Image->create($session);

##Save the image to the location
$square->saveToStorageLocation($storage, 'square.png');

##Do a file existance check.

ok((-e $storage->getPath and -d $storage->getPath), 'Storage location created and is a directory');
cmp_bag($storage->getFiles, ['square.png'], 'Only 1 file in storage with correct name');

##Initialize an Image Asset with that filename and storage location

$session->user({userId=>3});
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Image Asset test"});
my $properties = {
	#     '1234567890123456789012'
	id => 'ImageAssetTest00000001',
	title => 'Image Asset Test',
	className => 'WebGUI::Asset::File::Image',
	url => 'image-asset-test',
};
my $defaultAsset = WebGUI::Asset->getDefault($session);
my $asset = $defaultAsset->addChild($properties, $properties->{id});

ok($asset->getStorageLocation, 'Image Asset getStorageLocation initialized');
ok($asset->get('storageId'), 'getStorageLocation updates Image asset object with storage location');
is($asset->get('storageId'), $asset->getStorageLocation->getId, 'Image Asset storageId and cached storageId agree');

$asset->update({
	storageId => $storage->getId,
	filename => 'square.png',
});

is($storage->getId, $asset->get('storageId'), 'Asset updated with correct new storageId');
is($storage->getId, $asset->getStorageLocation->getId, 'Cached Asset storage location updated with correct new storageId');

$versionTag->commit;

END {
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
}
