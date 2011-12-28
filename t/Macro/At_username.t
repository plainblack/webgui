#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Macro::At_username;
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests = 2; # For conditional load and skip

plan tests => $numTests;

my $output;

$session->user({userId => 1});
$output = WebGUI::Macro::At_username::process($session);
is($output, 'Visitor', 'username = Visitor');

$session->user({userId => 3});
$output = WebGUI::Macro::At_username::process($session);
is($output, 'Admin', 'username = Admin');

