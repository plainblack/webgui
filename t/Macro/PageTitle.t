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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'PageTitle'}) {
	Macro_Config::insert_macro($session, 'PageTitle', 'PageTitle');
}


my $macroText = '^PageTitle;';
my $output;

plan tests => 2;

$output = $macroText;

my $homeAsset = WebGUI::Asset->getDefault($session);

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

WebGUI::Macro::process($session, \$output);
is($output, $homeAsset->get('title'), 'fetching title for site default asset');

TODO: {
	local $TODO = "Tests to make later";
	ok(0, 'Fetch title from locally made asset with known title');
}
