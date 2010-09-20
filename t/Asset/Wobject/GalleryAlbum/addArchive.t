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

use strict;

## The goal of this test is to test the permissions of GalleryAlbum assets

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);

$versionTag->set({name=>"Add Archive to Album Test"});
addToCleanup($versionTag);

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

# Properties applied to every photo in the archive
my $properties  = {
    keywords        => "something",
    location        => "somewhere",
    friendsOnly     => "1",
};

$versionTag->commit;


#----------------------------------------------------------------------------
# Tests
plan tests => 11;


#----------------------------------------------------------------------------
# Test the addArchive sub
# elephant_images.zip contains three jpgs: Aana1.jpg, Aana2.jpg, Aana3.jpg

$versionTag = WebGUI::VersionTag->getWorking($session);
$album->addArchive( WebGUI::Test->getTestCollateralPath('elephant_images.zip'), $properties );

my $images  = $album->getLineage(['descendants'], { returnObjects => 1 });

is( scalar @$images, 3, "addArchive() adds one asset per image" );
cmp_bag(
    [ map { $_->get("filename") } @$images ],
    [ "Aana1.jpg", "Aana2.jpg", "Aana3.jpg" ],
    "Names of files attached to Photo assets match filenames in archive"
);

cmp_bag(
    [ map { $_->get("title") } @$images ],
    [ "Aana1", "Aana2", "Aana3" ],
    "Titles of Photo assets match filenames in archive excluding extensions"
);

cmp_bag(
    [ map { $_->get("menuTitle") } @$images ],
    [ "Aana1", "Aana2", "Aana3" ],
    "Menu titles of Photo assets match filenames in archive excluding extensions"    
);

cmp_bag(
    [ map { $_->get("url") } @$images ],
    [
        $session->url->urlize( $album->getUrl . "/Aana1" ), 
        $session->url->urlize( $album->getUrl . "/Aana2" ), 
        $session->url->urlize( $album->getUrl . "/Aana3" ), 
    ],
    "URLs of Photo assets match filenames in archive excluding extensions"
);

cmp_bag(
    [ map { $_->get("keywords") } @$images ],
    [ "something", "something", "something" ],
    "Keywords of Photo assets match keywords in properties"
);

cmp_bag(
    [ map { $_->get("location") } @$images ],
    [ "somewhere", "somewhere", "somewhere" ],
    "Location of Photo assets match keywords in properties"
);

cmp_bag(
    [ map { $_->get("friendsOnly") } @$images ],
    [ "1", "1", "1" ],
    "Photo assets are viewable by friends only"
);

# Empty gallery album
$versionTag->rollback;

#----------------------------------------------------------------------------
# Test the sorting option of addArchive sub
# gallery_archive_sorting_test.zip contains four jpgs: photo1.jpg, photo2.jpg, photo3.jpg and photo4.jpg
# The following test covers sorting by date and name.  Testing fileOrder is not possible, because
# it's machine dependent.

$versionTag = WebGUI::VersionTag->getWorking($session);
# Add photos sorted by file order (default)
$album->addArchive( WebGUI::Test->getTestCollateralPath('gallery_archive_sorting_test.zip'), $properties, 'fileOrder' );
# Get all children
my $images  = $album->getLineage(['descendants'], { returnObjects => 1 });
# Check order
cmp_deeply(
    [ map { $_->get("filename") } @{ $images } ],
    [ "photo3.jpg", "photo2.jpg", "photo4.jpg", "photo1.jpg", ],
    "Photos sorted by file order (all files exist)"
);
# Empty gallery album
$versionTag->rollback;

$versionTag = WebGUI::VersionTag->getWorking($session);
# Add photos sorted by date
$album->addArchive( WebGUI::Test->getTestCollateralPath('gallery_archive_sorting_test.zip'), $properties, 'date' );
# Get all children
my $images  = $album->getLineage(['descendants'], { returnObjects => 1 });
# Check order
cmp_deeply(
    [ map { $_->get("filename") } @$images ],
    [ "photo4.jpg", "photo1.jpg", "photo3.jpg", "photo2.jpg" ],
    "Photos sorted by date"
);
# Empty gallery album
$versionTag->rollback;

$versionTag = WebGUI::VersionTag->getWorking($session);
# Add photos sorted by name
$album->addArchive( WebGUI::Test->getTestCollateralPath('gallery_archive_sorting_test.zip'), $properties, 'name' );
# Get all children
my $images  = $album->getLineage(['descendants'], { returnObjects => 1 });
# Check order
cmp_deeply(
    [ map { $_->get("filename") } @$images ],
    [ "photo1.jpg", "photo2.jpg", "photo3.jpg", "photo4.jpg" ],
    "Photos sorted by name"
);
# Empty gallery album
$versionTag->rollback;


#----------------------------------------------------------------------------
# Test the www_addArchive page
