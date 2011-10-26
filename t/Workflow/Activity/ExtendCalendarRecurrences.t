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

use strict;
use Test::More;
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Workflow::Activity::ExtendCalendarRecurrences;
use DateTime;
use Data::Dumper;

my $session = WebGUI::Test->session;
my $temp    = WebGUI::Test->asset;

my $tag = WebGUI::VersionTag->getWorking($session);

my $calendar = $temp->addChild(
    {   className => 'WebGUI::Asset::Wobject::Calendar' }
);

my $eventStartDate = DateTime->today->truncate(to => 'month')->subtract(years => 1); 

my $one_year_ago = $eventStartDate->ymd;

my $event = $calendar->addChild(
    {   className => 'WebGUI::Asset::Event',
        startDate => $one_year_ago,
        endDate   => $one_year_ago,
    }, undef, undef, {skipAutoCommitWorkflows => 1, }
);

my $trashed_event = $calendar->addChild(
    {   className => 'WebGUI::Asset::Event',
        startDate => $one_year_ago,
        endDate   => $one_year_ago,
    }, undef, undef, {skipAutoCommitWorkflows => 1, }
);
$trashed_event->trash;

my $clipped_event = $calendar->addChild(
    {   className => 'WebGUI::Asset::Event',
        startDate => $one_year_ago,
        endDate   => $one_year_ago,
    }, undef, undef, {skipAutoCommitWorkflows => 1, }
);
$clipped_event->cut;

my $recurId = $event->setRecurrence(
    {   recurType => 'monthDay',
        every     => 2,
        startDate => $event->get('startDate'),
        dayNumber => $eventStartDate->day,
    }
);

$trashed_event->setRecurrence(
    {   recurType => 'monthDay',
        every     => 2,
        startDate => $trashed_event->get('startDate'),
        dayNumber => $eventStartDate->day,
    }
);

$clipped_event->setRecurrence(
    {   recurType => 'monthDay',
        every     => 2,
        startDate => $clipped_event->get('startDate'),
        dayNumber => $eventStartDate->day,
    }
);

$tag->commit;
WebGUI::Test->addToCleanup($tag);

my $workflow = WebGUI::Workflow->create(
    $session, {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    },
);

WebGUI::Test::addToCleanup($workflow);

my $activity =
$workflow->addActivity('WebGUI::Workflow::Activity::ExtendCalendarRecurrences');

my $calendars = [ $calendar->getId ];
{
    # We only want to be testing our calendar, not any others in the asset
    # tree.
    no warnings 'redefine';
    sub WebGUI::Workflow::Activity::ExtendCalendarRecurrences::findCalendarIds {
        return $calendars;
    }
}

is $activity->findCalendarIds, $calendars, 'mocking worked';

my $instance = WebGUI::Workflow::Instance->create(
    $session, {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);


my $count = 0;
while (my $status = $instance->run ne 'complete') {
    note $status;
    $instance->run;
    last if $count++ > 30;
}

#my $sql = q{
#    select e.startDate, e.endDate
#    from   asset a
#    inner join Event e on e.assetId = a.assetId
#    and    a.parentId = ?
#    order by e.startDate
#};

#my $dates = $session->db->buildArrayRefOfHashRefs($sql, [$calendar->getId]);
my $dates = $calendar->getLineage(['children'], { returnObjects => 1, });
# 3 years at every other month (6 times) plus the one we started with
is(@{$dates}, 19, 'created right number of dates') or diag Dumper $dates;

my @uncommitted_events = grep { $_->get('status') ne 'approved' } @{ $dates };
is @uncommitted_events, 0, 'all events are committed (approved)';

done_testing;

#vim:ft=perl
