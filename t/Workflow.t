#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Workflow;
use WebGUI::Workflow::Cron;
use WebGUI::Utility qw/isIn/;
use Test::More tests => 67; # increment this value for each test you create
use Test::Deep;

my $session = WebGUI::Test->session;
my $wf = WebGUI::Workflow->create($session, {title => 'Title', description => 'Description',
					     type => 'None'});
ok(defined $wf, 'can create workflow');
isa_ok($wf, 'WebGUI::Workflow', 'workflow');

my $wfId = $wf->getId;
ok(defined $wfId, 'workflow has an ID');
ok($session->id->valid($wfId), 'Workflow has a valid Id');
ok(defined WebGUI::Workflow->new($session, $wfId), 'workflow can be retrieved');

is($wf->get('title'), 'Title', 'workflow title is set');
is($wf->get('description'), 'Description', 'workflow description is set');
is($wf->get('type'), 'None', 'workflow type is set');
ok(!$wf->get('enabled'), 'workflow is not enabled');
# TODO: test other properties
is_deeply($wf->getActivities, [], 'workflow has no activities');
is_deeply($wf->getInstances, [], 'workflow has no instances');
is_deeply($wf->getCrons, [], 'workflow has no crons');

##################################################
#
# getList tests
#
##################################################

isa_ok(WebGUI::Workflow->getList($session), 'HASH', 'getList returns a hashref');

ok(!isIn($wfId, keys %{WebGUI::Workflow->getList($session)}), 'workflow not in enabled list');
is(scalar keys %{WebGUI::Workflow->getList($session)}, 11, 'There are eleven enabled, default workflows, of all types, shipped with WebGUI');

$wf->set({enabled => 1});
ok($wf->get('enabled'), 'workflow is enabled');
ok(isIn($wfId, keys %{WebGUI::Workflow->getList($session)}), 'workflow in enabled list');
$wf->set({enabled => 0});
ok(!$wf->get('enabled'), 'workflow is disabled again');

is(scalar keys %{WebGUI::Workflow->getList($session, 'WebGUI::User')}, 1, 'There is only 1 WebGUI::User based workflow that ships with WebGUI');

##Throwing in another test here to test how enabled works.  It should be sticky

$wf->set({enabled => 1});
ok($wf->get('enabled'), 'Enable workflow again');
$wf->set({description => 'Better stay enabled'});
ok($wf->get('enabled'), 'Workflow is enabled after setting the description');
$wf->set({enabled => 0});

##################################################
#
# Mode tests
#
##################################################

is($wf->get('mode'), 'parallel', 'default mode for created workflows is parallel');
ok(! $wf->isSingleton, 'Is not singleton');
ok(! $wf->isSerial,    'Is not serial');
ok(! $wf->isRealtime,  'Is not realtime, and never will be');
ok(  $wf->isParallel,  'Is parallel');
$wf->set({'mode', 'serial'});
is(join('', $wf->isSingleton, $wf->isSerial, $wf->isParallel), '010', 'Is checks after setting mode to serial');
$wf->set({'mode', 'singleton'});
is(join('', $wf->isSingleton, $wf->isSerial, $wf->isParallel), '100', 'Is checks after setting mode to singleton');
$wf->set({'isSerial' => 1});
is(join('', $wf->isSingleton, $wf->isSerial, $wf->isParallel), '010', 'Is checks after setting mode to singleton');
$wf->set({'isSingleton' => 1});
is(join('', $wf->isSingleton, $wf->isSerial, $wf->isParallel), '100', 'Is checks after setting mode to singleton');

##Checking sticky mode settings
$wf->set({description => 'better stay singleton'});
ok($wf->isSingleton, 'After setting description, workflow is still singleton');

$wf->delete;
ok(!defined WebGUI::Workflow->new($session, $wfId), 'deleted workflow cannot be retrieved');

my $wf2 = WebGUI::Workflow->create($session, {title => 'Title', description => 'Description',
					      type => 'WebGUI::VersionTag'});
ok(defined $wf2, 'can create version tag workflow');
isa_ok($wf2, 'WebGUI::Workflow', 'workflow');

require WebGUI::Workflow::Activity::UnlockVersionTag;
my $activity = WebGUI::Workflow::Activity::UnlockVersionTag->create($session, $wf2->getId);
ok(defined $activity, 'can create activity');
isa_ok($activity, 'WebGUI::Workflow::Activity::UnlockVersionTag', 'activity');
isa_ok($activity, 'WebGUI::Workflow::Activity', 'activity');
my $actId = $activity->getId;
ok(defined $actId, 'activity has an ID');
is(scalar @{$wf2->getActivities}, 1, 'workflow has one activity');
is($wf2->getActivities->[0]->getId, $actId, 'Workflow has the correct activity');

TODO: {
	local $TODO = "Tests that test things that do not work yet";
	# Mismatched activity with workflow.
	require WebGUI::Workflow::Activity::DecayKarma;
	my $badActivity = WebGUI::Workflow::Activity::DecayKarma->create($session, $wf2->getId);
	ok(!defined $badActivity, 'cannot create mismatched activity');
	is(scalar @{$wf2->getActivities}, 1, 'workflow still has one activity');
}

