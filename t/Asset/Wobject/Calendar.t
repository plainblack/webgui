#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

##The goal of this test is to test the creation of Calendar Wobjects.

my @icalWrapTests = (
    {
        in      => 'Text is passed through with no problems',
        out     => 'Text is passed through with no problems',
        comment => 'Text passed through with no problems',
    },
    {
        in      => ',Escape more than one, multiple, commas,',
        out     => '\,Escape more than one\, multiple\, commas\,',
        comment => 'escape commas',
    },
    {
        in      => ';Escape more than one; multiple; semicolons;',
        out     => '\;Escape more than one\; multiple\; semicolons\;',
        comment => 'escape semicolons',
    },
    {
        in      => '\\Escape more than one\\ multiple\\ backslashes\\',
        out     => '\\\\Escape more than one\\\\ multiple\\\\ backslashes\\\\',
        comment => 'escape backslashes',
    },
    {
        in      => "lots\nand\nlots\nof\nnewlines\n",
        out     => 'lots\\nand\\nlots\\nof\\nnewlines\\n',
        comment => 'escape newlines',
    },
    {
                   #         1         2         3         4         5         6         7   V
                   #12345678901234567890123456789012345678901234567890123456789012345678901234567890
        in      => "There's not a day goes by I don't feel regret. Not because I'm in here, or because you think I should. I look back on the way I was then: a young, stupid kid who committed that terrible crime. I want to talk to him.",
        out     => "There's not a day goes by I don't feel regret. Not because I'm in here\\,\r\n or because you think I should. I look back on the way I was then: a\r\n young\\, stupid kid who committed that terrible crime. I want to talk to\r\n him.",
        comment => 'basic wrapping',
    },
);

use WebGUI::Test;
use WebGUI::Session;
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Asset::Wobject::Calendar;
use WebGUI::Asset::Event;

plan tests => 14 + scalar @icalWrapTests;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Test->asset;

my $cal = $node->addChild({className=>'WebGUI::Asset::Wobject::Calendar'});
my $windowCal = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Calendar for doing event window testing',
});

# Test for a sane object type
isa_ok($cal, 'WebGUI::Asset::Wobject::Calendar');

# Test addChild to make sure we can only add Event assets as children to the calendar
my $event = $cal->addChild({className=>'WebGUI::Asset::Event'});
isa_ok($event, 'WebGUI::Asset::Event','Can add Events as a child to the calendar.');

my $dt = WebGUI::DateTime->new($session, mysql => '2001-08-16 8:00:00', time_zone => 'America/Chicago');

my $vars = {};
$cal->appendTemplateVarsDateTime($vars, $dt, "start");
cmp_deeply(
    $vars,
    {
        startMinute     => '00',
        startDayOfMonth => 16,
        startMonthName  => 'August',
        startMonthAbbr  => 'Aug',
        startEpoch      => 997966800,
        startHms        => '08:00:00',
        startM          => 'AM',
        startMeridiem   => 'AM',
        startDayName    => 'Thursday',
        startMdy        => '08-16-2001',
        startYmd        => '2001-08-16',
        startDmy        => '16-08-2001',
        startDayAbbr    => 'Thu',
        startDayOfWeek  => 4,
        startHour       => 8,
        startHour24     => 8,
        startMonth      => 8,
        startSecond     => '00',
        startYear       => 2001,
    },
    'Variables returned by appendTemplateVarsDateTime'
);

######################################################################
#
# getEventsIn
#
######################################################################

my $tz   = $session->datetime->getTimeZone();
my $bday = WebGUI::DateTime->new($session, WebGUI::Test->webguiBirthday);

##Simulate how windows are built in each view method
my $startDt     = $bday->cloneToUserTimeZone->truncate(to => 'day')->subtract(days => 1);
my $windowStart = $startDt->clone;
my $endDt       = $startDt->clone->add(days => 2);
my $windowEnd   = $endDt->clone->subtract(seconds => 1);

my $tag2 = WebGUI::VersionTag->getWorking($session);

my $inside = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Inside window, no times, same day',
    startDate   => $bday->toDatabaseDate,
    endDate     => $bday->toDatabaseDate,
    timeZone    => $tz,
},);

my $insidewt = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Inside window, with times',
    startDate   => $bday->toDatabaseDate,
    endDate     => $bday->toDatabaseDate,
    startTime   => $bday->toDatabaseTime,
    endTime     => $bday->clone->add(hours => 1)->toDatabaseTime,
    timeZone    => $tz,
},);

my $outsideHigh = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Outside window, after time',
    startDate   => $endDt->clone->add(days => 2)->toDatabaseDate,
    endDate     => $endDt->clone->add(days => 3)->toDatabaseDate,
    timeZone    => $tz,
},);

