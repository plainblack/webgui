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

## The goal of this test is to test the creation and deletion of photo assets

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $gallery
    = WebGUI::Test->asset(
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "1024",
    );
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    });
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    });

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# setFile also makes download versions
$photo->setFile( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
my $storage = $photo->getStorageLocation;

cmp_deeply(
    $storage->getFiles, bag('page_title.jpg','1024.jpg'),
    "Storage location contains the resolution file",
);

ok(
    -e $storage->getPath($gallery->getImageResolutions->[0] . '.jpg'),
    "Generated resolution file exists on the filesystem",
);

#vim:ft=perl
