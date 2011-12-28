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

# This script uses Test::WWW::Mechanize to test adding and editing Event
# assets.
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );
my @versionTags     = ( WebGUI::VersionTag->getWorking( $session ) );

# Create a user for testing purposes
my $user        = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($user);
$user->username( 'dufresne' . time );

my ( $mech );


# Create a Calendar to add Events to
my $calendar    = $node->addChild( {
    className           => 'WebGUI::Asset::Wobject::Calendar',
    groupIdEventEdit    => '2',     # Registered Users
    groupIdEdit         => '3',     # Admins
    workflowIdCommit    => 'pbworkflow000000000003', # Commit Without approval
} );

# Remember this event url when we want to edit it later
my $eventUrl;

$versionTags[-1]->commit;
WebGUI::Test->addToCleanup($versionTags[-1]);

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Add event: Users without permission are not shown form
my $mech       = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get( $calendar->getUrl('func=add;className=WebGUI::Asset::Event') );

$mech->content_lacks( q{value="editSave"} );

#----------------------------------------------------------------------------
# Add event: Users with permission are shown form to add event
$mech->get('/');
$mech->session->user({ user => $user });

# Properties given to the form
my $properties  = {
    title       => 'Event Title',
    menuTitle   => 'Event Menu Title',
};

$mech->get_ok( $calendar->getUrl('func=add;className=WebGUI::Asset::Event') );
$mech->submit_form_ok( 
    {
        with_fields => $properties,
    }, 
    'Event add form' 
);

# Form gets saved correctly
my $event   
    = $calendar->getLineage( ['children'], { 
        returnObjects => 1, 
        orderByClause => "creationDate DESC",
    } )->[0];

# Add properties that should be set to default
$properties = {
    %{ $properties },
    ownerUserId     => $user->userId,
    createdBy       => $user->userId,
    groupIdEdit     => '2',
};

cmp_deeply( $event->get, superhashof( $properties ), 'Event properties saved correctly' );

# Save the event URL for later
$eventUrl       = $event->getUrl;

#----------------------------------------------------------------------------
# Edit Event: Users without permission are not shown form
$mech       = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );

$mech->get( $eventUrl . '?func=edit' );
ok !$mech->success, 'edit form was not loaded';
$mech->content_lacks( q{value="editSave"} );

#----------------------------------------------------------------------------
# Edit Event: User with permission is shown form to edit event
$mech->get('/');
$mech->session->user({ user => $user });

$mech->get_ok( $eventUrl . '?func=edit' );

my $properties  = {
    title       => "Event Title" . time,
    menuTitle   => "Event Menu Title" . time,
    description => "Event Description" . time,
};

$mech->submit_form_ok(
    {
        with_fields => $properties,
    },
    'Event edit form'
);

# Form gets saved correctly
my $event
    = $calendar->getLineage( ['children'], {
        returnObjects       => 1,
        orderByClause       => "creationDate DESC",
    } )->[0];

# Add defaults that should not get set from the form
$properties = {
    %{ $properties },
    ownerUserId     => $user->userId,
    createdBy       => $user->userId,
    groupIdEdit     => '2',
};

cmp_deeply( $event->get, superhashof( $properties ), 'Events properties saved correctly' );

done_testing;

#vim:ft=perl
