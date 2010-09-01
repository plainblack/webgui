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
use WebGUI::HTML;
use WebGUI::Session;

use Test::More;
use Test::Deep;
use Data::Dumper;

my $session = WebGUI::Test->session;

plan tests => 3;

is WebGUI::HTML::arrayToRow(1),
   '<tr><td>1</td></tr>',
   'addToRow: 1 element';

is WebGUI::HTML::arrayToRow(1,2),
   '<tr><td>1</td><td>2</td></tr>',
   '... 2 elements';

is WebGUI::HTML::arrayToRow(),
   '<tr><td></td></tr>',
   '... 0 elements';