my $cron = WebGUI::Workflow::Cron->create($session,
					  {monthOfYear => '*', dayOfMonth => '5', hourOfDay => '2',
					   minuteOfHour => '15', dayOfWeek => '*', enabled => 1,
					   runOnce => 0, priority => 2, workflowId => $wf2->getId,
					   title => 'Test Cron'});
ok(defined $cron, 'can create cron');
isa_ok($cron, 'WebGUI::Workflow::Cron', 'cron');
is(scalar @{$wf2->getCrons}, 1, 'workflow has one cron');
is($wf2->getCrons->[0]->getId, $cron->getId, 'one cron is same cron');
$cron->delete;

# More activity and cron tests here?

$wf2->delete;

my $wf3 = WebGUI::Workflow->create($session, {});
isa_ok($wf3, 'WebGUI::Workflow', 'workflow created with all defaults');
is($wf3->get('title'),       'Untitled', 'Default title is Untitled');
is($wf3->get('description'), undef,      'Default description is undefined');
is($wf3->get('type'),        'None',     'Default type is None');
is($wf3->get('enabled'),     0,          'By default, enabled is 0');
is($wf3->get('mode'),        'parallel', 'Default mode is parallel');

my $decayKarma = $wf3->addActivity('WebGUI::Workflow::Activity::DecayKarma');
my $cleanTemp  = $wf3->addActivity('WebGUI::Workflow::Activity::CleanTempStorage');
my $oldTrash   = $wf3->addActivity('WebGUI::Workflow::Activity::PurgeOldTrash');

#####################################################################
#
# Activity tests, promote, demote, reorder, accessing, deleting
#
#####################################################################

my $nextActivity;
$nextActivity = $wf3->getNextActivity($cleanTemp->getId);
isa_ok($nextActivity, 'WebGUI::Workflow::Activity', 'getNextActivity returns a Workflow::Activity object');
is($nextActivity->getId, $oldTrash->getId, 'getNextActivity returns the activity after the specified activity');

$nextActivity = $wf3->getNextActivity($oldTrash->getId);
is($nextActivity, undef, 'getNextActivity returns undef if there is no next activity');

my $getActivity = $wf3->getActivity($decayKarma->getId);
isa_ok($getActivity, 'WebGUI::Workflow::Activity', 'getNextActivity returns a Workflow::Activity object');
is($getActivity->getId, $decayKarma->getId, 'getActivity returns the requested activity by activityId');

cmp_deeply(
    $wf3->getActivities,
    [$decayKarma, $cleanTemp, $oldTrash],
    'getActivities returns activties in the order they were added to the Workflow'
);

$wf3->demoteActivity($oldTrash->getId);

cmp_deeply(
    [ map { $_->getId } @{ $wf3->getActivities } ],
    [ map { $_->getId } $decayKarma, $cleanTemp, $oldTrash],
    'demote works on first activity, even though it does not move'
);

$wf3->promoteActivity($decayKarma->getId);

cmp_deeply(
    [ map { $_->getId } @{ $wf3->getActivities } ],
    [ map { $_->getId } $decayKarma, $cleanTemp, $oldTrash],
    'promote works on last activity, even though it does not move'
);

$wf3->demoteActivity($cleanTemp->getId);

cmp_deeply(
    [ map { $_->getId } @{ $wf3->getActivities } ],
    [ map { $_->getId } $decayKarma, $oldTrash, $cleanTemp],
    'demote activity works'
);

$wf3->promoteActivity($oldTrash->getId);

cmp_deeply(
    [ map { $_->getId } @{ $wf3->getActivities } ],
    [ map { $_->getId } $oldTrash, $decayKarma, $cleanTemp],
    'promote activity works'
);

my $trashClipboard = $wf3->addActivity('WebGUI::Workflow::Activity::TrashClipboard');

$wf3->deleteActivity($cleanTemp->getId);

cmp_deeply(
    [ map { $_->getId } @{ $wf3->getActivities } ],
    [ map { $_->getId } $oldTrash, $decayKarma, $trashClipboard],
    'delete activity works'
);

$wf3->deleteActivity('neverAWebGUIId');

cmp_deeply(
    [ map { $_->getId } @{ $wf3->getActivities } ],
    [ map { $_->getId } $oldTrash, $decayKarma, $trashClipboard],
    'delete activity requires a valid activityId to delete'
);

cmp_deeply(
    [ map { $_->get('sequenceNumber') } @{ $wf3->getActivities } ],
    [ 1,2,3 ],
    'delete updates the sequence numbers of its activities'
);

$decayKarma->delete();

cmp_deeply(
    [ map { $_->get('sequenceNumber') } @{ $wf3->getActivities } ],
    [ 1,3 ],
    'Manual delete of an activity does not update the sequence numbers'
);

$wf3->reorderActivities();

cmp_deeply(
    [ map { $_->get('sequenceNumber') } @{ $wf3->getActivities } ],
    [ 1,2 ],
    'reorder activities works'
);

$wf3->delete;

# Local variables:
# mode: cperl
# End:
