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
use lib "$FindBin::Bin/../../lib";

use Test::MockObject;
my $mocker;
BEGIN {
    $mocker = Test::MockObject->new();
    $mocker->fake_module('WebGUI::Form::Image');
    $mocker->fake_new('WebGUI::Form::Image');
}

use File::Copy;
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Image;
use WebGUI::Storage;
use WebGUI::Asset::File::Image;
use WebGUI::Form::File;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 13;

my $session = WebGUI::Test->session;

my $rectangle = WebGUI::Image->new($session, 100, 200);
$rectangle->setBackgroundColor('#0000FF');

##Create a storage location
my $storage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($storage);

##Save the image to the location
$rectangle->saveToStorageLocation($storage, 'blue.png');

##Do a file existance check.

ok((-e $storage->getPath and -d $storage->getPath), 'Storage location created and is a directory');
cmp_bag($storage->getFiles, ['blue.png'], 'Only 1 file in storage with correct name');

##Initialize an Image Asset with that filename and storage location

$session->user({userId=>3});
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Image Asset test"});
my $properties = {
	#            '1234567890123456789012'
	id        => 'ImageAssetTest00000001',
	title     => 'Image Asset Test',
	className => 'WebGUI::Asset::File::Image',
	url       => 'image-asset-test',
};
my $defaultAsset = WebGUI::Asset->getDefault($session);
my $asset = $defaultAsset->addChild($properties, $properties->{id});

ok($asset->getStorageLocation, 'Image Asset getStorageLocation initialized');
ok($asset->storageId, 'getStorageLocation updates Image asset object with storage location');
is($asset->storageId, $asset->getStorageLocation->getId, 'Image Asset storageId and cached storageId agree');

$asset->update({
	storageId => $storage->getId,
	filename => 'blue.png',
});

my $filename = $asset->getStorageLocation->getPath($asset->filename);
ok(-e $filename, 'file exists in the storage location for following tests');

my @stat_before = stat($filename);
ok($asset->getStorageLocation->rotate($asset->filename, 90), 'rotate worked');
my @stat_after = stat($filename);
is(isnt_array(\@stat_before, \@stat_after), 1, 'Image is different after rotation');

@stat_before = stat($filename);
$asset->getStorageLocation->resize($asset->filename, 200, 300);
my @stat_after = stat($filename);
is(isnt_array(\@stat_before, \@stat_after), 1, 'Image is different after resize');

@stat_before = stat($filename);
$asset->getStorageLocation->crop($asset->filename, 100, 125, 10, 25);
my @stat_after = stat($filename);
is(isnt_array(\@stat_before, \@stat_after), 1, 'Image is different after crop');

my $sth = $session->db->read('describe ImageAsset annotations');
isnt($sth->hashRef, undef, 'Annotations column is defined');

is($storage->getId, $asset->storageId, 'Asset updated with correct new storageId');
is($storage->getId, $asset->getStorageLocation->getId, 'Cached Asset storage location updated with correct new storageId');

$versionTag->commit;
addToCleanup($versionTag);

sub isnt_array {
    my ($a, $b) = @_;

    for (my $i = 0; $i < @{ $a }; ++$i) {
        return 1 if @{ $a }[$i] ne @{ $b }[$i];
    }

    return 0;
}
