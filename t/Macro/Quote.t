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
use strict;
use lib '../../lib';
use Getopt::Long;
use WebGUI::Macro;
use WebGUI::Session;
use Data::Dumper;
use Macro_Config;
# ---- END DO NOT EDIT ----

my $session = initialize();  # this line is required

use Test::More; # increment this value for each test you create

unless ($session->config->get('macros')->{'Quote'}) {
	diag("Inserting macro into config");
	Macro_Config::insert_macro($session, 'Quote', 'Quote');
}


my $macroText = '^Quote("%s");';
my $output;

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

diag("Planning on running $numTests tests\n");

foreach my $testSet (@testSets) {
	$output = sprintf $macroText, $testSet->{input};
	diag("current test: $output");
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, 'testing '.$testSet->{input});
}

cleanup($session); # this line is required

# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("../..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