my $outsideLow = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Outside window, before time',
    startDate   => $startDt->clone->subtract(days => 3)->toDatabaseDate,
    endDate     => $startDt->clone->subtract(days => 2)->toDatabaseDate,
    timeZone    => $tz,
},);

my $straddle = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Straddles the window, inclusive',
    startDate   => $startDt->clone->subtract(days => 1)->toDatabaseDate,
    endDate     => $endDt->clone->add(days => 1)->toDatabaseDate,
    timeZone    => $tz,
},);

my $straddlewt = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Straddles the window with times, inclusive',
    startDate   => $startDt->clone->subtract(hours => 12)->toDatabaseDate,
    endDate     => $endDt->clone->add(hours => 12)->toDatabaseDate,
    startTime   => $startDt->clone->subtract(hours => 12)->toDatabaseTime,
    endTime     => $endDt->clone->add(hours => 12)->toDatabaseTime,
    timeZone    => $tz,
},);

my $straddleLowwt = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Straddles the window, lower side',
    startDate   => $startDt->clone->subtract(hours => 12)->toDatabaseDate,
    endDate     => $startDt->clone->add(hours => 12)->toDatabaseDate,
    startTime   => $startDt->clone->subtract(hours => 12)->toDatabaseTime,
    endTime     => $startDt->clone->add(hours => 12)->toDatabaseTime,
    timeZone    => $tz,
},);

my $straddleHighwt = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Straddles the window, higher side',
    startDate   => $endDt->clone->subtract(hours => 12)->toDatabaseDate,
    endDate     => $endDt->clone->add(hours => 12)->toDatabaseDate,
    startTime   => $endDt->clone->subtract(hours => 12)->toDatabaseTime,
    endTime     => $endDt->clone->add(hours => 12)->toDatabaseTime,
    timeZone    => $tz,
},);

my $justBeforewt = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Just before the window.  Ending time coincident with window start',
    startDate   => $startDt->clone->subtract(hours => 1)->toDatabaseDate,
    endDate     => $startDt->toDatabaseDate,
    startTime   => $startDt->clone->subtract(hours => 1)->toDatabaseTime,
    endTime     => $startDt->toDatabaseTime,
    timeZone    => $tz,
},);

my $justAfterwt = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Just after the window.  Start time coincident with window end',
    startDate   => $endDt->toDatabaseDate,
    endDate     => $endDt->clone->add(hours => 1)->toDatabaseDate,
    startTime   => $endDt->toDatabaseTime,
    endTime     => $endDt->clone->add(hours => 1)->toDatabaseTime,
    timeZone    => $tz,
}, );

my $justBefore = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Just before the window.  Ending date coincident with window start',
    startDate   => $startDt->clone->add(days => -1)->toDatabaseDate,
    endDate     => $startDt->clone->add(days => -1)->toDatabaseDate,
    timeZone    => $tz,
},);

my $justAfter = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Just after the window.  Start date coincident with window end',
    startDate   => $endDt->clone->add(days => 1)->toDatabaseDate,
    endDate     => $endDt->clone->add(days => 1)->toDatabaseDate,
    timeZone    => $tz,
},);

my $starting = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Inside the window, same start date',
    startDate   => $startDt->toDatabaseDate,
    endDate     => $startDt->toDatabaseDate,
    timeZone    => $tz,
}, );

my $ending = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Inside the window, same end date',
    startDate   => $endDt->clone->add(days => -1)->toDatabaseDate,
    endDate     => $endDt->clone->add(days => -1)->toDatabaseDate,
    timeZone    => $tz,
},);

my $coincident = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Coincident with the window start and window end',
    startDate   => $startDt->toDatabaseDate,
    endDate     => $endDt->toDatabaseDate,
    timeZone    => $tz,
},);

my $coincidentLow = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Coincident with the window start',
    startDate   => $startDt->toDatabaseDate,
    endDate     => $endDt->clone->add(days => 1)->toDatabaseDate,
    timeZone    => $tz,
},);

my $coincidentHigh = $windowCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Coincident with the window end',
    startDate   => $startDt->clone->add( days => -1, )->toDatabaseDate,
    endDate     => $endDt->toDatabaseDate,
    timeZone    => $tz,
},);

#    no suffix = all day event
#    wt suffix = with times
#                      inside
#                      insidewt
#          |-------------straddle-----------------|
#          |-------------straddlewt---------------|
#      straddleLowwt
#                                           straddleHighwt
#              |----------coincident-----------|
#              |----------coincidentLow------------------|
#    |--------------------coincidentHigh-------|
# window:      |-------------------------------|
#  starting--->|
#                                             |<---ending
#   justBeforewt                               justAfterwt
#     justBefore                               justAfter
#                                                 outside high
# outside low
#
# Everything above the window should be included in the set of events returned.

