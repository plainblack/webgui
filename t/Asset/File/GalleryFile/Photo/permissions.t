#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Friends;
use Test::More; 
use WebGUI::Test::Maker::Permission;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $maker           = WebGUI::Test::Maker::Permission->new;

$session->user({ userId => 3 });
my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});
WebGUI::Test->tagsToRollback(@versionTags);

# Add a new user to the test user's friends list
my $friend  = WebGUI::User->new($session, "new");
WebGUI::Test->usersToDelete($friend);
WebGUI::Friends->new($session)->add( [ $friend->userId ] );

# Add a new registered user
my $notFriend   = WebGUI::User->new( $session, "new" );
WebGUI::Test->usersToDelete($notFriend);

my $gallery
    = $node->addChild({
        className       => "WebGUI::Asset::Wobject::Gallery",
        groupIdView     => "2",     # Registered Users
        groupIdEdit     => "3",     # Admins
        groupIdComment  => "2",     # Registered Users
        ownerUserId     => $session->user->userId,
    });

my $album
    = $gallery->addChild({
        className       => "WebGUI::Asset::Wobject::GalleryAlbum",
        groupIdView     => "2",     # Registered Users
        groupIdEdit     => "3",     # Admins
        ownerUserId     => $session->user->userId,
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

my $photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        friendsOnly     => 0,
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 40;

#----------------------------------------------------------------------------
# Photo inherits view from parent Album
$maker->prepare({
    object      => $photo,
    method      => 'canView',
    pass        => [ '3', $friend, $notFriend ],
    fail        => [ '1', ],
})->run;

#----------------------------------------------------------------------------
# Photo can only be edited by owner or those who can edit the parent album
$maker->prepare({
    object      => $photo,
    method      => 'canEdit',
    pass        => [ '3', ],
    fail        => [ '1', $notFriend, $friend, ],
})->run;

#----------------------------------------------------------------------------
# Photo can be commented on by those who can view and can comment on the 
# parent album and gallery.
$maker->prepare({
    object      => $photo,
    method      => 'canComment',
    pass        => [ '3', $friend, $notFriend ],
    fail        => [ '1', ],
})->run;

#----------------------------------------------------------------------------
# Photo set as friends only can only be viewed by owner's friends
$photo->update({ friendsOnly => 1, });
$maker->prepare({
    object      => $photo,
    method      => 'canView',
    pass        => [ '3', $friend ],
    fail        => [ '1', $notFriend ],
})->run;

#----------------------------------------------------------------------------
# Photo can be commented on by those who can view and can comment on the 
# parent album and gallery.
$maker->prepare({
    object      => $photo,
    method      => 'canComment',
    pass        => [ '3', $friend ],
    fail        => [ '1', $notFriend ],
})->run;

$photo->update({ friendsOnly => 0, });

#----------------------------------------------------------------------------
# Cleanup
