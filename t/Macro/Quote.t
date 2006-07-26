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
use WebGUI::Macro::Quote;
use WebGUI::Session;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		input => q!that's great!,
		output => q!'that\\'s great'!,
	},
	{
		input => q!0!,
		output => q!'0'!,
	},
	{
		input => q!!,
		output => q!''!,
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::Quote::process($session, $testSet->{input});
	is($output, $testSet->{output}, 'testing '.$testSet->{input});
}
