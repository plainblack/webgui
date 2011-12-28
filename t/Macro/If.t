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
use WebGUI::Macro::If;
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests = 8; # For conditional load and skip

plan tests => $numTests;

my $output;

$output = WebGUI::Macro::If::process($session, '', 'full', 'empty');
is($output, 'empty', 'null string is false');

$output = WebGUI::Macro::If::process($session, undef, 'full', 'empty');
is($output, 'empty', 'undef is false');

$output = WebGUI::Macro::If::process($session, 0, 'full', 'empty');
is($output, 'empty', '0 is false');

$output = WebGUI::Macro::If::process($session, ' ', 'full', 'empty');
is($output, 'empty', 'whitespace is false');

$output = WebGUI::Macro::If::process($session, 1, 'full', 'empty');
is($output, 'full', 'Integer 1 is true');

$output = WebGUI::Macro::If::process($session, 'AABB', 'full', 'empty');
is($output, 'full', 'Some random text is true');

$output = WebGUI::Macro::If::process($session, 5, 'There are %s lights', 'empty');
is($output, 'There are 5 lights', 'true text works with sprintf');

$output = WebGUI::Macro::If::process($session, 0, 'Full', 'There are %s lights');
is($output, 'There are %s lights', '...false text does not');
