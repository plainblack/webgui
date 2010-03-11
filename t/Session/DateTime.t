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
use lib "$FindBin::Bin/../lib";
use File::Copy;
use File::Spec;

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 90; # increment this value for each test you create

local @INC = @INC;
unshift @INC, File::Spec->catdir( WebGUI::Test->getTestCollateralPath, 'Session-DateTime', 'lib' );

my $session = WebGUI::Test->session;

my $dt = $session->datetime;

my $wgbday = 997966800;
my $bdayCopy = $wgbday;
my ($start, $end) = $session->datetime->dayStartEnd($wgbday);
ok($end-$start >= 60*60*23, "dayStartEnd()"); 
is($dt->epochToHuman($wgbday,"%y"), "2001", "epochToHuman() - year"); 
is($dt->epochToHuman($wgbday,"%c"), "August", "epochToHuman() - month name"); 
is($dt->epochToHuman($wgbday,"%m"), "08", "epochToHuman() - month number, 2 digit"); 
is($dt->epochToHuman($wgbday,"%M"), "8", "epochToHuman() - month number, variable digit"); 
is($dt->epochToHuman($wgbday,"%n"), "00", "epochToHuman() - 2 digit minute"); 
is($dt->epochToHuman($wgbday,"%%%c%d%h"), "%August1608", "epochToHuman()"); 
is($dt->epochToHttp($wgbday),"Thu, 16 Aug 2001 13:00:00 GMT","epochToHttp()");
is($dt->epochToMail($wgbday),"Thu, 16 Aug 2001 08:00:00 -0500","epochToMail()");
is($dt->epochToSet($wgbday,1), "2001-08-16 08:00:00", "epochToSet(), with time");
is($dt->epochToSet($wgbday),   "2001-08-16",          "epochToSet(), without time");
is($dt->getDayOfWeek($wgbday), 4, "getDayOfWeek()");
is($dt->getDayName(7), "Sunday", "getDayName()");
is($dt->getDayName(8), undef,    "getDayName(), too high returns undef");
is($dt->getDayName(0), undef,    "getDayName(), too low returns undef");
is($dt->getDaysInMonth($wgbday), 31, "getDaysInMonth()");
is($dt->getDaysInInterval($wgbday,$wgbday+3*60*60*24), 3, "getDaysInInterval()");
is($dt->getFirstDayInMonthPosition($wgbday), 3, "getFirstDayInMonthPosition()");
is($dt->getMonthName(1), "January", "getMonthName()");
is($dt->getMonthName(0), undef,     "getMonthName returns undef if too low");
is($dt->getMonthName(25), undef,    "getMonthName returns undef if too high");
is($dt->getSecondsFromEpoch($wgbday), 60*60*8, "getSecondsFromEpoch()");
is(join("-",$dt->localtime($wgbday)),'2001-8-16-8-0-0-228-4-1', "localtime()");
is($dt->monthCount($wgbday,$wgbday+60*60*24*365), 12, "monthCount()");
my ($start, $end) = $dt->monthStartEnd($wgbday);
ok($end-$start >= 60*60*24*28, "monthStartEnd()"); 
is($dt->secondsToTime(60*60*8),"08:00:00", "secondsToTime()");
ok($dt->time() > $wgbday,"time()");
is($dt->timeToSeconds("08:00:00"), 60*60*8, "timeToSeconds()");

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

my $visitorTimeZone = $dt->getTimeZone();
is ($visitorTimeZone, 'America/Chicago', 'getTimeZone: default time zone for visitor is America/Chicago');
is ($dt->getTimeZone(), 'America/Chicago', 'getTimeZone: fetching cached version from user object');

my $buster = WebGUI::User->new($session, "new");
$buster->profileField('timeZone', 'Amerigo/Vespucci');
$session->user({user => $buster});
my $user_guard = cleanupGuard $buster;
is ($dt->getTimeZone(), 'America/Chicago', 'getTimeZone: time zones not in the approved list get reset to the default');

my $dude = WebGUI::User->new($session, "new");
$dude->profileField('timeZone', 'Australia/Perth');
$session->user({user => $dude});
WebGUI::Test->usersToDelete($dude);
is ($dt->getTimeZone(), 'Australia/Perth', 'getTimeZone: valid time zones are allowed');

my $bud = WebGUI::User->new($session, "new");
$bud->profileField('timeZone', '');
$session->user({user => $bud});
WebGUI::Test->usersToDelete($bud);
is ($dt->getTimeZone(), 'America/Chicago', q|getTimeZone: if user's time zone doesn't exist, then return America/Chicago|);

