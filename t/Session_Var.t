#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------
 
# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Session;
# ---- END DO NOT EDIT ----
use Test::More tests => 6; # increment this value for each test you create
 
my $session = initialize();  # this line is required
 
# put your tests here
use WebGUI::Session::Var;
 
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

 
cleanup($session); # this line is required
 
# ---- DO NOT EDIT BELOW THIS LINE -----
sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("..",$configFile);
}
sub cleanup {
        my $session = shift;
        $session->close();
}
