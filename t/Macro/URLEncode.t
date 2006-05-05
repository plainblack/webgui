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

unless ($session->config->get('macros')->{'URLEncode'}) {
	Macro_Config::insert_macro($session, 'URLEncode', 'URLEncode');
}


my $macroText = '^URLEncode("%s");';
my $output;

my @testSets = (
	{
	input => q! !,
	output => q!%20!,
	comment => q|space|,
	},
	{
	input => q!/!,
	output => q!%2F!,
	comment => q|slash|,
	},
	{
	input => q!abcde!,
	output => q!abcde!,
	comment => q|alpha|,
	},
	{
	input => q!&!,
	output => q!%26!,
	comment => q|ampersand|,
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;


foreach my $testSet (@testSets) {
	$output = sprintf $macroText, $testSet->{input};
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, 'testing '.$testSet->{input});
}
