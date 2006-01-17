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
 
 
ok($session->var->getId ne "", "getId()");
ok($session->var->get("lastPageView") > 0, "get()");
is($session->var->isAdminOn, 0, "isAdminOn()");
$session->var->switchAdminOn;
is($session->var->isAdminOn, 1, "switchAdminOn()");
$session->var->switchAdminOff;
is($session->var->isAdminOn, 0, "switchAdminOff()");
my $id = $session->var->getId;
$session->var->end;
my ($count) = $session->db->quickArray("select count(*) from userSession where sessionId=".$session->db->quote($id));
ok($count == 0,"end()");
