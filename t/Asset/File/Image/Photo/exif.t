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
use JSON;
use Image::ExifTool;

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
$photo->setFile( WebGUI::Test->getTestCollateralPath("lamp.jpg") );
my $exifData    = $photo->get("exifData");

ok( defined $exifData, "exifData column is defined after setFile" );

my $exif        = jsonToObj( $exifData );
ok( ref $exif eq "HASH", "exifData is JSON hash" );

#----------------------------------------------------------------------------
# Test getTemplateVars exif data
my $var         = $photo->getTemplateVars;

is_deeply(
    [ sort keys %$exif ],
    [ sort map { s/exif_// } keys %$var ],
    "getTemplateVars gets a hash of all exif tags",
);

is_deeply(
    [ sort keys %$exif ],
    [ sort map { $_->{tag} } @{ $var->{exifLoop} } ],
    "getTemplateVars gets a loop over the tags",
);
