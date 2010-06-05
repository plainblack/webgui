#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the getDownloadFileUrl and www_download()
# methods

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);

my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});
WebGUI::Test->addToCleanup($versionTags[-1]);

my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "100\n200\n300",
        groupIdView         => 7,
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
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# getResolutions returns an array reference of available resolutions
$photo->setFile( WebGUI::Test->getTestCollateralPath( "lamp.jpg" ) );
cmp_deeply(
    $photo->getResolutions,
    bag( "100.jpg", "200.jpg", "300.jpg" ),
    "getResolutions returns the correct array reference",
);

#----------------------------------------------------------------------------
# getDownloadFileUrl returns the URL to download the resolution
is(
    $photo->getDownloadFileUrl("100"),
    $photo->getStorageLocation->getUrl( "100.jpg" ),
    "getDownloadFileUrl returns the URL to download the resolution",
);

ok(
    !eval{ $photo->getDownloadFileUrl("400"); 1 },
    "getDownloadFileUrl croaks if resolution doesn't exist",
);

