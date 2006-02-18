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
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 22; # increment this value for each test you create

my $session = WebGUI::Test->session;

# commify
is(WebGUI::Utility::commify(10), "10", 'commify() - no comma needed');
is(WebGUI::Utility::commify(1000), "1,000", 'commify() - single comma');
is(WebGUI::Utility::commify(10000000), "10,000,000", 'commify() - multiple commas');

# formatBytes
is(WebGUI::Utility::formatBytes(10), '10 B', 'formatBytes() - bytes');
is(WebGUI::Utility::formatBytes(4300), '4 kB', 'formatBytes() - kilobytes');
is(WebGUI::Utility::formatBytes(1700000), '2 MB', 'formatBytes() - megabytes');

# isBetween 
ok(WebGUI::Utility::isBetween(0,-1,1), 'isBetween() - negative and positive range'); 
ok(WebGUI::Utility::isBetween(0,1,-1), 'isBetween() - negative and positive range, reversed'); 
ok(WebGUI::Utility::isBetween(11,1,15), 'isBetween() - positive range'); 
ok(WebGUI::Utility::isBetween(-5,-10,-2), 'isBetween() - negative range'); 

# isIn
ok(WebGUI::Utility::isIn("webgui", qw(cars trucks webgui trains)), 'isIn()');

# makeArrayCommaSafe
my @commaFilledArray = ("this,that", "foo,bar", "x-y");
WebGUI::Utility::makeArrayCommaSafe(\@commaFilledArray);
my $noCommaFound = 1;
foreach my $row (@commaFilledArray) {
	$noCommaFound = 0 if ($row =~ m/,/);
}
ok($noCommaFound, 'makeArrayCommaSafe()');

# makeCommaSafe
ok(!(WebGUI::Utility::makeCommaSafe("this,that,foo,,bar") =~ m/,/), 'makeCommaSafe()');

# makeTabSafe
ok(!(WebGUI::Utility::makeTabSafe("this\tthat\tfoo\tbar\t") =~ m/\t/), 'makeTabSafe()');

# randint
my $number = WebGUI::Utility::randint(50,75);
ok($number >= 50 && $number <= 75, 'randint()');

# randomizeArray
SKIP: {
	skip("Don't know how to test randomizeArray.",1);
	ok(undef, 'randomizeArray()');
	}

# randomizeHash
SKIP: {
	skip("Don't know how to test randomizeHash.",1);
	ok(undef, 'randomizeHash()');
	}

# round
is(WebGUI::Utility::round(47.133984233, 0), 47, 'round() - 0 significant digits');
is(WebGUI::Utility::round(47.133984233, 3), 47.134, 'round() - multiple significant digits');

# sortHash
SKIP: {
	skip("Don't know how to test sortHash.",1);
	ok(undef, 'sortHash()');
	}

# sortHashDescending
SKIP: {
	skip("Don't know how to test sortHashDescending.",1);
	ok(undef, 'sortHashDescending()');
	}
