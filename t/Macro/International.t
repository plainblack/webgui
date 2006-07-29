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
use WebGUI::Macro::International;
use WebGUI::Session;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		input => ['macroName', 'Macro_International'],
		output => q!International!,
		comment => q|explicit namespace|,
	},
	{
		input => ['international title', 'Macro_International'],
		output => q!International Macro!,
		comment => q|space in label|,
	},
	{
		input => ['webgui', 'WebGUI'],
		output => q!WebGUI!,
		comment => q|explicit namespace #2|,
	},
	{
		input => ['webgui', ''],
		output => q!WebGUI!,
		comment => q|default namespace|,
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::International::process($session, @{ $testSet->{input} });
	is($output, $testSet->{output}, $testSet->{comment} );
}
