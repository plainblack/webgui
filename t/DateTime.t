#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::User;
use DateTime;
use WebGUI::DateTime;

# load your modules here

use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

# put your tests here

plan tests => 30;

my $timeZoneUser = addUser($session);

my $dt = WebGUI::DateTime->new($session,"2006-11-06 21:12:45");

isa_ok($dt, "WebGUI::DateTime", "constructor via epoch");
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
isa_ok($copiedDt->session, "WebGUI::Session",  "add does not nuke its session");

is($copiedDt->time_zone()->name, "America/Hermosillo",  "add does not change the time zone");
is($copiedDt->toUserTimeZone(),  "2006-11-06 15:12:45", "add returns the correct time");

my $epochDt = WebGUI::DateTime->new($session, "1169141075");
isa_ok($epochDt, "WebGUI::DateTime", "epochal construction");

my $now;
my $nowDt = WebGUI::DateTime->new($session);
isa_ok($nowDt, 'WebGUI::DateTime', 'constructed with undef');
cmp_deeply($nowDt->epoch, num(time(),5), '... uses now as the epoch');

$nowDt = WebGUI::DateTime->new($session, '');
isa_ok($nowDt, 'WebGUI::DateTime', 'constructed with empty string');
cmp_deeply($nowDt->epoch, num(time(),5), '... uses now as the epoch');

my $dt1970 = WebGUI::DateTime->new($session, 0);
isa_ok($dt1970, 'WebGUI::DateTime', 'constructed with 0');
is($dt1970->epoch, 0, '... uses 0 for epoch');

my $bday = WebGUI::DateTime->new($session, '2001-08-16');
isa_ok($bday, 'WebGUI::DateTime', 'constructed with mysql date, no time');
is(
    $bday->epoch,
    WebGUI::DateTime->new($session, WebGUI::Test->webguiBirthday)->truncate( to => 'day')->epoch,
    '... has correct epoch'
);

my $badday = eval { WebGUI::DateTime->new($session, '2001-08-161'); };
ok($@, 'new croaks on a bad date');
my $badday = eval { WebGUI::DateTime->new($session, '2001-08-16 99:99:99'); };
ok($@, 'new croaks on an out of range time');
my $badday = eval { WebGUI::DateTime->new($session, '2001-08-16 99:199:99'); };
ok($@, 'new croaks on an illegal time');


#----------------------------------------------------------------------------
# Test webguiToStrftime conversion
is( $nowDt->webguiToStrftime('%y-%m-%d'), '%Y-%m-%d', 'webgui to strftime conversion' );

$timeZoneUser->update({ 'dateFormat' => '%y-%M-%D' });
$timeZoneUser->update({ 'timeFormat' => '%H:%n %p' });
is( $nowDt->webguiToStrftime, '%Y-%_varmonth_-%e %l:%M %P', 'default datetime string' );


sub addUser {
	my $session = shift;
	my $user = WebGUI::User->new($session, "new");

	##From my research, this particular time zone does NOT follow daylight savings,
	##so the test will not fail in the summer
	$user->profileField("timeZone","America/Hermosillo");
	$user->username("Time Zone");
    WebGUI::Test->addToCleanup($user);
	return $user;
}
