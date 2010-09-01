#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::c_companyName;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 2;

my $output = WebGUI::Macro::c_companyName::process($session);
is($output, $session->setting->get('companyName'), "Testing companyName");

$session->setting->set('companyName', q|Gooey's Consulting, LLC|);
$output = WebGUI::Macro::c_companyName::process($session);
is($output, q|Gooey&#39;s Consulting&#44; LLC|, "Testing companyName with embedded quote and comma");
