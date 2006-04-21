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
use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use Data::Dumper;
# ---- END DO NOT EDIT ----

use Test::More; # increment this value for each test you create

my $macroText = '^D("%s",%s);';
my $wgbday = 997966800;
my $output;

my @testSets = (
	{
	format => '%%%c%d%h',
	output =>'%August1608',
	},
	{
	format => '',
	output =>'8/16/2001  8:00 am',
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;


my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'D'}) {
	Macro_Config::insert_macro($session, 'D', 'Date');
}

foreach my $testSet (@testSets) {
	$output = sprintf $macroText, $testSet->{format}, $wgbday;
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, 'testing '.$testSet->{format});
}
