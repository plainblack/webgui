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

use WebGUI::Test;
use WebGUI::Macro::Thumbnail;
use WebGUI::Session;
use WebGUI::Image;
use WebGUI::Storage;
use Image::Magick;
use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 8;

my $session = WebGUI::Test->session;

is(
	WebGUI::Macro::Thumbnail::process($session, '/url-that-does-not-resolve'),
	undef,
	'non-existant URL returns undef'
);

my $square = WebGUI::Image->new($session, 100, 100);
$square->setBackgroundColor('#0000FF');

##Create a storage location
my $storage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($storage);

##Save the image to the location
$square->saveToStorageLocation($storage, 'square.png');

##Do a file existance check.

ok((-e $storage->getPath and -d $storage->getPath), 'Storage location created and is a directory');
cmp_bag($storage->getFiles, ['square.png'], 'Only 1 file in storage with correct name');

##Initialize an Image Asset with that filename and storage location

$session->user({userId=>3});
my $properties = {
	#     '1234567890123456789012'
	id => 'ThumbnailAsset00000001',
	title => 'Thumbnail macro test',
	className => 'WebGUI::Asset::File::Image',
	url => 'thumbnail-test',
};
my $defaultAsset = WebGUI::Test->asset;
$session->asset($defaultAsset);
my $asset = $defaultAsset->addChild($properties, $properties->{id});
$asset->update({
	storageId => $storage->getId,
	filename => 'square.png',
});

$asset->generateThumbnail();


##Call the Thumbnail Macro with that Asset's URL and see if it returns
##the correct URL.

my $output = WebGUI::Macro::Thumbnail::process($session, $asset->getUrl());
my $macroUrl = $storage->getPath('thumb-square.png');
is($output, $asset->getThumbnailUrl, 'Macro returns correct filename');

my $thumbUrl = $output;
substr($thumbUrl, 0, length($session->config->get("uploadsURL"))) = '';
my $thumbFile = $session->config->get('uploadsPath') . $thumbUrl;
my $fileExists = ok((-e $thumbFile), "file actually exists $thumbFile");

SKIP: {
    skip "File does not exist", 3 unless $fileExists;

    ##Load the image into some parser and check a few pixels to see if they're blue-ish.
    ##->Get('pixel[x,y]') hopefully returns color in hex triplets
    my $thumbImg = Image::Magick->new();
    $thumbImg->ReadImage($thumbFile);

    cmp_bag([$thumbImg->GetPixels(width=>1, height=>1, x=>25, y=>25, map=>'RGB', normalize=>'true')], [0,0,1], 'blue pixel #1');
    cmp_bag([$thumbImg->GetPixels(width=>1, height=>1, x=>75, y=>75, map=>'RGB', normalize=>'true')], [0,0,1], 'blue pixel #2');
    cmp_bag([$thumbImg->GetPixels(width=>1, height=>1, x=>50, y=>50, map=>'RGB', normalize=>'true')], [0,0,1], 'blue pixel #3');

}
