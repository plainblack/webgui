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
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests = 2 + 1; # For conditional load and skip

plan tests => $numTests;

my $macro = 'WebGUI::Macro::At_username';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

my $output;

$session->user({userId => 1});
$output = WebGUI::Macro::At_username::process($session);
is($output, 'Visitor', 'username = Visitor');

$session->user({userId => 3});
$output = WebGUI::Macro::At_username::process($session);
is($output, 'Admin', 'username = Admin');

}
