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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @added_macros = ();
push @added_macros, WebGUI::Macro_Config::enable_macro($session, 'International', 'International');

my $macroText = '^International("%s","%s");';
my $output;

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
	$output = sprintf $macroText, @{ $testSet->{input} };
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, $testSet->{comment} );
}

END {
	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}
