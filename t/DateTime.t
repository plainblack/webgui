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
use WebGUI::User;

# load your modules here

use Test::More;

my $session = WebGUI::Test->session;

# put your tests here

my $numTests = 1 + 17;
plan tests => $numTests;

my $loaded = use_ok("WebGUI::DateTime");

my $timeZoneUser = addUser($session);

SKIP: {

skip "Unable to load WebGUI::DateTime", $numTests-1 unless $loaded;

my $dt = WebGUI::DateTime->new($session,"2006-11-06 21:12:45");

isa_ok($dt, "WebGUI::DateTime", "constructor");
isa_ok($dt, "DateTime", "constructor");

is($dt->toDatabase,     "2006-11-06 21:12:45", "toDatabase returns the identical string since it is in UTC");
is($dt->toDatabaseDate, "2006-11-06",          "toDatabaseDate returns the identical date since it is in UTC");
is($dt->toDatabaseTime, "21:12:45",            "toDatabaseTime returns the identical time since it is in UTC");

$session->user({user => $timeZoneUser});

my $copiedDt = $dt->cloneToUserTimeZone;
isa_ok($copiedDt,          "WebGUI::DateTime", "cloneToUserTimeZone");
isa_ok($copiedDt->session, "WebGUI::Session",  "cloneToUserTimeZone also copies over the session object");

is($copiedDt->time_zone()->name, "America/Hermosillo", "cloned object has correct time zone");
is($dt->time_zone()->name,       "UTC",                "original object is still UTC");

is($copiedDt->toUserTimeZone(),     "2006-11-06 14:12:45", "toUserTimeZone obeys the time zone");
is($copiedDt->toUserTimeZoneDate(), "2006-11-06",          "toUserTimeZoneDate obeys the time zone");
is($copiedDt->toUserTimeZoneTime(), "14:12:45",            "toUserTimeZoneTime obeys the time zone");

$copiedDt->add(hours => 1);

isa_ok($copiedDt,          "WebGUI::DateTime", "add returns itself");
isa_ok($copiedDt->session, "WebGUI::Session",  "add does not nuke $session");

is($copiedDt->time_zone()->name, "America/Hermosillo",  "add does not change the time zone");
is($copiedDt->toUserTimeZone(),  "2006-11-06 15:12:45", "add returns the correct time");

my $epochDt = WebGUI::DateTime->new($session, "1169141075");
isa_ok($epochDt, "WebGUI::DateTime", "epochal construction");

}

sub addUser {
	my $session = shift;
	my $user = WebGUI::User->new($session, "new");

	##From my research, this particular time zone does NOT follow daylight savings,
	##so the test will not fail in the summer
	$user->profileField("timeZone","America/Hermosillo");
	$user->username("Time Zone");
    WebGUI::Test->usersToDelete($user);
	return $user;
}

END { ##Clean-up after yourself, always
}

