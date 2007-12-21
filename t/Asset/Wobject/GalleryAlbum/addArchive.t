# $vim: syntax=perl
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
use lib "$FindBin::Bin/../../../lib";

## The goal of this test is to test the permissions of GalleryAlbum assets

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
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

$album->addArchive( WebGUI::Test->getTestCollateralPath('elephant_images.zip') );
$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# Test the addArchive sub
# elephant_images.zip contains three jpgs: Aana1.jpg, Aana2.jpg, Aana3.jpg
my $images  = $album->getLineage(['descendants'], { returnObjects => 1 });

is( scalar @$images, 3, "addArchive() adds one asset per image" );
cmp_deeply(
    [ map { $_->get("filename") } @$images ],
    bag( "Aana1.jpg", "Aana2.jpg", "Aana3.jpg" ),
);

#----------------------------------------------------------------------------
# Test the www_addArchive page

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}
