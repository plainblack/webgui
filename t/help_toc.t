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
use WebGUI::International;
use Data::Dumper;
use File::Find;
# ---- END DO NOT EDIT ----

#The goal of this test is to make sure that all required labels
#for the help system exist.

use Test::More; # increment this value for each test you create
my $numTests = 0;

initialize();  # this line is required

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList();

$numTests = scalar @helpFileSet;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

diag("Check for mandatory lables for Help table of contents");

foreach my $fileSet (@helpFileSet) {
	my $file = $fileSet->[1];
	ok(WebGUI::Operation::Help::_getHelpName($file), "Missing label for $file");
}

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

