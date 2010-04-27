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
use lib "$FindBin::Bin/../../../../lib";

# Test the 'adjustOrientation' method called by 'applyConstraints'. It is 
# responsible for rotating JPEG images according to orientation information
# in EXIF data (if present). A number of test images have been created for 
# this purpose which are checked based on dimensions and pixel-wise.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset::File::GalleryFile::Photo;

use Image::Magick;
use Test::More; 
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);

# Name version tag and make sure it gets cleaned up
$versionTag->set({name=>"Orientation adjustment test"});
addToCleanup($versionTag);

# Create gallery and a single album
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "1024x768",        
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
    
# Create single photo inside the album    
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

# Commit all changes
$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 8;

#----------------------------------------------------------------------------
# Test adjustment of image with orientation set to 1

$photo->setFile( WebGUI::Test->getTestCollateralPath('orientation_1.jpg') );
my $storage = $photo->getStorageLocation;

# Check dimensions
cmp_deeply( [ $storage->getSizeInPixels($photo->get('filename')) ], [2, 3], "Check if image with orientation 1 was left as is (based on dimensions)" );

# Check single pixel
my $image = new Image::Magick;
$image->Read( $storage->getPath( $photo->get('filename') ) );
cmp_deeply( [ $image->GetPixel( x=>1, y=>1 ) ], [ 1, 1, 1], "Check if image with orientation 1 was left as is (based on pixel values)");

#----------------------------------------------------------------------------
# Test adjustment of image with orientation set to 3

# Attach new image to Photo asset
$photo->setFile( WebGUI::Test->getTestCollateralPath('orientation_3.jpg') );
my $storage = $photo->getStorageLocation;

# Check dimensions
cmp_deeply( [ $storage->getSizeInPixels($photo->get('filename')) ], [2, 3], "Check if image with orientation 3 was rotated by 180° (based on dimensions)" );

# Check single pixel
$image->Read( $storage->getPath( $photo->get('filename') ) );
cmp_deeply( [ $image->GetPixel( x=>2, y=>3 ) ], [ 1, 1, 1], "Check if image with orientation 3 was rotated by 180° (based on pixels)");


#----------------------------------------------------------------------------
# Test adjustment of image with orientation set to 6

# Attach new image to Photo asset
$photo->setFile( WebGUI::Test->getTestCollateralPath('orientation_6.jpg') );
my $storage = $photo->getStorageLocation;

# Check dimensions
cmp_deeply( [ $storage->getSizeInPixels($photo->get('filename')) ], [3, 2], "Check if image with orientation 6 was rotated by 90° CW (based on dimensions)" );

# Check single pixel
$image->Read( $storage->getPath( $photo->get('filename') ) );
cmp_deeply( [ $image->GetPixel( x=>3, y=>1 ) ], [ 1, 1, 1], "Check if image with orientation 6 was rotated by 90° CW (based on pixels)");


#----------------------------------------------------------------------------
# Test adjustment of image with orientation set to 8

# Attach new image to Photo asset
$photo->setFile( WebGUI::Test->getTestCollateralPath('orientation_8.jpg') );
my $storage = $photo->getStorageLocation;

# Check dimensions
cmp_deeply( [ $storage->getSizeInPixels($photo->get('filename')) ], [3, 2], "Check if image with orientation 8 was rotated by 90° CCW (based on dimensions)" );

# Check single pixel
$image->Read( $storage->getPath( $photo->get('filename') ) );
cmp_deeply( [ $image->GetPixel( x=>1, y=>2 ) ], [ 1, 1, 1], "Check if image with orientation 8 was rotated by 90° CCW (based on pixels)");
