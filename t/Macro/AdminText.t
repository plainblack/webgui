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

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests = 4;

plan tests => $numTests;

diag("Planning on running $numTests tests\n");

my $adminText = "^AdminText(admin);";
my $output;

$output = $adminText;
WebGUI::Macro::process($session, \$output);
is($output, '', 'user is not admin');

$session->user({userId => 3});
$output = $adminText;
WebGUI::Macro::process($session, \$output);
is($output, '', 'user is admin, not in admin mode');

$session->var->switchAdminOn;
$output = $adminText;
WebGUI::Macro::process($session, \$output);
is($output, 'admin', 'admin in admin mode');

$session->var->switchAdminOff;
$output = $adminText;
WebGUI::Macro::process($session, \$output);
is($output, '', 'user is admin, not in admin mode');

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

