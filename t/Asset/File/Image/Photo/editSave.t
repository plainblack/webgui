#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the editSave and 
# processPropertiesFromFormPost methods.

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Test::Maker::HTML;
use WebGUI::Asset::File::Image::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $maker           = WebGUI::Test::Maker::HTML->new;
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoGallery",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoAlbum",
    });
my $photo
    = $gallery->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Tests
plan tests => 0;

#----------------------------------------------------------------------------
# Test permissions

# Edit an existing photo
$maker->prepare({
    object      => $photo,
    method      => "www_edit",
    userId      => "1",
    test_privilege  => "insufficient",
})->run;

# Save a new photo
$maker->prepare({
    object      => $photo,
    method      => "www_editSave",
    userId      => "1",
    test_privilege  => "insufficient",
})->run;

#----------------------------------------------------------------------------
# Test processPropertiesFromFormPost errors
# TODO: This test should use i18n.
# TODO: This error / test should occur in File, not Photo
$maker->prepare({
    object      => $album
    method      => "www_editSave",
    formParams  => {


    },
    test_regex  => [ 
        qr/You must select a file/,
        qr/You must enter a title/,
    ],
})->run;

#----------------------------------------------------------------------------
# Test editSave success result

#----------------------------------------------------------------------------
