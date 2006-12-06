#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Utility qw/isIn/;
use Test::More tests => 25; # increment this value for each test you create

my $session = WebGUI::Test->session;
my $wf = WebGUI::Workflow->create($session, {title => 'Title', description => 'Description',
					     type => 'None'});
ok(defined $wf, 'can create workflow');
isa_ok($wf, 'WebGUI::Workflow', 'workflow');

my $wfId = $wf->getId;
ok(defined $wfId, 'workflow has an ID');
ok(defined WebGUI::Workflow->new($session, $wfId), 'workflow can be retrieved');

is($wf->get('title'), 'Title', 'workflow title is set');
is($wf->get('description'), 'Description', 'workflow description is set');
is($wf->get('type'), 'None', 'workflow type is set');
ok(!$wf->get('enabled'), 'workflow is not enabled');
# TODO: test other properties
is_deeply($wf->getActivities, [], 'workflow has no activities');
is_deeply($wf->getInstances, [], 'workflow has no instances');
is_deeply($wf->getCrons, [], 'workflow has no crons');
ok(!isIn($wfId, keys %{WebGUI::Workflow->getList($session)}), 'workflow not in enabled list');

$wf->set({enabled => 1});
ok($wf->get('enabled'), 'workflow is enabled');
ok(isIn($wfId, keys %{WebGUI::Workflow->getList($session)}), 'workflow in enabled list');
$session->errorHandler->warn('Interesting');
$wf->set({enabled => 0});
ok(!$wf->get('enabled'), 'workflow is disabled again');

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

# Mismatched activity with workflow.
require WebGUI::Workflow::Activity::DecayKarma;
my $badActivity = WebGUI::Workflow::Activity::DecayKarma->create($session, $wf2->getId);
ok(!defined $badActivity, 'cannot create mismatched activity');
is(scalar @{$wf->getActivities}, 1, 'workflow still has one activity');

# TODO: test activities more, and crons

# Local variables:
# mode: cperl
# End:
