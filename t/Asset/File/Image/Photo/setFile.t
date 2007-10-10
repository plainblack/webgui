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
use lib "$FindBin::Bin/../../../../lib";

## The goal of this test is to test the creation and deletion of photo assets

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::File::Image::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoGallery",
        imageResolutions    => "1024x768",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoAlbum",
    });
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# setFile also makes download versions
$photo->setFile( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
my $storage = $photo->getStorageLocation;

is_deeply(
    $storage->getFiles, ['page_title.jpg'],
    "Storage location contains only the file we added",
);

ok(
    -e $storage->getPath($gallery->get('imageResolutions') . '.jpg'),
    "Generated resolution file exists on the filesystem",
);


