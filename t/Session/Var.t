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

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Session::Var;

use Test::More tests => 44; # increment this value for each test you create
use Test::Deep;
 
my $session = WebGUI::Test->session;
 
ok($session->var->getId ne "", "getId()");
cmp_ok($session->var->get("lastPageView"), '>', 0, "get(lastPageView)");
is($session->var->isAdminOn, 0, "isAdminOn()");
$session->var->switchAdminOn;
is($session->var->isAdminOn, 1, "switchAdminOn()");
$session->var->switchAdminOff;
is($session->var->isAdminOn, 0, "switchAdminOff()");

my $token = $session->scratch->get('webguiCsrfToken');
ok( $token, 'CSRF token set');
ok( $session->id->valid($token), '...is a valid GUID');

my $id = $session->var->getId;
my ($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$id]);
is($count, 1, "created an user session entry in the database");

my $env = $session->request->env;
$env->{REMOTE_ADDR} = '192.168.0.34';

my $var = WebGUI::Session::Var->new($session);
my $varTime = time();
my $varExpires = $varTime + $session->setting->get('sessionTimeout');
isa_ok($var, 'WebGUI::Session::Var', 'new returns Var object');
isnt($session->scratch->get('webguiCsrfToken'), $token, '... calling new without sessionId creates a new token');
$token = $session->scratch->get('webguiCsrfToken');

cmp_ok(abs($var->get('lastPageView') - $varTime), '<=', 1, 'lastPageView set correctly');
cmp_ok(abs($var->get('expires') - $varExpires), '<=', 1, 'expires set correctly');

is($var->get('userId'), 1, 'default userId is 1');

is($var->get('sessionId'), $var->getId, "get('sessionId') and getId return the same thing");
isnt($var->getId, $session->var->getId, "a sessionId different from our Session's var sessionId was created");
is($var->getId, $session->getId, 'SessionId set to userSessionId from var');

is($var->get('adminOn'), $var->isAdminOn, "get('adminOn') and isAdminOn return the same thing");
is($var->get('adminOn'), 0, "adminOn is off by default"); ##retest

is($var->get('lastIP'), '192.168.0.34', "lastIP fetched");

isa_ok($var->session, 'WebGUI::Session', 'session method returns a Session object');
is($var->session->getId, $session->getId, 'session method returns our Session object');

sleep(2);
$env->{REMOTE_ADDR} = '10.0.5.5';

#Grab a more recent version of our user session object
$varTime = time();
my $var2 = WebGUI::Session::Var->new($session, $session->getId);
$varExpires = $varTime + $session->setting->get('sessionTimeout');
is($var2->session->scratch->get('webguiCsrfToken'), $token, 'opening a new user session did not change the CSRF token');

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

$var2 = WebGUI::Session::Var->new($session, 'illegalSessionIdThatIsTooLong');
#                                           '1234567890123456789012'
isa_ok($var2, 'WebGUI::Session::Var', 'invalid sessionId will still produce a Var object');
($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$var2->getId]);
is($count, 0, "object store of sessionId does not match database record");
$var2Id = $var2->getId;
$var2->end;
my $idToDelete = substr $var2Id,0,22;
($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$idToDelete]);
is($count, 1, "Unable to delete database record for Var object with invalid sessionId");

my $varId3 = 'nonExistantIdButValid0';
#            '1234567890123456789012'
$var = WebGUI::Session::Var->new($session, $varId3);
isa_ok($var, 'WebGUI::Session::Var', 'non-existant sessionId will still produce a Var object');
is($var->getId,     $varId3, 'user session Id set to non-existant Id');
is($session->getId, $varId3, 'session Id set to non-existant Id');

cmp_deeply(
	$var,
	methods(
		['get', 'sessionId'] => $varId3,
		['get', 'userId']    => 1,
		['get', 'adminOn']   => 0,
		['get', 'lastIP']   => '10.0.5.5',
	),
	'non-existant Id returns default values'
);

$var->end;

##Grab a new Var object that we'll expire.  We'll detect the expiration
##by looking for admin status and userId
$var2 = WebGUI::Session::Var->new($session);
$var2->switchAdminOn;

# jury rig the database and the cache to expire
$session->db->write("update userSession set userId=? where sessionId=?",
	[3, $var2->getId]);
$session->db->write("update userSession set expires=? where sessionId=?",
	[$var2->get('lastPageView')-1, $var2->getId]);
my %copyOfVar2 = %{$var2->{_var}};
$copyOfVar2{expires} = $var2->get('lastPageView')-1;
$copyOfVar2{userId} = 3;
$session->cache->set($var2->getId, \%copyOfVar2);

my $var3 = WebGUI::Session::Var->new($session, $var2->getId);
is   $var3->getId,         $var2->getId,     'new Var object has correct id';
isnt $var3->isAdminOn,     $var2->isAdminOn, 'new adminOn not equal to old adminOn';
is   $var3->isAdminOn,     0, 'new Var object has default adminOn';
isnt $var3->get('userId'), 3, 'new userId not equal to old userId';
$var2->end;
$var3->end;

##Var objects for noFuss tests
my $var4        = WebGUI::Session::Var->new($session);
my $varExpiring = WebGUI::Session::Var->new($session);
$session->db->write("update userSession set expires=? where sessionId=?",
	[$varExpiring->get('lastPageView')-1, $varExpiring->getId]);
$varExpiring->{_var}{expires} = $varExpiring->get('lastPageView')-1;

sleep 1;

$env->{REMOTE_ADDR} = '127.0.0.1';

##Test a valid fetch
my $varTest = WebGUI::Session::Var->new($session, $var4->getId, 1);

cmp_deeply(
	$varTest,
	methods(
		['get', 'sessionId'] => $var4->getId,
		['get', 'userId']  => 1,
		['get', 'adminOn'] => 0,
		['get', 'lastIP']  => '10.0.5.5',
		['get', 'expires'] => $var4->get('expires'),
		['get', 'lastPageView'] => $var4->get('lastPageView'),
	),
	'fetching a valid session with noFuss does not update the object info'
);

$varTest->end;
$var4->end;

##Test a valid fetch
$varTest = WebGUI::Session::Var->new($session, $varExpiring->getId, 1);

cmp_deeply(
	$varTest,
	methods(
		['get', 'sessionId'] => $varExpiring->getId,
		['get', 'userId']  => 1,
		['get', 'adminOn'] => 0,
		['get', 'lastIP']  => '10.0.5.5',
		['get', 'lastPageView'] => $varExpiring->get('lastPageView'),
		['get', 'expires'] => $varExpiring->get('expires'),
	),
	'fetching a valid session with noFuss does not update the object info, even if it has expired'
);

$varExpiring->end;
$varTest->end;

my $varId4 = 'idDoesNotExist00779988';
#            '1234567890123456789012'
$varTest = WebGUI::Session::Var->new($session, $varId4, 1);
isa_ok($varTest, "WebGUI::Session::Var", "non-existant Id with noFuss returns a valid object...");
is($varTest->getId, $varId4, "...and we got our requested Id");

$varTest->start(3, $varTest->getId);
is($varTest->get('userId'), 3, 'userId set via start');
$varTest->start("", $varTest->getId);
is($varTest->get('userId'), 1, 'calling start with null userId returns default user (visitor)');

END {

	foreach my $varObj ($var, $var2, $var3, $var4, $varExpiring, $varTest) {
		if (defined $varObj and ref $varObj eq 'WebGUI::Session::Var') {
			$varObj->end();
		}
	}
	$session->db->write("delete from userSession where sessionId=?",[$idToDelete]);
}
