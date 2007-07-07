#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 2+1;

plan tests => $numTests;

my $macro = 'WebGUI::Macro::c_companyName';
my $loaded = use_ok($macro);

my $originalCompanyName = $session->setting->get('companyName');

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

my $output = WebGUI::Macro::c_companyName::process($session);
is($output, $originalCompanyName, "Testing companyName");

$session->setting->set('companyName', q|Gooey's Consulting, LLC|);
$output = WebGUI::Macro::c_companyName::process($session);
is($output, q|Gooey&quot;s Consulting&#44; LLC|, "Testing companyName with embedded quote and comma");

}

END {
	$session->setting->set('companyName', $originalCompanyName);
}
