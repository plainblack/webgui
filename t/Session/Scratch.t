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

use Test::More tests => 14; # increment this value for each test you create
 
my $session = WebGUI::Test->session;

my $scratch = $session->scratch;
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
