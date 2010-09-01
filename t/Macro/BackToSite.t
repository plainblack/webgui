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
use WebGUI::Macro::BackToSite;
use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 1;

my $output = WebGUI::Macro::BackToSite::process($session);
is($output, $session->url->getBackToSiteURL, 'fetching current url');
