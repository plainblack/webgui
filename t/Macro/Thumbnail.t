#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use WebGUI::Image;
use WebGUI::Storage::Image;

use Image::Magick;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 7;

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'Thumbnail'}) {
	Macro_Config::insert_macro($session, 'Thumbnail', 'Thumbnail');
}

my $square = WebGUI::Image->new($session, 100, 100);
$square->setBackgroundColor('#0000FF');

##Create a storage location
my $storage = WebGUI::Storage::Image->create($session);

##Save the image to the location
diag ref $storage;
$square->saveToStorageLocation($storage, 'square.png');

##Do a file existance check.

ok((-e $storage->getPath and -d $storage->getPath), 'Storage location created and is a directory');
cmp_bag($storage->getFiles, ['square.png'], 'Only 1 file in storage with correct name');

##Initialize an Image Asset with that filename and storage location

$session->user({userId=>3});
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thumbnail macro test"});
my $properties = {
	#     '1234567890123456789012'
	id => 'ThumbnailAsset00000001',
	title => 'Thumbnail macro test',
	className => 'WebGUI::Asset::File::Image',
	url => 'thumbnail-test',
	storageId => $storage->getId,
	filename => 'square.png',
};
my $defaultAsset = WebGUI::Asset->getDefault($session);
$session->asset($defaultAsset);
my $asset = $defaultAsset->addChild($properties, $properties->{id});
$versionTag->commit;

$asset->generateThumbnail();

##Call the Thumbnail Macro with that Asset's URL and see if it returns
##the correct URL.

my $macroText = sprintf q!^Thumbnail("%s");!, $asset->getUrl();
WebGUI::Macro::process($session, \$macroText);
my $macroUrl = $storage->getPath('thumb-square.png');
is($macroText, $asset->getThumbnailUrl, 'Macro returns correct filename');

my $thumbUrl = $asset->getThumbnailUrl;
substr($thumbUrl, 0, length($session->config->get("uploadsURL"))) = '';
my $thumbFile = $session->config->get('uploadsPath') . $thumbUrl;
ok((-e $thumbFile), 'file actually exists');

##Load the image into some parser and check a few pixels to see if they're blue-ish.
##->Get('pixel[x,y]') hopefully returns color in hex triplets
my $thumbImg = Image::Magick->new();
$thumbImg->Read(filename => $thumbFile);

cmp_bag([$thumbImg->GetPixels(width=>1, height=>1, x=>25, y=>25, map=>'RGB', normalize=>'true')], [0,0,1], 'blue pixel #1');
cmp_bag([$thumbImg->GetPixels(width=>1, height=>1, x=>75, y=>75, map=>'RGB', normalize=>'true')], [0,0,1], 'blue pixel #2');
cmp_bag([$thumbImg->GetPixels(width=>1, height=>1, x=>50, y=>50, map=>'RGB', normalize=>'true')], [0,0,1], 'blue pixel #3');

END {
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
	##Storage is cleaned up by rolling back the version tag
}
