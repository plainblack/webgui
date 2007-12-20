#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the editSave, 
# processPropertiesFromFormPost, and applyConstraints methods.

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

my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});

$session->user( { userId => 3 } ); # Admins can do everything

my $maker           = WebGUI::Test::Maker::HTML->new;
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
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
        className           => "WebGUI::Asset::File::Image::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests
plan no_plan => 1;

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
    object      => $album,
    method      => "www_editSave",
    formParams  => {
       assetId      => "new",
       className    => "WebGUI::Asset::File::Image::Photo",
    },
    test_regex  => [ 
        qr/You must select a file/,
        qr/You must enter a title/,
    ],
})->run;

#----------------------------------------------------------------------------
# Test editSave success result
# TODO: This test should use i18n
$maker->prepare({
    object      => $album,
    method      => "www_editSave",
    formParams  => {
       assetId      => "new",
       className    => "WebGUI::Asset::File::Image::Photo",
    },
    test_regex  => [ 
        qr/awaiting approval and commit/,
    ],
})->run;


#----------------------------------------------------------------------------
# Cleanup
END {
    foreach my $versionTag (@versionTags) {
        $versionTag->rollback;
    }
}


