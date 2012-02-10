#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::VersionTag;

#----------------------------------------------------------------------------
# Init
my $session    = WebGUI::Test->session;
my $node       = WebGUI::Asset->getImportNode($session);

# Create gallery and a single album
my $tag = WebGUI::VersionTag->getWorking($session);
my $gallery
    = WebGUI::Test->asset(
        className           => "WebGUI::Asset::Wobject::Gallery",
    );
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    });
    
# Create 5 photos inside the gallery
my @photo;

for (my $i = 0; $i < 5; $i++)
{
    $photo[$i]
        = $album->addChild({
            className           => "WebGUI::Asset::File::GalleryFile::Photo",
        });
}
$tag->commit;
WebGUI::Test->addToCleanup($tag);

foreach my $asset ($gallery, $album, @photo) {
    $asset = $asset->cloneFromDb;
}

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Test getFirstFile method

note('getFirstFile');
is( $photo[2]->getFirstFile->getId, $photo[0]->getId, 'First file is photo no. 1' );
is( $photo[0]->getFirstFile->getId, $photo[0]->getId, 'First file is still photo no. 1' );

#----------------------------------------------------------------------------
# Test getFirstFile method

note('getLastFile');
is( $photo[2]->getLastFile->getId, $photo[4]->getId, 'Last file is photo no. 5' );
is( $photo[4]->getLastFile->getId, $photo[4]->getId, 'Last file is still photo no. 5' );

#----------------------------------------------------------------------------
# Test getPreviousFile method

note('getPreviousFile');
is( $photo[2]->getPreviousFile->getId, $photo[1]->getId, 'Photo previous of photo no. 3 is photo no. 2' );
is( $photo[1]->getPreviousFile->getId, $photo[0]->getId, 'Photo previous of photo no. 2 is photo no. 1' );
is( $photo[0]->getPreviousFile, undef, 'Photo previous of photo no. 1 is undef' );

#----------------------------------------------------------------------------
# Test getNextFile method

note('getNextFile');
is( $photo[2]->getNextFile->getId, $photo[3]->getId, 'Photo next of photo no. 3 is photo no. 4' );
is( $photo[3]->getNextFile->getId, $photo[4]->getId, 'Photo next of photo no. 4 is photo no. 5' );
is( $photo[4]->getNextFile, undef, 'Photo next of photo no. 5 is undef' );

done_testing;
