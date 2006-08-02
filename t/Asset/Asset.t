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
use WebGUI::Session;
use WebGUI::Asset;
use Test::More tests => 1; # increment this value for each test you create

my $session = WebGUI::Test->session;

# Test the default constructor
my $defaultAsset = WebGUI::Asset->getDefault($session);
is(ref $defaultAsset, 'WebGUI::Asset::Wobject::Layout');

