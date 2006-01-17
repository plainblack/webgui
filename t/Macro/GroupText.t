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
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests = 2;

plan tests => $numTests;

diag("Planning on running $numTests tests\n");

my $macroText = "^GroupText(3,local,foreigner);";
my $output;

$output = $macroText;
WebGUI::Macro::process($session, \$output);
is($output, 'foreigner', 'GroupText, user not in group');

$output = $macroText;
$session->user({userId => 3});
WebGUI::Macro::process($session, \$output);
is($output, 'local', 'GroupText, user in group');
