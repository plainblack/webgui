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
use Test::More tests => 22; # increment this value for each test you create
 
my $session = initialize();  # this line is required
 
# put your tests here
use WebGUI::Session::Stow;
 
my $stow  = WebGUI::Session::Stow->new($session);
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
