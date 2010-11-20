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

# The goal of this test is to confirm correct rotation of all files attached
# to a Photo asset after calling the rotate method.
# We will only do a quick check by comparing dimensions of all attached files
# after rotation. Checks on individual pixels are alreay done in testing code
# for WebGUI::Storage

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session    = WebGUI::Test->session;
my $node       = WebGUI::Asset->getImportNode($session);

# Create gallery and a single album
my $gallery
    = WebGUI::Test->asset(
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "1024",
    );
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    });

# Create single photo inside the album    
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    });

# Attach image file to photo asset (setFile also makes download versions)
$photo->setFile( WebGUI::Test->getTestCollateralPath("rotation_test.png") );
my $storage = $photo->getStorageLocation;

#----------------------------------------------------------------------------

plan tests => 2;

#----------------------------------------------------------------------------

# Save dimensions of images
my @oldDims;
foreach my $file ( @{$storage->getFiles('showAll') } ) {    
    push ( @oldDims, [ $storage->getSizeInPixels($file) ] ) unless $file eq '.';
}

# Rotate photo (i.e. all attached images) by 90° CW
$photo->rotate(90);

# Save new dimensions of images in reverse order
my @newDims;
foreach my $file ( @{$storage->getFiles('showAll') } ) {
    push ( @newDims, [ reverse($storage->getSizeInPixels($file)) ] ) unless $file eq '.';
}

# Compare dimensions
cmp_deeply( \@oldDims, \@newDims, "Check if all files were rotated by 90° CW" );

# Rotate photo (i.e. all attached images) by 90° CCW
$photo->rotate(-90);

# Save new dimensions of images in original order
my @newerDims;
foreach my $file ( @{$storage->getFiles('showAll') } ) {
    push ( @newerDims, [ $storage->getSizeInPixels($file) ] ) unless $file eq '.';
}

# Compare dimensions
cmp_deeply( \@oldDims, \@newerDims, "Check if all files were rotated by 90° CCW" );
