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

# Test the forms for Workflow editing
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
# Tests

plan tests => 14;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Add a workflow
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });

$mech->get_ok( '?op=addWorkflow' );
$mech->submit_form_ok({
        fields => {
            type => "None",
        },
    },
    "Add a new workflow"
);

my $workflowId = $mech->value( 'workflowId' );
ok( $workflowId, "workflow id in edit form" );
ok( my $workflow = WebGUI::Workflow->new( $mech->session, $workflowId ), "can be instanced" );
WebGUI::Test::addToCleanup( $workflow );
is( $workflow->get('type'), "None", "type set correctly" );

my %workflowFields = (
    title           => 'New Test Workflow',
    description     => 'Descriptive',
);
$mech->submit_form_ok({
        fields => \%workflowFields,
    },
    "Update the new workflow's name and settings",
);

$workflow = WebGUI::Workflow->new( $mech->session, $workflowId );
is( $workflow->get('title'), $workflowFields{title}, "title set correctly" );
is( $workflow->get('description'), $workflowFields{description}, "description set correctly" );

# Add an activity
$mech->follow_link_ok(
    {
        url_regex => qr/WebGUI::Workflow::Activity::DeleteExpiredSessions/,
    },
    "Add a DeleteExpiredSessions activity",
);

my %activityFields = (
    title    => 'New Workflow Activity',
    description => 'As if you needed one.',
);
$mech->submit_form_ok({
        fields => \%activityFields,
    },
    "Edit the activity properties",
);

my $activities = $workflow->getActivities;
is( @$activities, 1, 'workflow has one activity' );
is( $activities->[0]->get('title'), $activityFields{title}, "activity title set" );
is( $activities->[0]->get('description'), $activityFields{description}, "activity description set" );


#vim:ft=perl
