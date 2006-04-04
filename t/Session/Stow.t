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

use Test::More tests => 26; # increment this value for each test you create
 
my $session = WebGUI::Test->session;
 
# put your tests here
 
my $stow  = $session->stow;
my $count = 0;
my $maxCount = 20;

for (my $count = 1; $count <= $maxCount; $count++){
   $stow->set("Test$count",$count);
}
 
for (my $count = 1; $count <= $maxCount; $count++){
   is($stow->get("Test$count"), $count, "Passed set/get $count");
}

$stow->delete("Test1");
is($stow->get("Test1"), undef, "delete()");
$stow->deleteAll;
is($stow->get("Test2"), undef, "deleteAll()");

my @list = qw/alpha delta tango charlie omicron zero/;
my @orig_list = qw/alpha delta tango charlie omicron zero/;

my $mil1 = [ @list ];

$stow->set("military", $mil1);

is_deeply($stow->get("military"), $mil1, 'fetched a copy of an array ref from stow');

undef $mil1;
is_deeply($stow->get("military"), [ @list ], 'removing original reference does not affect stow');

push @list, qw/beta gamma/;

is_deeply($stow->get("military"), [ @orig_list ], "modifying original list does not affect stow'ed list");

my $milList = $stow->get("military");

push @{ $milList }, qw/foxtrot echo/;

is_deeply($stow->get("military"), [ @orig_list, qw/foxtrot echo/ ], "modifying fetched list changes stow'ed list because it is a reference");
