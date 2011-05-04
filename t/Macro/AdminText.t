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
use WebGUI::Macro::AdminText;
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

plan tests => 6;

my $output;

$session->user({userId => 1});
$output = WebGUI::Macro::AdminText::process($session, 'admin');
is($output, '', 'user is not admin');

$session->user({userId => 3});
$output = WebGUI::Macro::AdminText::process($session, 'admin');
is($output, '', 'user is admin');

$output = WebGUI::Macro::AdminText::process($session, '');
is($output, '', 'null text');

$output = WebGUI::Macro::AdminText::process($session);
is($output, undef, 'undef text');

