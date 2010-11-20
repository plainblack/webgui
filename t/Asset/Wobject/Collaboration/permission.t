# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Maker::Permission;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user( { userId => 3 } );
my $maker           = WebGUI::Test::Maker::Permission->new;
my $node            = WebGUI::Test->asset;

my %user;
$user{"2"}          = WebGUI::User->new( $session, "new" );
$user{"2"}->addToGroups( ['2'] ); # Registered user
WebGUI::Test->addToCleanup($user{'2'});

my $collab
    = $node->addChild({
        className               => "WebGUI::Asset::Wobject::Collaboration",
        groupIdView             => 7,   # Everyone
        groupIdEdit             => 3,   # Admins
        ownerUserId             => 3,   # Admin
        postGroupId             => 2,   # Registered Users
        canStartThreadGroupId   => 3,   # Admin
    },);

#----------------------------------------------------------------------------
# Tests
plan tests => 36;

#----------------------------------------------------------------------------
# Permissions for collaboration systems
# View
$maker->prepare( {
    object      => $collab,
    method      => 'canView',
    pass        => [ '1', $user{"2"}, '3', ], 
} )->run;

# Edit
$maker->prepare( {
    object      => $collab,
    method      => 'canEdit',
    pass        => [ '3', ], 
    fail        => [ '1', $user{"2"}, ],
} )->run;

# Post
$maker->prepare( {
    object      => $collab,
    method      => 'canPost',
    pass        => [ $user{"2"}, '3', ], 
    fail        => [ '1', ],
} )->run;

# Post Thread
$maker->prepare( {
    object      => $collab,
    method      => 'canStartThread',
    pass        => [ '3', ], 
    fail        => [ '1', $user{"2"}, ],
} )->run;

# Subscribe
$maker->prepare( {
    object      => $collab,
    method      => 'canSubscribe',
    pass        => [ $user{"2"}, '3', ],
    fail        => [ '1', ],
} )->run;

# Moderate
$maker->prepare( {
    object      => $collab,
    method      => 'canModerate',
    pass        => [ '3', ], 
    fail        => [ '1', $user{"2"}, ],
} )->run;

#vim:ft=perl
