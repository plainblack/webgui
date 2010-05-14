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
use lib "$FindBin::Bin/../../../lib";

## The goal of this test is to test the creation and deletion of album assets

use Scalar::Util;
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Album Test"});
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
    });

#----------------------------------------------------------------------------
# Tests
plan tests => 4;

#----------------------------------------------------------------------------
# Test module compiles okay
use_ok("WebGUI::Asset::Wobject::GalleryAlbum");

#----------------------------------------------------------------------------
# Test creating an album
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

$versionTag->commit;

is(
    Scalar::Util::blessed($album), "WebGUI::Asset::Wobject::GalleryAlbum",
    "Album is a WebGUI::Asset::Wobject::GalleryAlbum object",
);

isa_ok( 
    $album, "WebGUI::Asset::Wobject",
);

#----------------------------------------------------------------------------
# Test deleting a album
my $properties  = $album->get;
$album->purge;

is(
    WebGUI::Asset->newById($session, $properties->{assetId}), undef,
    "Album no longer able to be instanciated",
);


#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}
