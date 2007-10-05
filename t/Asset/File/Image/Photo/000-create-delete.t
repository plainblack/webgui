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

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Tests
plan tests => 5;

#----------------------------------------------------------------------------
# Test module compiles okay
# plan tests => 1
use_ok("WebGUI::Asset::File::Image::Photo");

#----------------------------------------------------------------------------
# Test creating a photo
# plan tests => 2
my $photo
    = $node->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });

is(
    blessed $photo, "WebGUI::Asset::File::Image::Photo",
    "Photo is a WebGUI::Asset::File::Image::Photo object",
);

isa_ok( 
    $photo, "WebGUI::Asset::File::Image",
);

#----------------------------------------------------------------------------
# Test deleting a photo
# plan tests => 2
my $properties  = $photo->get;
$photo->purge;

is(
    $photo, undef
    "Photo is undefined",
);

is(
    WebGUI::Asset->newByDynamicClass($session, $properties->{assetId}), undef,
    "Photo no longer able to be instanciated",
);

