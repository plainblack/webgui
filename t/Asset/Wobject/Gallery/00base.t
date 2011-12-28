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

## The goal of this test is to test the creation and deletion of gallery assets

use Scalar::Util;
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Gallery Test"});
WebGUI::Test->addToCleanup($versionTag);

#----------------------------------------------------------------------------
# Tests
plan tests => 4;

#----------------------------------------------------------------------------
# Test module compiles okay
use_ok("WebGUI::Asset::Wobject::Gallery");

my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
    });

$versionTag->commit;
WebGUI::Test->addToCleanup($versionTag);
$gallery->cloneFromDb;

is(
    Scalar::Util::blessed($gallery), "WebGUI::Asset::Wobject::Gallery",
    "Gallery is a WebGUI::Asset::Wobject::Gallery object",
);

isa_ok( 
    $gallery, "WebGUI::Asset::Wobject",
);

#----------------------------------------------------------------------------
# Test adding children to Gallery

# Only GalleryAlbums may be added


#----------------------------------------------------------------------------
# Test deleting a gallery
my $properties  = $gallery->get;
$gallery->purge;

eval { WebGUI::Asset->newById($session, $properties->{assetId}); };
ok( Exception::Class->caught(), 'Gallery no longer able to be instanciated after purge');

#vim:ft=perl
