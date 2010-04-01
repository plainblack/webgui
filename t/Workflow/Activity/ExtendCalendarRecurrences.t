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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../../t/lib";
use Test::More;
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Workflow::Activity::ExtendCalendarRecurrences;
use DateTime;
use Data::Dumper;

my $session = WebGUI::Test->session;
my $temp    = WebGUI::Asset->getTempspace($session);

my $tag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test::addToCleanup($tag);

my $calendar = $temp->addChild(
    {   className => 'WebGUI::Asset::Wobject::Calendar' }
);

my $one_year_ago = DateTime->today->subtract(years => 1)->ymd;

my $event = $calendar->addChild(
    {   className => 'WebGUI::Asset::Event',
        startDate => $one_year_ago,
        endDate   => $one_year_ago,
    }
);

my $recurId = $event->setRecurrence(
    {   recurType => 'monthDay',
        every     => 2,
        startDate => $event->get('startDate'),
        dayNumber => DateTime->today->day,
    }
);

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


while (my $status = $instance->run ne 'complete') {
    note $status;
    $instance->run;
}

my $sql = q{
    select e.startDate, e.endDate
    from   asset a
    inner join event e on e.assetId = a.assetId
    and    a.parentId = ?
    order by e.startDate
};

my $dates = $session->db->buildArrayRefOfHashRefs($sql, [$calendar->getId]);
# 3 years at every other month (6 times) plus the one we started with
is(@$dates, 19) or diag Dumper $dates;

done_testing;

#vim:ft=perl