$tag2->commit;
WebGUI::Test->addToCleanup($tag2);

is(scalar @{ $windowCal->getLineage(['children'])}, 17, 'added events to the window calendar');

my @window = $windowCal->getEventsIn($windowStart->toDatabase, $windowEnd->toDatabase);

cmp_bag(
    [ map { $_->get('title') } @window ],
    [ map { $_->get('title') }
        ($inside,     $insidewt,
         $straddle,   $straddleHighwt, $straddleLowwt,  $straddlewt,
         $coincident, $coincidentLow,  $coincidentHigh, $starting,
         $ending, )
    ],
    '..returns correct set of events'
);

######################################################################
#
# viewWeek
#
######################################################################

my $weekCal = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Calendar for doing event span testing, week',
});

my $allDayDt = $bday->cloneToUserTimeZone;

my $nextWeekDt = $bday->cloneToUserTimeZone->add(weeks => 1)->truncate( to => 'week')->add(days => 6, hours => 19);

my $allDay = $weekCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'An event with explicit times that lasts all day',
    startDate   => $allDayDt->toDatabaseDate,
    endDate     => $allDayDt->clone->add(days => 1)->toDatabaseDate,
    startTime   => $allDayDt->clone->truncate(to => 'day')->toDatabaseTime,
    endTime     => $allDayDt->clone->add(days => 1)->truncate(to => 'day')->toDatabaseTime,
    timeZone    => $tz,
}, );

my $endOfWeek = $weekCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Event at the end of the week',
    startDate   => $nextWeekDt->toDatabaseDate,
    endDate     => $nextWeekDt->toDatabaseDate,
    startTime   => $nextWeekDt->toDatabaseTime,
    endTime     => $nextWeekDt->clone->add(hours => 1)->toDatabaseTime,
    timeZone    => $tz,
}, );

my $weekVars = $weekCal->viewWeek({ start => $bday });
my @eventBins = ();
foreach my $day (@{ $weekVars->{days} }) {
    if (exists $day->{events} and scalar @{ $day->{events} } > 0) {
        push @eventBins, $day->{dayOfWeek};
    }
}

cmp_deeply(
    \@eventBins,
    [ 4 ],
    'viewWeek: all day event is only in 1 day when time zones line up correctly'
);

$weekVars = $weekCal->viewWeek({ start => $nextWeekDt });
@eventBins = ();
foreach my $day (@{ $weekVars->{days} }) {
    if (exists $day->{events} and scalar @{ $day->{events} } > 0) {
        push @eventBins, $day->{dayOfWeek};
    }
}

cmp_deeply(
    \@eventBins,
    [ 7 ],
    '... end of week event in proper bin, considering time zone'
);

################################################################
#
# wrapIcal
#
################################################################

#Any old calendar will do for these tests.

foreach my $test (@icalWrapTests) {
    my ($in, $out, $comment) = @{ $test }{ qw/in out comment/ };
    my $wrapOut = $cal->wrapIcal($in);
    is ($wrapOut, $out, $comment);
}

######################################################################
#
# viewMonth
#
######################################################################

my $monthCal = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Calendar for doing event span testing, month',
});

$allDayDt       = $bday->cloneToUserTimeZone;
my $nextMonthDt = $bday->cloneToUserTimeZone->add(months => 1)->truncate( to => 'month')->add(days => 29, hours => 19);

$allDay = $monthCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'An event with explicit times that lasts all day',
    startDate   => $allDayDt->toDatabaseDate,
    endDate     => $allDayDt->clone->add(days => 1)->toDatabaseDate,
    startTime   => $allDayDt->clone->truncate(to => 'day')->toDatabaseTime,
    endTime     => $allDayDt->clone->add(days => 1)->truncate(to => 'day')->toDatabaseTime,
    timeZone    => $tz,
},);

my $endOfMonth = $monthCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Event at the end of the month',
    startDate   => $nextMonthDt->toDatabaseDate,
    endDate     => $nextMonthDt->toDatabaseDate,
    startTime   => $nextMonthDt->toDatabaseTime,
    endTime     => $nextMonthDt->clone->add(hours => 1)->toDatabaseTime,
    timeZone    => $tz,
}, );

my $monthVars = $monthCal->viewMonth({ start => $bday });
@eventBins = ();
foreach my $week ( @{ $monthVars->{weeks} } ) {
    foreach my $day (@{ $week->{days} }) {
        if (exists $day->{events} and scalar @{ $day->{events} } > 0) {
            push @eventBins, $day->{dayMonth};
        }
    }
}

