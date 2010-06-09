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
use WebGUI::Test::Maker::Permission;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $maker           = WebGUI::Test::Maker::Permission->new;
my $node            = WebGUI::Asset->getImportNode( $session );

$session->user({ userId => 3 });
my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});

my $registeredUser  = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($registeredUser);

# Make a Calendar to add events do
my $calendar = $node->addChild({
    className           => 'WebGUI::Asset::Wobject::Calendar',
    groupIdView         => '7',     # Everyone
    groupIdEdit         => '3',     # Admins
    groupIdEventEdit    => '2',     # Registered Users
});

$versionTags[-1]->commit;

# Arguments for when adding events
my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1 } );

my $event;

#----------------------------------------------------------------------------
# Tests

plan tests => 12;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test permissions of an event added by the Admin
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});
$event  = $calendar->addChild({
    className       => 'WebGUI::Asset::Event',
    ownerUserId     => 3,
}, @addArgs);

$maker->prepare( {
    object      => $event,
    method      => 'canView',
    pass        => [ '1', '3', $registeredUser, ],
    fail        => [ ],
} )->run;
$maker->prepare( {
    object      => $event,
    method      => 'canEdit',
    pass        => [ '3', ],
    fail        => [ '1', $registeredUser, ],
} )->run;

#----------------------------------------------------------------------------
# Cleanup
END {
    for my $tag ( @versionTags ) {
        $tag->rollback;
    }
}
