# $vim: syntax=perl
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

## The goal of this test is to test the thumbnails view of GalleryAlbums

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Test::Maker::HTML;

#----------------------------------------------------------------------------
# Init
my $maker           = WebGUI::Test::Maker::HTML->new;
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
$versionTag->set({name=>"Album Test"});
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdAddComment   => 2,   # Registered Users
        groupIdAddFile      => 2,   # Registered Users
        groupIdView         => 7,   # Everyone
        groupIdEdit         => 3,   # Admins
        ownerUserId         => 3,   # Admin
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
        ownerUserId         => "3", # Admin
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my @photos;
for my $i ( 0 .. 5 ) {
    $photos[ $i ] 
        = $album->addChild({
            className           => "WebGUI::Asset::File::GalleryFile::Photo",
            filename            => "$i.jpg",
        },
        undef,
        undef,
        {
            skipAutoCommitWorkflows => 1,
        });
}

$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 1;

TODO: {
    local $TODO = "Write some tests";
    ok(0, 'No tests here');
}

#----------------------------------------------------------------------------
# Test view_thumbnails

#----------------------------------------------------------------------------
# Test www_thumbnails

#vim:ft=perl
