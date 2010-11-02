#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::D_date;
use Data::Dumper;

use Test::More;
use Test::Exception;

my $wgbday = WebGUI::Test->webguiBirthday;

my @testSets = (
	{
		format => '%%%c%d%h',
		output =>'%August1608',
	},
	{
		format => '',
		output =>'8/16/2001 8:00 am',
	},
);

my $numTests = scalar @testSets + 4;

plan tests => $numTests;

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

##Checking for edge case, time=0
is WebGUI::Macro::D_date::process($session, '', 0),
    '12/31/1969 6:00 pm',
    '...checking for handling time=0';

lives_ok { WebGUI::Macro::D_date::process($session, '', '   0') }
    'handles leading whitespace okay';
lives_ok { WebGUI::Macro::D_date::process($session, '', '0    ') }
    'handles trailing whitespace okay';
