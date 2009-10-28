#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Macro::AdminBar;
use HTML::TokeParser;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 2;

my $output;
$output = WebGUI::Macro::AdminBar::process($session);
is($output, undef, 'AdminBar returns undef unless admin is on');
$session->var->switchAdminOn;
$output = WebGUI::Macro::AdminBar::process($session);
ok($output, 'AdminBar returns something when admin is on');

