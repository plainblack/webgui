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
use HTML::TokeParser;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 2;

$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::AdminBar';
my $loaded = use_ok($macro);

my $originalAssets = $session->config->get('assets');

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

my $output;
$output = WebGUI::Macro::AdminBar::process($session);
is($output, undef, 'AdminBar returns undef unless admin is on');
$session->var->switchAdminOn;
$output = WebGUI::Macro::AdminBar::process($session);
ok($output, 'AdminBar returns something when admin is on');


}

END: {
    $session->config->set('assets', $originalAssets);
}
