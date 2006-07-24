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
use WebGUI::Group;
use WebGUI::User;
use WebGUI::Macro_Config;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create
use List::Util qw/max min/;
use Data::Dumper;

##Note, testing statistical functions is kind of weird.  All we really
##need to do is make sure that the macro functions as advertised.

plan tests => 4;

unless ($session->config->get('macros')->{'Splat_random'}) {
	Macro_Config::insert_macro($session, '*', 'Splat_random');
}

my $macroText = q!^*(%s);!;
my $output;
my $inBounds = 1;
BOUNDED: for (my $i=0; $i<=99; $i++) {
	my $output = sprintf $macroText, 10;
	WebGUI::Macro::process($session, \$output);
	if (($output > 10) or ($output < 0)) {
		$inBounds = 0;
		last BOUNDED;
	}
}

ok($inBounds, "100 fetches were in bounds");

$output = '^*;';
WebGUI::Macro::process($session, \$output);
ok($output >= 0 and $output < 1_000_000_000, "Empty argument returns a number");

my $wholeNumber = 1;
WHOLE: for (my $i=0; $i<=99; $i++) {
	my $output = sprintf $macroText, 1;
	WebGUI::Macro::process($session, \$output);
	if (int($output) != $output) {
		$wholeNumber = 0;
		last WHOLE;
	}
}

ok($wholeNumber, "100 fetches were all whole numbers");

my @bins = ();
WHOLE: for (my $i=0; $i<=999; $i++) {
	my $output = sprintf $macroText, 4;
	WebGUI::Macro::process($session, \$output);
	++$bins[$output];
}

is(scalar(@bins), 4, "All bins have values on a sample size of 1000");

#diag Dumper \@bins;
