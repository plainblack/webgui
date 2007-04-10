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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 69; # increment this value for each test you create
 
my $session = WebGUI::Test->session;

my $wgbday = 997966800;
my $bdayCopy = $wgbday;
my ($start, $end) = $session->datetime->dayStartEnd($wgbday);
ok($end-$start >= 60*60*23, "dayStartEnd()"); 
is($session->datetime->epochToHuman($wgbday,"%y"), "2001", "epochToHuman() - year"); 
is($session->datetime->epochToHuman($wgbday,"%c"), "August", "epochToHuman() - month name"); 
is($session->datetime->epochToHuman($wgbday,"%m"), "08", "epochToHuman() - month number, 2 digit"); 
is($session->datetime->epochToHuman($wgbday,"%M"), "8", "epochToHuman() - month number, variable digit"); 
is($session->datetime->epochToHuman($wgbday,"%n"), "00", "epochToHuman() - 2 digit minute"); 
is($session->datetime->epochToHuman($wgbday,"%%%c%d%h"), "%August1608", "epochToHuman()"); 
is($session->datetime->epochToHttp($wgbday),"Thu, 16 Aug 2001 13:00:00 GMT","epochToHttp()");
is($session->datetime->epochToMail($wgbday),"Thu, 16 Aug 2001 08:00:00 -0500","epochToMail()");
is($session->datetime->epochToSet($wgbday,1), "2001-08-16 08:00:00", "epochToSet(), with time");
is($session->datetime->epochToSet($wgbday),   "2001-08-16",          "epochToSet(), without time");
is($session->datetime->getDayOfWeek($wgbday), 4, "getDayOfWeek()");
is($session->datetime->getDayName(7), "Sunday", "getDayName()");
is($session->datetime->getDayName(8), undef,    "getDayName(), too high returns undef");
is($session->datetime->getDayName(0), undef,    "getDayName(), too low returns undef");
is($session->datetime->getDaysInMonth($wgbday), 31, "getDaysInMonth()");
is($session->datetime->getDaysInInterval($wgbday,$wgbday+3*60*60*24), 3, "getDaysInInterval()");
is($session->datetime->getFirstDayInMonthPosition($wgbday), 3, "getFirstDayInMonthPosition()");
is($session->datetime->getMonthName(1), "January", "getMonthName()");
is($session->datetime->getMonthName(0), undef,     "getMonthName returns undef if too low");
is($session->datetime->getMonthName(25), undef,    "getMonthName returns undef if too high");
is($session->datetime->getSecondsFromEpoch($wgbday), 60*60*8, "getSecondsFromEpoch()");
is($session->datetime->humanToEpoch("2001-08-16 08:00:00"), $wgbday, "humanToEpoch()");
is(join("-",$session->datetime->localtime($wgbday)),'2001-8-16-8-0-0-228-4-1', "localtime()");
is($session->datetime->monthCount($wgbday,$wgbday+60*60*24*365), 12, "monthCount()");
my ($start, $end) = $session->datetime->monthStartEnd($wgbday);
ok($end-$start >= 60*60*24*28, "monthStartEnd()"); 
is(join(" ",$session->datetime->secondsToInterval(60*60*24*365*2)),"2 years", "secondsToInterval()");
is($session->datetime->secondsToTime(60*60*8),"08:00:00", "secondsToTime()");
is($session->datetime->setToEpoch("2001-08-16 08:00:00"), $wgbday, "setToEpoch()");
ok($session->datetime->time() > $wgbday,"time()");
is($session->datetime->timeToSeconds("08:00:00"), 60*60*8, "timeToSeconds()");

        my %conversion = (
                "%c" => "%B",
                "%C" => "%b",
                "%d" => "%d",
                "%D" => "%e",
                "%h" => "%I",
                "%H" => "%l",
                "%j" => "%H",
                "%J" => "%k",
                "%m" => "%m",
                "%M" => "%_varmonth_",
                "%n" => "%M",
		"%O" => "%z",
                "%p" => "%P",
                "%P" => "%p",
                "%s" => "%S",
                "%w" => "%A",
                "%W" => "%a",
                "%y" => "%Y",
                "%Y" => "%y"
                );

####################################################
#
# getTimeZone
#
####################################################

my $visitorTimeZone = $session->datetime->getTimeZone();
is ($visitorTimeZone, 'America/Chicago', 'getTimeZone: default time zone for visitor is America/Chicago');
is ($session->datetime->getTimeZone(), 'America/Chicago', 'getTimeZone: fetching cached version from user object');

my $buster = WebGUI::User->new($session, "new");
$buster->profileField('timeZone', 'Amerigo/Vespucci');
$session->user({user => $buster});
is ($session->datetime->getTimeZone(), 'America/Chicago', 'getTimeZone: time zones not in the approved list get reset to the default');

my $dude = WebGUI::User->new($session, "new");
$dude->profileField('timeZone', 'Australia/Perth');
$session->user({user => $dude});
is ($session->datetime->getTimeZone(), 'Australia/Perth', 'getTimeZone: valid time zones are allowed');

my $bud = WebGUI::User->new($session, "new");
$bud->profileField('timeZone', '');
$session->user({user => $bud});
is ($session->datetime->getTimeZone(), 'America/Chicago', q|getTimeZone: if user's time zone doesn't exist, then return America/Chicago|);

$session->user({userId => 1});  ##back to Visitor

####################################################
#
# mailToEpoch
#
####################################################

my $wgBdayMail = 'Thu, 16 Aug 2001 08:00:00 -0500';
is ($session->datetime->mailToEpoch($wgBdayMail), $wgbday, 'mailToEpoch');

