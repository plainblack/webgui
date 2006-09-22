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
use WebGUI::Session::Var;

use Test::More tests => 25; # increment this value for each test you create
use Test::Deep;
 
my $session = WebGUI::Test->session;
 
ok($session->var->getId ne "", "getId()");
cmp_ok($session->var->get("lastPageView"), '>', 0, "get(lastPageView)");
is($session->var->isAdminOn, 0, "isAdminOn()");
$session->var->switchAdminOn;
is($session->var->isAdminOn, 1, "switchAdminOn()");
$session->var->switchAdminOff;
is($session->var->isAdminOn, 0, "switchAdminOff()");

my $id = $session->var->getId;
my ($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$id]);
is($count, 1,"created an user session entry in the database");

my %newEnvHash = ( REMOTE_ADDR => '192.168.0.34');
my $origEnv = $session->env->{_env};
$session->env->{_env} = \%newEnvHash;

my $varTime = time();
my $varExpires = $varTime + $session->setting->get('sessionTimeout');
my $var = WebGUI::Session::Var->new($session);
isa_ok($var, 'WebGUI::Session::Var', 'new returns Var object');
is($var->get('userId'), 1, 'default userId is 1');

is($var->get('sessionId'), $var->getId, "get('sessionId') and getId return the same thing");
isnt($var->getId, $session->var->getId, "a sessionId different from our Session's var sessionId was created");
is($var->getId, $session->getId, 'SessionId set to userSessionId from var');

is($var->get('adminOn'), $var->isAdminOn, "get('adminOn') and isAdminOn return the same thing");
is($var->get('adminOn'), 0, "adminOn is off by default"); ##retest

cmp_ok(abs($var->get('lastPageView') - $varTime), '<=', 1, 'lastPageView set correctly');
cmp_ok(abs($var->get('expires') - $varExpires), '<=', 1, 'expires set correctly');

is($var->get('lastIP'), '192.168.0.34', "lastIP fetched");

isa_ok($var->session, 'WebGUI::Session', 'session method returns a Session object');
is($var->session->getId, $session->getId, 'session method returns our Session object');

sleep(2);
$newEnvHash{REMOTE_ADDR} = '10.0.5.5';

#Grab a more recent version of our user session object
$varTime = time();
$varExpires = $varTime + $session->setting->get('sessionTimeout');
my $var2 = WebGUI::Session::Var->new($session, $session->getId);

cmp_deeply(
	$var2,
	methods(
		['get', 'sessionId'] => $var->get('sessionId'),
		['get', 'userId']    => $var->get('userId'),
		['get', 'adminOn']   => $var->get('adminOn'),
	),
	'similar methods in copy of original var object'
);

cmp_ok(abs($var2->get('lastPageView') - $varTime), '<=', 1, 'lastPageView set correctly on copy');
cmp_ok(abs($var2->get('expires') - $varExpires), '<=', 1, 'expires set correctly on copy');
is($var2->get('lastIP'), '10.0.5.5', "lastIP set on copy");

my $var2Id = $var2->getId;
$var2->end;
($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$var2->getId]);
ok($count == 0,"end() removes current entry from database");
$var->end;

$session->env->{_env} = $origEnv;

TODO: {
	local $TODO = "Stuff to write later";
	ok(0, 'check fetching a non-existant sessionId');
	ok(0, 'check fetching a non-existant sessionId with noFuss');
}

END: {
	foreach my $varObj ($var, $var2) {
		if (defined $varObj and ref $varObj eq 'WebGUI::Session::Var') {
			$varObj->end();
		}
	}
}
