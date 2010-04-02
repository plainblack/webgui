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

## The goal of this test is to test the creation and deletion of photo assets

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session    = WebGUI::Test->session;
my $node       = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);

$versionTag->set({name=>"Photo Test"});

addToCleanup($versionTag);

# Create gallery and a single album
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
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
    
# Create 5 photos inside the gallery
my @photo;

for (my $i = 0; $i < 5; $i++)
{
    $photo[$i]
        = $album->addChild({
            className           => "WebGUI::Asset::File::GalleryFile::Photo",
        },
        undef,
        undef,
        {
            skipAutoCommitWorkflows => 1,
        });
}

# Commit all changes
$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 11;

#----------------------------------------------------------------------------
# Test module compiles okay
# plan tests => 1
use_ok("WebGUI::Asset::File::GalleryFile::Photo");

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

