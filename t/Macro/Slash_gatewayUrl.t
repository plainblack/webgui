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

my @added_macros = ();
push @added_macros, WebGUI::Macro_Config::enable_macro($session, '/', 'Slash_gatewayUrl');

my $macroText = '^/;';
my $output;

plan tests => 1;

$output = $macroText;

##Note, this is not a test of the gateway method.  That is done over
##in t/Session/Url.t  All we need to do is make sure that the macro
##fetches the same thing as the method.

WebGUI::Macro::process($session, \$output);
is($output, $session->url->gateway, 'fetching site gateway');

END {
	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}
