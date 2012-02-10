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
use WebGUI::Macro::u_companyUrl;
use WebGUI::Session;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 1;

my ($value) = $session->dbSlave->quickArray(
	"select value from settings where name='companyUrl'");
my $output = WebGUI::Macro::u_companyUrl::process($session);
is($output, $value, sprintf "Testing companyUrl");