$session->user({userId => 1});  ##back to Visitor

####################################################
#
# mailToEpoch
#
####################################################

my $wgBdayMail = 'Thu, 16 Aug 2001 08:00:00 -0500';
is ($dt->mailToEpoch($wgBdayMail), $wgbday, 'mailToEpoch');

WebGUI::Test->interceptLogging();

is ($dt->mailToEpoch(750), undef, 'mailToEpoch returns undef on failure to parse');
like($WebGUI::Test::logger_warns, qr{750 is not a valid date for email}, "DateTime logs a warning on failure to parse");

####################################################
#
# getMonthDiff
#
####################################################

my $wgDayAfter = $wgbday + (3600*24);
is ($dt->getMonthDiff($wgbday, $wgDayAfter), 0, 'getMonthDiff = 0 (1 day apart)');
my $wgWeekAfter = $wgbday + (3600*24*7);
is ($dt->getMonthDiff($wgbday, $wgWeekAfter), 0, 'getMonthDiff = 0 (1 week apart)');
my $wgMonthAfter = $wgbday + (3600*24*32);
is ($dt->getMonthDiff($wgbday, $wgMonthAfter), 1, 'getMonthDiff = 1 (1 month apart)');
$wgMonthAfter = $wgbday + (3600*24*70);
is ($dt->getMonthDiff($wgbday, $wgMonthAfter), 2, 'getMonthDiff = 2 (2 month apart)');
my $wgYearAfter = $wgbday + (3600*24*(365+32));
is ($dt->getMonthDiff($wgbday, $wgYearAfter), 13, 'getMonthDiff = 13 (1+ years apart)');

####################################################
#
# getTimeZones
#
####################################################

use DateTime::TimeZone;
my $dt_tzs = DateTime::TimeZone::all_names;
my $wg_tzs = $dt->getTimeZones();
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

ok($dt->addToDate($wgbday,1,2,3) >= $wgbday+1*60*60*24*365+2*60*60*24*28+3*60*60*24, "addToDate()"); 
is($dt->addToDate($wgbday), $wgbday, 'addToDate defaults to adding 0');
cmp_ok(
    abs($dt->addToDate()-time),
    '<=',
    1,
    "addToDate() with no arguments returns the current time"
);

####################################################
#
# addToTime
#
####################################################

ok($dt->addToTime($wgbday,1,2,3) >= $wgbday+1*60*60+2*60+3, "addToTime()"); 
is($dt->addToTime($wgbday), $wgbday, 'addToTime defaults to adding 0');
cmp_ok(
    abs($dt->addToTime()-time),
    '<=',
    1,
    "addToTime() with no arguments returns the current time"
);


####################################################
#
# addToDateTime
#
####################################################

ok($dt->addToDateTime($wgbday,1,2,3,4,5,6) >= $wgbday+1*60*60*24*365+2*60*60*24*28+3*60*60*24+4*60*60+5*60+6, "addToDateTime()"); 
is($dt->addToDateTime($wgbday), $wgbday, 'addToDateTime defaults to adding 0');
cmp_ok(
    abs($dt->addToDateTime()-time),
    '<=',
    1,
    "addToDateTime() with no arguments returns the current time"
);

####################################################
#
# secondsToInterval
#
####################################################

is(join(" ",$dt->secondsToInterval(60*60*24*365*2)),   "2 Year(s)",     "secondsToInterval(), years");
is(join(" ",$dt->secondsToInterval(60*60*24*180)),     "6 Month(s)",    "secondsToInterval(), months");
is(join(" ",$dt->secondsToInterval(60*60*24*7*3)),     "3 Week(s)",     "secondsToInterval(), weeks");
is(join(" ",$dt->secondsToInterval(60*60*24*5)),       "5 Day(s)",      "secondsToInterval(), days");
is(join(" ",$dt->secondsToInterval(60*60*24*8)),       "1 Week(s)",     "secondsToInterval(), days, longer than a week");
is(join(" ",$dt->secondsToInterval(60*60*24*363)),     "12 Month(s)",   "secondsToInterval(), days, longer than a month");
is(join(" ",$dt->secondsToInterval(60*60*24*365*2.4)), "2 Year(s)",     "secondsToInterval(), days, longer than a year");
is(join(" ",$dt->secondsToInterval(60*60*18)),         "18 Hour(s)",    "secondsToInterval(), hours");
is(join(" ",$dt->secondsToInterval(60*60*24*365*2.9)), "3 Year(s)",     "secondsToInterval(), hours, longer than a year");
is(join(" ",$dt->secondsToInterval(60*27)),            "27 Minute(s)",  "secondsToInterval(), minutes");
is(join(" ",$dt->secondsToInterval(59)),               "59 Second(s)",  "secondsToInterval(), seconds");

