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
use lib "$FindBin::Bin/../../../lib";
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
WebGUI::Test->addToCleanup($user{'2'});
$user{"2"}->addToGroups( ['2'] ); # Registered user

my $versionTag      = WebGUI::VersionTag->getWorking( $session );
WebGUI::Test->addToCleanup($versionTag);
$versionTag->set( { name => "Collaboration Test" } );

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
        groupIdView         => 7,
    }, @addArgs );

$versionTag->commit( { timeout => 1_000_000 } );

# Re-load the collab to get the newly committed properties
$collab = WebGUI::Asset->newByDynamicClass( $session, $collab->getId );
$thread = WebGUI::Asset->newByDynamicClass( $session, $thread->getId );

#----------------------------------------------------------------------------
# Tests
plan tests => 36;

#----------------------------------------------------------------------------
# Permissions for threads
# View
$maker->prepare( {
    object      => $thread,
    method      => 'canView',
    pass        => [ '1', $user{"2"}, '3', ], 
} )->run;

# Subscribe
$maker->prepare( {
    object      => $thread,
    method      => 'canSubscribe',
    pass        => [ $user{"2"}, '3', ], 
    fail        => [ '1', ],
} )->run;

# Edit
$maker->prepare( {
    object      => $thread,
    method      => 'canEdit',
    pass        => [ $user{"2"}, '3', ], 
    fail        => [ '1', ], 
} )->run;

# Reply
$maker->prepare( {
    object      => $thread,
    method      => 'canReply',
    pass        => [ $user{"2"}, '3', ], 
    fail        => [ '1', ],
} )->run;

# Reply with allowReplies = 0
$collab->update({ allowReplies => 0 });
$thread = WebGUI::Asset->newByDynamicClass( $session, $thread->getId );
$maker->prepare( {
    object      => $thread,
    method      => 'canReply',
    fail        => [ '1', $user{"2"}, '3', ], 
} )->run;
$collab->update({ allowReplies => 1 });

# Reply with thread isLocked
$thread->lock;
$maker->prepare( {
    object      => $thread,
    method      => 'canReply',
    fail        => [ '1', $user{"2"}, '3', ], 
} )->run;
$thread->unlock;

WebGUI::Test->addToCleanup('WebGUI::Group' => $thread->get('subscriptionGroupId'));

