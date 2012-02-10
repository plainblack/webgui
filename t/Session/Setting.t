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

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 10; # increment this value for each test you create
 
my $session = WebGUI::Test->session;

$session->setting->add("inmate","30265");
my ($value) = $session->db->quickArray("select value from settings where name='inmate'");
is($value, '30265', "add()");
is($session->setting->get("inmate"), "30265", "get()");
$session->setting->set("inmate","37927");
my ($value) = $session->db->quickArray("select value from settings where name='inmate'");
is($value, '37927', "set()");
is($session->setting->get("inmate"), '37927', 'set() also updates object cache');
is($session->setting->has('inmate'), 1, 'has checks for existance');
$session->setting->set('inmate', 0);
is($session->setting->get('inmate'), 0, 'get will get 0 values');
is($session->setting->has('inmate'), 1, 'has checks for existance, regardless of value');
$session->setting->remove("inmate"); 
my ($value) = $session->db->quickArray("select value from settings where name='inmate'");
is($value, undef, "delete()");

isa_ok($session->setting->session, 'WebGUI::Session', 'session method returns a session object');
isa_ok($session->setting->get, 'HASH', '->get with no parameters returns a hashref');
