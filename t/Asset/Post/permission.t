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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Maker::Permission;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user( { userId => 3 } );
my $maker           = WebGUI::Test::Maker::Permission->new;
my $node            = WebGUI::Asset->getImportNode( $session );

my %user;
$user{"2"}          = WebGUI::User->new( $session, "new" );
WebGUI::Test->usersToDelete($user{'2'});
$user{"2"}->addToGroups( ['2'] ); # Registered user

my $versionTag      = WebGUI::VersionTag->getWorking( $session );
$versionTag->set( { name => "Collaboration Test" } );
WebGUI::Test->tagsToRollback($versionTag);

my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1 } );

my $collab
    = $node->addChild({
        className               => "WebGUI::Asset::Wobject::Collaboration",
        groupIdView             => 7,   # Everyone
        groupIdEdit             => 3,   # Admins
        groupToEditPost         => 3,   # Admins
        ownerUserId             => 3,   # Admin
        postGroupId             => 2,   # Registered Users
        canStartThreadGroupId   => 3,   # Admin
        allowReplies            => 1,
        editTimeout             => 60 * 60 * 24, # 24 hours
    }, @addArgs );

my $thread
    = $collab->addChild({
        className           => 'WebGUI::Asset::Post::Thread',
        ownerUserId         => $user{"2"}->userId,  
    }, @addArgs );

my $post
    = $thread->addChild({
        className           => 'WebGUI::Asset::Post',
        ownerUserId         => $user{"2"}->userId,
    }, @addArgs );

$versionTag->commit( { timeout => 1_000_000 } );

# Re-load the collab to get the newly committed properties
$collab = WebGUI::Asset->newById( $session, $collab->getId );
$thread = WebGUI::Asset->newById( $session, $thread->getId );
$post   = WebGUI::Asset->newById( $session, $post->getId );

#----------------------------------------------------------------------------
# Tests
plan tests => 12;

#----------------------------------------------------------------------------
# Permissions for posts
# View
$maker->prepare( {
    object      => $post,
    method      => 'canView',
    pass        => [ '1', $user{"2"}, '3', ], 
} )->run;

## Edit
$maker->prepare( {
    object      => $post,
    method      => 'canEdit',
    pass        => [ $user{"2"}, '3', ], 
    fail        => [ '1', ], 
} )->run;

#----------------------------------------------------------------------------
# Cleanup
WebGUI::Test->addToCleanup('WebGUI::Group' => $thread->get('subscriptionGroupId'));

