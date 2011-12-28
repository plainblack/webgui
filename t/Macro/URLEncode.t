#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Macro::URLEncode;
use WebGUI::Session;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

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
	{
		input => q!this, that and the other!,
		output => q!this%2C%20that%20and%20the%20other!,
		comment => q|inline comma|,
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::URLEncode::process($session, $testSet->{input});
	is($output, $testSet->{output}, 'testing '.$testSet->{input});
}
