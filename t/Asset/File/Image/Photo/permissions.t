#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# Test permissions of Photo assets

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Friends;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my ($photo);
$session->user({ userId => 3 });

my $friend  = WebGUI::User->new($session, "new");
WebGUI::Friends->new($session)->add( [ $friend->userId ] );

my $gallery
    = $node->addChild({
        className       => "WebGUI::Asset::Wobject::Gallery",
        groupIdView     => "7",
        groupIdEdit     => "3",
        ownerUserId     => $session->user->userId,
    });
my $album
    = $gallery->addChild({
        className       => "WebGUI::Asset::Wobject::GalleryAlbum",
        groupIdView     => "",
        groupIdEdit     => "",
        ownerUserId     => $session->user->userId,
    });


#----------------------------------------------------------------------------
# Cleanup
END {
    WebGUI::Friends->new($session)->delete( [ $friend->userId ] );
    $friend->delete;
    $versionTag->rollback;
}

#----------------------------------------------------------------------------
# Tests
plan no_plan => 1;

#----------------------------------------------------------------------------
# Everyone can view, Admins can edit, Owned by current user
$photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::Image::Photo",
        groupIdView     => "7",
        groupIdEdit     => "3",
        ownerUserId     => $session->user->userId,
    });

ok(  $photo->canView(1),        "Visitor can view"                      );
ok( !$photo->canEdit(1),        "Visitor cannot edit"                   );
ok(  $photo->canView(2),        "Registered users can view"             );
ok( !$photo->canEdit(2),        "Registered users cannot edit"          );
ok(  $photo->canView,           "Current user can view"                 );
ok(  $photo->canEdit,           "Current user can edit"                 );

#----------------------------------------------------------------------------
# Admins can view, Admins can edit, Owned by Admin, current user is Visitor
my $oldUser = $session->user;
$session->user( { user => WebGUI::User->new($session, "1") } );
$photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::Image::Photo",
        groupIdView     => "3",
        groupIdEdit     => "3",
        ownerUserId     => "3",
    });

ok( !$photo->canView,           "Visitors cannot view"                  );
ok( !$photo->canEdit,           "Visitors cannot edit"                  );
ok( !$photo->canView(2),        "Registered Users cannot view"          );
ok( !$photo->canEdit(2),        "Registered Users cannot edit"          );
ok(  $photo->canView(3),        "Admins can view"                       );
ok(  $photo->canEdit(3),        "Admins can edit"                       );
$session->user( { user => $oldUser } );

#----------------------------------------------------------------------------
# Photo without specific view/edit inherits from gallery properties
$photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::Image::Photo",
        groupIdView     => "",
        groupIdEdit     => "",
        ownerUserId     => $session->user->userId,
    });

ok( $photo->canView(1),         "Visitors can view"                     );
ok( !$photo->canEdit(1),        "Visitors cannot edit"                  );
ok( $photo->canView(2),         "Registered Users can view"             );
ok( !$photo->canEdit(2),        "Registered Users cannot edit"          );
ok( $photo->canView,            "Owner can view"                        );
ok( $photo->canEdit,            "Owner can edit"                        );
ok( $photo->canView(3),         "Admin can view"                        );
ok( $photo->canEdit(3),         "Admin can edit"                        );

#----------------------------------------------------------------------------
# Friends are allowed to view friendsOnly photos
$photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::Image::Photo",
        groupIdEdit     => "",
        ownerUserId     => $session->user->userId,
    });

ok( !$photo->canView(1),        "Visitors cannot view"                  );
ok( !$photo->canEdit(1),        "Visitors cannot edit"                  );
ok( !$photo->canView(2),        "Registered Users cannot view"          );
ok( !$photo->canEdit(2),        "Registered Users cannot edit"          );
ok( $photo->canView,            "Owner can view"                        );
ok( $photo->canEdit,            "Owner can edit"                        );
ok( $photo->canView(3),         "Admin can view"                        );
ok( $photo->canEdit(3),         "Admin can edit"                        );
