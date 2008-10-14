#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Content::Setup;

# load your modules here

use Test::More tests => 2; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

$session->setting->set("specialState", "init");
isnt(WebGUI::Content::Setup::handler($session), undef, "Setup should return some output when in init special state");
$session->setting->remove("specialState");
is(WebGUI::Content::Setup::handler($session), undef, "Setup shouldn't return anything when no special state is present");

