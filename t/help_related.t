#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Operation::Help;
use File::Find;
# ---- END DO NOT EDIT ----

#The goal of this test is to verify that all entries in the lib/WebGUI/Help
#directory correctly resolve to other Help entries.  The total number of
#tests will be dynamic, based on how many "related" entries are set up
#in the Help files.  Calling Test::plan will be delayed.

use Test::More;
my $numTests = 0;

initialize();  # this line is required

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList();

my %helpTable;

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($helpName);
	$helpTable{ $helpName } = $help;
}

##Scan #1, how many tests do we expect?

my @relatedHelp = ();
foreach my $topic ( keys %helpTable ) {
	foreach my $entry ( keys %{ $helpTable{$topic} }) {
		my @related = @{ $helpTable{$topic}{$entry}{related} };
		push @relatedHelp, @related;
		$numTests += scalar @related;
	}
}

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

##Each array element is a hash with two keys, tag (entry) and namespace (topic).

foreach my $related (@relatedHelp) {
	my ($topic, $entry) = @{ $related }{'namespace', 'tag'};
	ok( exists $helpTable{$topic}{$entry}, "Help entry: $topic -> $entry");
}

# put your tests here

cleanup(); # this line is required


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	WebGUI::Session::open("..",$configFile);
}

sub cleanup {
	WebGUI::Session::close();
}

