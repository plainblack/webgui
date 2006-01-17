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

use Test::More tests => 22; # increment this value for each test you create
 
my $session = WebGUI::Test->session;
 
# put your tests here
 
my $stow  = $session->stow;
my $count = 0;
my $maxCount = 20;

for (my $count = 1; $count <= $maxCount; $count++){
   $stow->set("Test$count",$count);
}
 
for (my $count = 1; $count <= $maxCount; $count++){
   is($stow->get("Test$count"), $count, "Passed set/get $count\n");
}

$stow->delete("Test1");
is($stow->get("Test1"), undef, "delete()");
$stow->deleteAll;
is($stow->get("Test2"), undef, "deleteAll()");
