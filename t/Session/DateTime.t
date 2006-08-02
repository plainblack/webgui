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

use Test::More tests => 28; # increment this value for each test you create
 
my $session = WebGUI::Test->session;

my $wgbday = 997966800;
my $bdayCopy = $wgbday;
ok($session->datetime->addToDate($wgbday,1,2,3) >= $wgbday+1*60*60*24*365+2*60*60*24*28+3*60*60*24, "addToDate()"); 
ok($session->datetime->addToTime($wgbday,1,2,3) >= $wgbday+1*60*60+2*60+3, "addToTime()"); 
ok($session->datetime->addToDateTime($wgbday,1,2,3,4,5,6) >= $wgbday+1*60*60*24*365+2*60*60*24*28+3*60*60*24+4*60*60+5*60+6, "addToDateTime()"); 
my ($start, $end) = $session->datetime->dayStartEnd($wgbday);
ok($end-$start >= 60*60*23, "dayStartEnd()"); 
is($session->datetime->epochToHuman($wgbday,"%y"), "2001", "epochToHuman() - year"); 
is($session->datetime->epochToHuman($wgbday,"%c"), "August", "epochToHuman() - month name"); 
is($session->datetime->epochToHuman($wgbday,"%m"), "08", "epochToHuman() - month number, 2 digit"); 
is($session->datetime->epochToHuman($wgbday,"%M"), "8", "epochToHuman() - month number, variable digit"); 
is($session->datetime->epochToHuman($wgbday,"%%%c%d%h"), "%August1608", "epochToHuman()"); 
is($session->datetime->epochToHttp($wgbday),"Thu, 16 Aug 2001 13:08:00 GMT","epochToHttp()");
is($session->datetime->epochToSet($wgbday,1), "2001-08-16 08:00:00", "epochToSet()");
is($session->datetime->getDayName(7), "Sunday", "getDayName()");
is($session->datetime->getDaysInMonth($wgbday), 31, "getDaysInMonth()");
is($session->datetime->getDaysInInterval($wgbday,$wgbday+3*60*60*24), 3, "getDaysInInterval()");
is($session->datetime->getFirstDayInMonthPosition($wgbday), 3, "getFirstDayInMonthPosition()");
is($session->datetime->getMonthName(1), "January", "getMonthName()");
is($session->datetime->getSecondsFromEpoch($wgbday), 60*60*8, "getSecondsFromEpoch()");
SKIP: {
	skip("getTimeZones() - not sure how to test",1);
	ok($session->datetime->getTimeZones(),"getTimeZones()");
    }
is($session->datetime->humanToEpoch("2001-08-16 08:00:00"), $wgbday, "humanToEpoch()");
is($session->datetime->intervalToSeconds(2,"weeks"),60*60*24*14, "intervalToSeconds()");
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


