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
use WebGUI::AdSpace;

#use Test::More tests => 3;
use Test::More;

my $numTests = 1; # increment this value for each test you create
++$numTests; ##For conditional testing on module load

plan tests => $numTests;

my $loaded = use_ok('WebGUI::AdSpace::Ad');

my $session = WebGUI::Test->session;
my $ad;
my $adSpace;

SKIP: {

    skip "Unable to load WebGUI::AdSpace::Ad", $numTests-1 unless $loaded;
    $adSpace = WebGUI::AdSpace->create($session, {name=>"Alfred"});
    $ad=WebGUI::AdSpace::Ad->create($session, $adSpace->getId, {"type" => "text"});
    isa_ok($ad,"WebGUI::AdSpace::Ad","testing create with no properties");
}

END {
	if (defined $ad and ref $ad eq 'WebGUI::AdSpace::Ad') {
		$ad->delete;
	}
	if (defined $adSpace and ref $adSpace eq 'WebGUI::AdSpace') {
		$adSpace->delete;
	}
}
