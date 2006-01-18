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
use Test::More tests => 10; # increment this value for each test you create
 
my $session = initialize();  # this line is required
 
# put your tests here

my $scratch = $session->Scratch;
my $maxCount = 10;

$scratch->deleteAll();


for (my $count = 1; $count <= $maxCount; $count++){
   $scratch->set("Test$count",$count);
}


for (my $count = 1; $count <= $maxCount; $count++){
   is($scratch->get("Test$count"), $count, "Passed set/get $count\n");
}


$scratch->delete("Test1");
is($scratch->get("Test1"), undef, "delete()");

$scratch->deleteName("Test10");
is($scratch->get("Test10"), undef, "deleteName()");

$scratch->deleteAll;
is($scratch->get("Test2"), undef, "deleteAll()");


my $testScratchSession = $scratch->session();

is($testScratchSession, $session, "session()");


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
