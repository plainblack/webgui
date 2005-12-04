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
use WebGUI::Macro;
# ---- END DO NOT EDIT ----

#This test is to verify bugs with respect to Macros:
# - [ 1364838 ] ^GroupText Macro cannot execute other macros

use Test::More; # increment this value for each test you create

my $numTests = 3;

initialize();  # this line is required

plan tests => $numTests;

diag("Planning on running $numTests tests\n");

my $macroText = "^GroupText(3,local,foreigner);";
my $output;

$output = $macroText;
WebGUI::Macro::process(\$output);
is($output, 'foreigner', 'GroupText, user not in group');

$output = $macroText;
WebGUI::Session::refreshUserInfo(3);
WebGUI::Macro::process(\$output);
is($output, 'local', 'GroupText, user in group');

$macroText = "^GroupText(3,^AssetProxy(getting_started);,foreigner)";
$output = $macroText;
WebGUI::Macro::process(\$output);

like($output, qr/If you're reading this/, 'GroupText, nesting, in group');

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

