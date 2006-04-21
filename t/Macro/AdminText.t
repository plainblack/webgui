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

my $numTests = 4;

plan tests => $numTests;


unless ($session->config->get('macros')->{'AdminText'}) {
	Macro_Config::insert_macro($session, 'AdminText', 'AdminText');
}

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
