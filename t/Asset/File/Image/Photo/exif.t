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

## The goal of this test is to test the EXIF functionality of WebGUI's photo
# asset

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    });
my ( $photo );

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Tests
plan no_plan => 1;

#----------------------------------------------------------------------------
# Test that exif data gets parsed from the file
$photo
    = $album->addChild({
        className               => "WebGUI::Asset::File::Image::Photo",
    });
$photo->setFile( WebGUI::Test->getCollateralPath("lamp.jpg") );
my $exif    = $photo->get("exifData");
