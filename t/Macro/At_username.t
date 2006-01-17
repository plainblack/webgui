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
# ---- END DO NOT EDIT ----

my $session = initialize();  # this line is required

use Test::More; # increment this value for each test you create

my $numTests = 2;

plan tests => $numTests;

diag("Planning on running $numTests tests\n");

my $macroText = "^@;";
my $output;

$output = $macroText;
WebGUI::Macro::process($session, \$output);
is($output, 'Visitor', 'username = Visitor');

$output = $macroText;
$session->user({userId => 3});
WebGUI::Macro::process($session, \$output);
is($output, 'Admin', 'username = Admin');

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

