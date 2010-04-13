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

## The goal of this test is to test the permissions of GalleryAlbum assets

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Test::Maker::Permission;

#----------------------------------------------------------------------------
# Init
my $maker           = WebGUI::Test::Maker::Permission->new;
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);

my %user;
$user{"2"}          = WebGUI::User->new( $session, "new" );
$user{"2"}->addToGroups( ['2'] ); # Registered user
WebGUI::Test->usersToDelete($user{'2'});

my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Album Test"});
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

$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 36;

#----------------------------------------------------------------------------
# By default, GalleryAlbum inherits its permissions from the Gallery, but 
# only the owner of the GalleryAlbum is allowed to add files
$maker->prepare({
    object      => $album,
    method      => "canView",
    pass        => [ 1, 3, $user{"2"}, ],
}, {
    object      => $album,
    method      => "canEdit",
    pass        => [ 3, ],
    fail        => [ 1, $user{"2"}, ],
}, {
    object      => $album,
    method      => "canAddFile",
    pass        => [ 3, ],
    fail        => [ 1, $user{"2"}, ], 
}, {
    object      => $album, 
    method      => "canComment",
    pass        => [ 3, $user{"2"}, ],
    fail        => [ 1, ],
});
$maker->run;

#----------------------------------------------------------------------------
# GalleryAlbums with "allowComments" false do not allow anyone to comment
$album->update({ allowComments   => 0 });
$maker->prepare({
    object      => $album,
    method      => "canComment",
    fail        => [ 1, 3, $user{"2"}, ],
});
$maker->run;

#----------------------------------------------------------------------------
# GalleryAlbum with "othersCanAdd" true allows anyone who can add files to
# the Gallery to add files to this GalleryAlbum
$album->update({ othersCanAdd   => 1 });
$maker->prepare({
    object      => $album,
    method      => "canAddFile",
    pass        => [ 3, $user{"2"}, ],
    fail        => [ 1, ],
});
$maker->run;