cmp_deeply(
    \@eventBins,
    [ 16 ],
    'viewMonth: all day event is only in 1 day when time zones line up correctly'
);

$monthVars = $monthCal->viewMonth({ start => $nextMonthDt });
@eventBins = ();
foreach my $week ( @{ $monthVars->{weeks} } ) {
    foreach my $day (@{ $week->{days} }) {
        if (exists $day->{events} and scalar @{ $day->{events} } > 0) {
            push @eventBins, $day->{dayMonth};
        }
    }
}

cmp_deeply(
    \@eventBins,
    [ 30 ],
    '... end of month event in proper bin'
);


######################################################################
#
# viewDay
#
######################################################################

my $dayCal = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Calendar for doing event span testing, day',
});

$allDayDt     = $bday->cloneToUserTimeZone;
my $nextDayDt = $bday->cloneToUserTimeZone->add(days => 1)->truncate( to => 'day')->add(hours => 19);

$allDay = $dayCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'An event with explicit times that lasts all day',
    startDate   => $allDayDt->toDatabaseDate,
    endDate     => $allDayDt->clone->add(days => 1)->toDatabaseDate,
    startTime   => $allDayDt->clone->truncate(to => 'day')->toDatabaseTime,
    endTime     => $allDayDt->clone->add(days => 1)->truncate(to => 'day')->toDatabaseTime,
    timeZone    => $tz,
}, );

my $nextDay = $dayCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Event at the end of the next day',
    startDate   => $nextDayDt->toDatabaseDate,
    endDate     => $nextDayDt->toDatabaseDate,
    startTime   => $nextDayDt->toDatabaseTime,
    endTime     => $nextDayDt->clone->add(hours => 1)->toDatabaseTime,
    timeZone    => $tz,
},);

my $hourVars = $dayCal->viewDay({ start => $nextDayDt });
@eventBins = ();
foreach my $slot (@{ $hourVars->{hours} }) {
    if (exists $slot->{events} and scalar @{ $slot->{events} } > 0) {
        push @eventBins, $slot->{hour24};
    }
}

cmp_deeply(
    \@eventBins,
    [ 19 ],
    '... end of day event in proper bin'
);

######################################################################
#
# viewList
#
######################################################################

my $listCal = $node->addChild({
    className            => 'WebGUI::Asset::Wobject::Calendar',
    title                => 'Calendar for doing event span testing, list',
    listViewPageInterval => 3600*24*3,
});

$allDayDt     = $bday->cloneToUserTimeZone->truncate( to => 'day' );
my $prevDayDt = $bday->cloneToUserTimeZone->truncate( to => 'day' )->subtract(days => 1)->add(hours => 19);

$allDay = $listCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'An event with explicit times that lasts all day',
    startDate   => $allDayDt->toDatabaseDate,
    endDate     => $allDayDt->clone->add(days => 1)->toDatabaseDate,
    startTime   => $allDayDt->toDatabaseTime,
    endTime     => $allDayDt->clone->add(days => 1)->toDatabaseTime,
    timeZone    => $tz,
}, undef, undef, {skipAutoCommitWorkflows => 1});

my $prevDay = $listCal->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'Event at the end of the previous day',
    startDate   => $prevDayDt->toDatabaseDate,
    endDate     => $prevDayDt->toDatabaseDate,
    startTime   => $prevDayDt->toDatabaseTime,
    endTime     => $prevDayDt->clone->add(hours => 1)->toDatabaseTime,
    timeZone    => $tz,
}, undef, undef, {skipAutoCommitWorkflows => 1});

my $tag6 = WebGUI::VersionTag->getWorking($session);
$tag6->commit;
WebGUI::Test->addToCleanup($tag6);

my $listVars = $listCal->viewList({ start => $bday });

@eventBins = ();
foreach my $event (@{ $listVars->{events} }) {
    push @eventBins, $event->{eventAssetId};
}

cmp_deeply(
    \@eventBins,
    [ $allDay->getId ],
    '... correct set of events in list view'
);


######################################################################
#
# getFeeds
#
######################################################################

my $feedCal = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Calendar for doing feed tests',
});

cmp_deeply(
    $feedCal->getFeeds(),
    [],
    'getFeeds: returns an empty array ref with no feeds'
);

##Update with JSON and try again :)
$feedCal->update({icalFeeds => '[]'});
is_deeply $feedCal->get('icalFeeds'), [], 'set as JSON, returned perl';

cmp_deeply(
    $feedCal->getFeeds(),
    [],
    'but getFeeds still returns a data structure.'
);