####################################################
#
# secondsToExactInterval
#
####################################################

is(join(" ",$dt->secondsToExactInterval(60*60*24*365*2)),   "2 Year(s)",     "secondsToExactInterval(), years");
is(join(" ",$dt->secondsToExactInterval(60*60*24*180)),     "6 Month(s)",    "secondsToExactInterval(), months");
is(join(" ",$dt->secondsToExactInterval(60*60*24*7*3)),     "3 Week(s)",     "secondsToExactInterval(), weeks");
is(join(" ",$dt->secondsToExactInterval(60*60*24*5)),       "5 Day(s)",      "secondsToExactInterval(), days");
is(join(" ",$dt->secondsToExactInterval(60*60*24*8)),       "8 Day(s)",      "secondsToExactInterval(), days, longer than a week");
is(join(" ",$dt->secondsToExactInterval(60*60*24*363)),     "363 Day(s)",    "secondsToExactInterval(), days, longer than a month");
is(join(" ",$dt->secondsToExactInterval(60*60*24*365*2.4)), "876 Day(s)",    "secondsToExactInterval(), days, longer than a year");
is(join(" ",$dt->secondsToExactInterval(60*60*18)),         "18 Hour(s)",    "secondsToExactInterval(), hours");
is(join(" ",$dt->secondsToExactInterval(60*60*24*365*2.9)), "25404 Hour(s)", "secondsToExactInterval(), hours, longer than a year");
is(join(" ",$dt->secondsToExactInterval(60*27)),            "27 Minute(s)",  "secondsToExactInterval(), minutes");
is(join(" ",$dt->secondsToExactInterval(59)),               "59 Second(s)",  "secondsToExactInterval(), seconds");

####################################################
#
# intervalToSeconds
#
####################################################

is($dt->intervalToSeconds(40),            40,          "intervalToSeconds() seconds as default");
is($dt->intervalToSeconds(59, 'seconds'), 59,          "intervalToSeconds() seconds");
is($dt->intervalToSeconds(3,  'minutes'), 60*3,        "intervalToSeconds() minutes");
is($dt->intervalToSeconds(2,  'hours'),   60*60*2,     "intervalToSeconds() hours");
is($dt->intervalToSeconds(1,  'days'),    60*60*24,    "intervalToSeconds() days");
is($dt->intervalToSeconds(2,  'weeks'),   60*60*24*14, "intervalToSeconds() weeks");
is($dt->intervalToSeconds(5,  'months'),  60*60*24*30*5, "intervalToSeconds() months");
is($dt->intervalToSeconds(7,  'years'),   60*60*24*365*7, "intervalToSeconds() years");

####################################################
#
# humanToEpoch
#
####################################################

is($dt->humanToEpoch("2001-08-16 08:00:00"), $wgbday, "humanToEpoch()");
is($dt->humanToEpoch("2001-08-16 24:00:00"), $wgbday-8*3600, "humanToEpoch() sets hour 24 to 0");

####################################################
#
# setToEpoch
#
####################################################

is($dt->setToEpoch(), undef, "setToEpoch() returns undef with no set time");
is($dt->setToEpoch("2001-08-16"),          $wgbday-3600*8, "setToEpoch() date only");
is($dt->setToEpoch("2001-08-16 08:00:00"), $wgbday,        "setToEpoch() date and time");
isnt($dt->setToEpoch("2001:08:16 08-00000"), $wgbday,      "setToEpoch() with bad format does not return wgbday");
cmp_ok(
    abs($dt->setToEpoch("2001:08:16 08-00000")-time),
    '<=',
    1,
    "setToEpoch() with bad format returns current time"
);

####################################################
#
# epochToHuman
#
####################################################

$dude->profileField('language', 'BadLocale');
$session->user({user => $dude});
is($dt->epochToHuman($wgbday), '8/16/2001  9:00 pm', 'epochToHuman: constructs a default locale if the language does not provide one.');
$session->user({userId => 1});

