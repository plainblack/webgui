# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the Account FriendManager
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Test the edit page of the friends manager

# Start a session
my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );

# Get our admin
my $admin   = WebGUI::User->new( $mech->session, "3" );

# Add a user who can be a friend for admin
my $edgar_friendly = WebGUI::Test->user( username => 'edgarfriendly', ableToBeFriend => 1 );
$edgar_friendly = WebGUI::User->new( $mech->session, $edgar_friendly->getId ); # fix the session

# Add a user who is not very nice
my $simon_phoenix = WebGUI::Test->user( username => 'simonphoenix', ableToBeFriend => 0 );
$simon_phoenix = WebGUI::User->new( $mech->session, $simon_phoenix->getId ); # fix the session

$mech->session->user({ user => $admin });

$mech->get_ok( '/?op=account;module=friendManager;do=editFriends;userId=3;groupName=Registered%20Users', "friend manager" );
$mech->content_lacks( $simon_phoenix->getId, "simon isn't friendly" );
$mech->submit_form_ok(
    {
        form_name => "friendManager",
        fields => {
            userToAdd => $edgar_friendly->getId,
        },
    },
    "submit form to add a friend"
);
ok( $admin->friends->hasUser( $edgar_friendly ), "friend was added" );

$mech->get_ok( '/?op=account;module=friendManager;do=editFriends;userId=3;groupName=Registered%20Users', "friend manager" );
$mech->content_lacks( $simon_phoenix->getId, "simon isn't friendly" );
$mech->submit_form_ok(
    {
        form_name => "friendManager",
        fields => {
            friendToAxe => $edgar_friendly->getId,
        },
    },
    "submit form to axe a friend"
);

# Instance a new group with the same ID as the admin's friends group.
# There is some stale cache problem with using $admin->friends directly
ok( !WebGUI::Group->new( $session, $admin->get('friendsGroup') )->hasUser( $edgar_friendly ), "friend was removed" );

TODO: {
    local $TODO = "Fix this stale cache problem";
    ok( !$admin->friends->hasUser( $edgar_friendly ), "friend was removed" );
};

done_testing;

#vim:ft=perl
