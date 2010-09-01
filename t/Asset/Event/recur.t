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

# Tests the recurrence functionality of calendar events

use strict;


use Test::More;
use DateTime;
use WebGUI::Asset::Event;

my $startDate = DateTime->new(
    year  => 2000,
    month => 1,
    day   => 1
);

sub recur {
    my ($type, $interval, $count, @extra) = @_;
    my $r = {
        recurType => $type,
        every     => $interval,
        endAfter  => $count,
        @extra,
    };
    return [
        map {$_->ymd} WebGUI::Asset::Event->dateSet($r, $startDate)->as_list
    ]
}

is_deeply recur(daily => 3 => 5), [
    '2000-01-01', '2000-01-04', '2000-01-07', '2000-01-10', '2000-01-13',
];

is_deeply recur(weekday => 3 => 5), [
    '2000-01-05', '2000-01-10', '2000-01-13', '2000-01-18', '2000-01-21',
];

is_deeply recur(weekly => 2 => 10 => dayNames => [qw(m w f)]), [
    '2000-01-10', '2000-01-12', '2000-01-14',
    '2000-01-24', '2000-01-26', '2000-01-28',
    '2000-02-07', '2000-02-09', '2000-02-11', '2000-02-21'
];

is_deeply recur(monthDay => 3 => 4 => dayNumber => 4), [
    '2000-01-04', '2000-04-04', '2000-07-04', '2000-10-04'
];

is_deeply recur(monthWeek => 1 => 6 => dayNames => ['w'], weeks => ['fifth']), [
    '2000-01-26', '2000-02-23', '2000-03-29',
    '2000-04-26', '2000-05-31', '2000-06-28',
];

is_deeply recur(yearDay => 2 => 3, months => ['feb'], dayNumber => 2), [
    '2000-02-02', '2002-02-02', '2004-02-02',
];

my %labor_day = (
    months => ['sep'],
    weeks  => ['first'],
    dayNames => ['m'],
);
is_deeply recur(yearWeek => 3 => 3, %labor_day), [
    '2000-09-04', '2003-09-01', '2006-09-04'
];

done_testing;

#----------------------------------------------------------------------------
#vim:ft=perl