is ($session->datetime->mailToEpoch(750), undef, 'mailToEpoch returns undef on failure to parse');
like($WebGUI::Test::logger_warns, qr{750 is not a valid date for email}, "DateTime logs a warning on failure to parse");

####################################################
#
# getMonthDiff
#
####################################################

my $wgDayAfter = $wgbday + (3600*24);
is ($session->datetime->getMonthDiff($wgbday, $wgDayAfter), 0, 'getMonthDiff = 0 (1 day apart)');
my $wgWeekAfter = $wgbday + (3600*24*7);
is ($session->datetime->getMonthDiff($wgbday, $wgWeekAfter), 0, 'getMonthDiff = 0 (1 week apart)');
my $wgMonthAfter = $wgbday + (3600*24*32);
is ($session->datetime->getMonthDiff($wgbday, $wgMonthAfter), 1, 'getMonthDiff = 1 (1 month apart)');
$wgMonthAfter = $wgbday + (3600*24*70);
is ($session->datetime->getMonthDiff($wgbday, $wgMonthAfter), 2, 'getMonthDiff = 2 (2 month apart)');
my $wgYearAfter = $wgbday + (3600*24*(365+32));
is ($session->datetime->getMonthDiff($wgbday, $wgYearAfter), 13, 'getMonthDiff = 13 (1+ years apart)');

####################################################
#
# getTimeZones
#
####################################################

use DateTime::TimeZone;
my $dt_tzs = DateTime::TimeZone::all_names;
my $wg_tzs = $session->datetime->getTimeZones();
is (scalar @{ $dt_tzs }, scalar keys %{ $wg_tzs }, 'getTimeZones: correct number of time zones');

my $timeZoneFormatFlag = 1;
foreach my $timeZone (keys %{ $wg_tzs } ) {
    my $tzLabel = $wg_tzs->{$timeZone};
    my $tz;
    ($tz = $timeZone) =~ tr/_/ /;
    if ($tz ne $tzLabel) {
        $timeZoneFormatFlag = 0;
    }
}

ok($timeZoneFormatFlag, 'getTimeZones: All time zones formatted correctly for reference and display');

####################################################
#
# addToDate
#
####################################################

ok($session->datetime->addToDate($wgbday,1,2,3) >= $wgbday+1*60*60*24*365+2*60*60*24*28+3*60*60*24, "addToDate()"); 
is($session->datetime->addToDate($wgbday), $wgbday, 'addToDate defaults to adding 0');

####################################################
#
# addToTime
#
####################################################

ok($session->datetime->addToTime($wgbday,1,2,3) >= $wgbday+1*60*60+2*60+3, "addToTime()"); 
is($session->datetime->addToTime($wgbday), $wgbday, 'addToTime defaults to adding 0');

####################################################
#
# addToDateTime
#
####################################################

ok($session->datetime->addToDateTime($wgbday,1,2,3,4,5,6) >= $wgbday+1*60*60*24*365+2*60*60*24*28+3*60*60*24+4*60*60+5*60+6, "addToDateTime()"); 
is($session->datetime->addToDateTime($wgbday), $wgbday, 'addToDateTime defaults to adding 0');

####################################################
#
# secondsToInverval
#
####################################################

is(join(" ",$session->datetime->secondsToInterval(60*60*24*365*2)), "2 years", "secondsToInterval(), years");
is(join(" ",$session->datetime->secondsToInterval(60*60*24*365*2.4)), "2 years", "secondsToInterval(), years, rounded down");
is(join(" ",$session->datetime->secondsToInterval(60*60*24*365*2.9)), "3 years", "secondsToInterval(), years, rounded up");
is(join(" ",$session->datetime->secondsToInterval(60*60*24*363)), "12 months",  "secondsToInterval(), months");
is(join(" ",$session->datetime->secondsToInterval(60*60*24*7*3)), "3 weeks",    "secondsToInterval(), weeks");
is(join(" ",$session->datetime->secondsToInterval(60*60*24*5)),   "5 days",     "secondsToInterval(), days");
is(join(" ",$session->datetime->secondsToInterval(60*60*18)),     "18 hours",   "secondsToInterval(), hours");
is(join(" ",$session->datetime->secondsToInterval(60*27)),        "27 minutes", "secondsToInterval(), minutes");
is(join(" ",$session->datetime->secondsToInterval(59)),           "59 seconds", "secondsToInterval(), seconds");

####################################################
#
# intervalToSeconds
#
####################################################

is($session->datetime->intervalToSeconds(40),            40,          "intervalToSeconds() seconds as default");
is($session->datetime->intervalToSeconds(59, 'seconds'), 59,          "intervalToSeconds() seconds");
is($session->datetime->intervalToSeconds(3,  'minutes'), 60*3,        "intervalToSeconds() minutes");
is($session->datetime->intervalToSeconds(2,  'hours'),   60*60*2,     "intervalToSeconds() hours");
is($session->datetime->intervalToSeconds(1,  'days'),    60*60*24,    "intervalToSeconds() days");
is($session->datetime->intervalToSeconds(2,  'weeks'),   60*60*24*14, "intervalToSeconds() weeks");
is($session->datetime->intervalToSeconds(5,  'months'),  60*60*24*30*5, "intervalToSeconds() months");
is($session->datetime->intervalToSeconds(7,  'years'),   60*60*24*365*7, "intervalToSeconds() years");

END {
    foreach my $account ($buster, $dude) {
        (defined $account  and ref $account  eq 'WebGUI::User') and $account->delete;
    }
}
