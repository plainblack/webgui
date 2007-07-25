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

use Test::More tests => 6; # increment this value for each test you create
 
my $session = WebGUI::Test->session;

$session->setting->add("test","XXX");
my ($value) = $session->db->quickArray("select value from settings where name='test'");
is($value, 'XXX', "add()");
is($session->setting->get("test"), "XXX", "get()");
$session->setting->set("test","YYY");
my ($value) = $session->db->quickArray("select value from settings where name='test'");
is($value, 'YYY', "set()");
is($session->setting->get("test"), 'YYY', 'set() also updates object cache');
$session->setting->remove("test"); 
my ($value) = $session->db->quickArray("select value from settings where name='test'");
is($value, undef, "delete()");

isa_ok($session->setting->session, 'WebGUI::Session', 'session method returns a session object');
