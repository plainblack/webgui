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
use WebGUI::Operation::Help;
# ---- END DO NOT EDIT ----

#The goal of this test is to verify that all entries in the lib/WebGUI/Help
#directory compile.  This test is necessary because WebGUI::Operation::Help
#will return an empty hash if it won't compile, and the help will simply
#disappear.

use Test::More;
my $numTests = 0;

my $session = initialize();  # this line is required

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList($session);

$numTests = scalar @helpFileSet; #One for each help compile

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($session, $helpName);
	ok(keys %{ $help }, "$helpName compiled");
}

# put your tests here

cleanup($session); # this line is required


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        return WebGUI::Session->open("..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

