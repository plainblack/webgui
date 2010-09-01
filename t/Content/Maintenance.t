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
use WebGUI::Content::Maintenance;

# load your modules here

use Test::More tests => 3; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

$session->{_request} = undef;

$session->setting->set("specialState", "upgrading");
isnt(WebGUI::Content::Maintenance::handler($session), undef, "Maintenance should return some output when in upgrade special state");
$session->setting->set("specialState", "degrading");
is(WebGUI::Content::Maintenance::handler($session), undef, "Maintenance returns undef if specialState is not 'upgrading'");
$session->setting->remove("specialState");
is(WebGUI::Content::Maintenance::handler($session), undef, "Maintenance shouldn't return anything when no special state is present");

