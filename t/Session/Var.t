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

use Test::More tests => 19; # increment this value for each test you create
 
my $session = WebGUI::Test->session;
 
ok($session->var->getId ne "", "getId()");
cmp_ok($session->var->get("lastPageView"), '>', 0, "get(lastPageView)");
is($session->var->isAdminOn, 0, "isAdminOn()");
$session->var->switchAdminOn;
is($session->var->isAdminOn, 1, "switchAdminOn()");
$session->var->switchAdminOff;
is($session->var->isAdminOn, 0, "switchAdminOff()");
my $id = $session->var->getId;
$session->var->end;
my ($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$id]);
ok($count == 0,"end()");

my $varTime = time();
my $varExpires = $varTime + $session->setting->get('sessionTimeout');
my $var = WebGUI::Session::Var->new($session);
isa_ok($var, 'WebGUI::Session::Var', 'new returns Var object');
is($var->get('userId'), 1, 'default userId is 1');
is($var->get('sessionId'), $var->getId, "get('sessionId') and getId return the same thing");
isnt($var->getId, $session->var->getId, 'a new, unique sessionId was created');
is($var->get('adminOn'), $var->isAdminOn, "get('adminOn') and isAdminOn return the same thing");
is($var->get('adminOn'), 0, "adminOn is off by default"); ##retest
cmp_ok(abs($var->get('lastPageView') - $varTime), '<=', 1, 'lastPageView set correctly');
cmp_ok(abs($var->get('expires') - $varExpires), '<=', 1, 'expires set correctly');

TODO: {
	local $TODO = "Stuff to write later";
	ok(0, 'check fetching a particular sessionId');
	ok(0, 'check fetching a non-existant sessionId');
	ok(0, 'check setting a particular userId');
	ok(0, 'check setting a non-existant userId');
	ok(0, 'check that lastIp was set correctly');
}
