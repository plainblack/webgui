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

my $numTests = 5;
$numTests += 1; #For the use_ok

plan tests => $numTests;

my $preventProxyCache = $session->setting->get('preventProxyCache');

my $macro = 'WebGUI::Macro::PageUrl';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

$session->setting->set('preventProxyCache', 0) if ($preventProxyCache);

my $homeAsset = WebGUI::Asset->getDefault($session);

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

my $output;

$output = WebGUI::Macro::PageUrl::process($session);
is($output, $session->url->gateway.$homeAsset->get('url'), 'fetching url for site default asset');

$output = WebGUI::Macro::PageUrl::process($session, '/sub/page');
is($output, $session->url->gateway.$homeAsset->get('url').'/sub/page', 'fetching url for site default asset with sub url');

$session->setting->set('preventProxyCache', 1);

$output = WebGUI::Macro::PageUrl::process($session);
like($output, qr{\?noCache=\d+:\d+$}, 'checking the cache settings in the page URL');

$output = WebGUI::Macro::PageUrl::process($session, '/sub/page');
like($output, qr{/sub/page\?noCache=\d+:\d+$}, 'checking the cache settings in the URL are at the end of the page URL');

}

TODO: {
	local $TODO = "Tests to make later";
	ok(0, 'Fetch url from locally made asset with known url');
}

END {
	# See note in the Slash_gateway macro test about this.
	$session->setting->set("preventProxyCache", $preventProxyCache);
}
