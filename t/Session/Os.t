#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::Session::Os;

my @testSets = (
	{
		os => 'Win',
		type => 'Windowsish',
	},
	{
		os => 'win32',
		type => 'Windowsish',
	},
	{
		os => 'MSWin32',
		type => 'Windowsish',
	},
	{
		os => 'Amiga OS',
		type => 'Linuxish',
	},
);

use Test::More;

my $numTests = 2 * scalar @testSets;

plan tests => $numTests;

my $session = WebGUI::Test->session;

foreach my $test (@testSets) {
	local $^O = $test->{os};
	my $os = WebGUI::Session::Os->new($session);
	is($os->get('name'), $test->{os}, "$test->{os}: name set");
	is($os->get('type'), $test->{type}, "$test->{os}: type set");
}

