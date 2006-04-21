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
use WebGUI::Macro_Config;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests = 2;

plan tests => $numTests;


unless ($session->config->get('macros')->{'@'}) {
	Macro_Config::insert_macro($session, '@', 'At_username');
}

my $macroText = "^@;";
my $output;

$output = $macroText;
WebGUI::Macro::process($session, \$output);
is($output, 'Visitor', 'username = Visitor');

$output = $macroText;
$session->user({userId => 3});
WebGUI::Macro::process($session, \$output);
is($output, 'Admin', 'username = Admin');
