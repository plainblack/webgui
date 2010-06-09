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

# This script uses Test::WWW::Mechanize to test adding and editing Event
# assets.
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI::Session;
plan skip_all => 'set WEBGUI_LIVE to enable this test' unless $ENV{WEBGUI_LIVE};

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );
my @versionTags     = ( WebGUI::VersionTag->getWorking( $session ) );

# Override some settings to make things easier to test
# userFunctionStyleId 
$session->setting->set( 'userFunctionStyleId', 'PBtmpl0000000000000132' );
$session->setting->set( 'defaultVersionTagWorkflow', 'pbworkflow000000000003' );

# Create a user for testing purposes
my $user        = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($user);
$user->username( 'dufresne' . time );
my $identifier  = 'ritahayworth';
my $auth        = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->saveParams( $user->userId, $user->authMethod, {
    'identifier'    => Digest::MD5::md5_base64( $identifier ), 
});

my ( $mech );

# Get the site's base URL
my $baseUrl         = 'http://' . $session->config->get('sitename')->[0];

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

#----------------------------------------------------------------------------
# Tests

if ( !eval { require Test::WWW::Mechanize; 1; } ) {
    plan skip_all => 'Cannot load Test::WWW::Mechanize. Will not test.';
}
$mech    = Test::WWW::Mechanize->new;
$mech->get( $baseUrl );
if ( !$mech->success ) {
    plan skip_all => "Cannot load URL '$baseUrl'. Will not test.";
}

plan skip_all => 'set WEBGUI_LIVE to enable this test'
    unless $ENV{WEBGUI_LIVE};

plan tests => 8;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Add event: Users without permission are not shown form
$mech       = Test::WWW::Mechanize->new;
$mech->get( $baseUrl . $calendar->getUrl('func=add;class=WebGUI::Asset::Event') );

$mech->content_lacks( q{value="editSave"} );

#----------------------------------------------------------------------------
# Add event: Users with permission are shown form to add event
$mech       = getMechLogin( $baseUrl, $user, $identifier );

# Properties given to the form
my $properties  = {
    title       => 'Event Title',
    menuTitle   => 'Event Menu Title',
};

$mech->get_ok( $baseUrl . $calendar->getUrl('func=add;class=WebGUI::Asset::Event') );
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
};

cmp_deeply( $event->get, superhashof( $properties ), 'Event properties saved correctly' );

# Save the event URL for later
$eventUrl       = $event->getUrl;

#----------------------------------------------------------------------------
# Edit Event: Users without permission are not shown form
$mech       = Test::WWW::Mechanize->new;

$mech->get( $baseUrl . $eventUrl . '?func=edit' );

$mech->content_lacks( q{value="editSave"} );

#----------------------------------------------------------------------------
# Edit Event: User with permission is shown form to edit event
$mech       = getMechLogin( $baseUrl, $user, $identifier );

$mech->get_ok( $baseUrl . $eventUrl . '?func=edit' );

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
};

cmp_deeply( $event->get, superhashof( $properties ), 'Events properties saved correctly' );

#----------------------------------------------------------------------------
# Cleanup
END {
    for my $tag ( @versionTags ) {
        $tag->rollback;
    }

}

#----------------------------------------------------------------------------
# getMechLogin( baseUrl, WebGUI::User, "identifier" )
# Returns a Test::WWW::Mechanize session after logging in the given user using
# the given identifier (password)
# baseUrl is a fully-qualified URL to the site to login to
sub getMechLogin {
    my $baseUrl     = shift;
    my $user        = shift;
    my $identifier  = shift;
    
    my $mech    = Test::WWW::Mechanize->new;
    $mech->get( $baseUrl . '?op=auth;method=displayLogin' );
    $mech->submit_form( 
        with_fields => {
            username        => $user->username,
            identifier      => $identifier,
        },
    ); 

    return $mech;
}
