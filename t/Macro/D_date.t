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
use WebGUI::Session;
use Data::Dumper;
# ---- END DO NOT EDIT ----

use Test::More; # increment this value for each test you create

my $wgbday = 997966800;

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

my $numTests = scalar @testSets + 1 + 1;

plan tests => $numTests;

my $macro = 'WebGUI::Macro::D_date';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

my $session = WebGUI::Test->session;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::D_date::process($session, $testSet->{format}, $wgbday);
	is($output, $testSet->{output}, 'testing '.$testSet->{format});
}

##How do you make sure that two sequential statements in perl are executed in the
##same integer second "window"?  You bracket the statement in question between
##time statements and check the outside statements.  If they match in time, then the
##statement is in the same window.

my ($time1, $time2) = (0,1);
my $output;
while ($time1 != $time2) {
	$time1 = time();
	$output = WebGUI::Macro::D_date::process($session);
	$time2 = time();
}

is($output, $session->datetime->epochToHuman($time1), 'checking default time and format');

}
