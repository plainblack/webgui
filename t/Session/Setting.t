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
use lib '../../lib';
use Getopt::Long;
use WebGUI::Session;
# ---- END DO NOT EDIT ----
use Test::More tests => 4; # increment this value for each test you create
 
my $session = initialize();  # this line is required

$session->setting->add("test","XXX");
my ($value) = $session->db->quickArray("select value from settings where name='test'");
is($value, 'XXX', "add()");
is($session->setting->get("test"), "XXX", "get()");
$session->setting->set("test","YYY");
my ($value) = $session->db->quickArray("select value from settings where name='test'");
is($value, 'YYY', "set()");
$session->setting->remove("test"); 
my ($value) = $session->db->quickArray("select value from settings where name='test'");
is($value, undef, "delete()");
  
cleanup($session); # this line is required
 
# ---- DO NOT EDIT BELOW THIS LINE -----
sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("../..",$configFile);
}
sub cleanup {
        my $session = shift;
        $session->close();
}
