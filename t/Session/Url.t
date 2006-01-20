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

use Test::More tests => 15; # increment this value for each test you create

my $session = WebGUI::Test->session;

#Enable caching
my $preventProxyCache = $session->setting->get('preventProxyCache');

$session->setting->set('preventProxyCache', 0) if ($preventProxyCache);

my $url = 'http://localhost.localdomain/foo';
my $url2;

diag("append tests");

$url2 = $session->url->append($url,'a=b');
is( $url2, $url.'?a=b', 'append first pair');

$url2 = $session->url->append($url2,'c=d');
is( $url2, $url.'?a=b;c=d', 'append second pair');

diag("gateway tests");

$session->config->{_config}->set(gateway => 'home.com');

is ( $session->config->get('gateway'), 'home.com', 'Set gateway for downstream tests');

$url = $session->config->get('gateway') . '/';
$url2 = $session->url->gateway;
is ( $url2, $url, 'gateway method, no args');

$url = $session->config->get('gateway') . '/';
$url2 = $session->url->gateway;
is ( $url2, $url, 'gateway method, no args');

$url2 = $session->url->gateway('/home');
$url = $session->config->get('gateway') . '/home';
is ( $url2, $url, 'gateway method, pageUrl with leading slash');

$url2 = $session->url->gateway('home');
is ( $url2, $url, 'gateway method, pageUrl without leading slash');

#Disable caching
$session->setting->set(preventProxyCache => 1);

is ( 1, $session->setting->get('preventProxyCache'), 'disable proxy caching');

$url2 = $session->url->gateway('home');
like ( $url2, qr/$url\?noCache=\d+;\d+$/, 'check proxy prevention setting');

#Enable caching
$session->setting->set(preventProxyCache => 0);

$url = '/home';
$url2 = $session->url->gateway($url,'a=b');
is( $url2, $session->config->get('gateway').$url.'?a=b', 'append one pair via gateway');

#Restore original proxy cache setting so downstream tests work with no surprises
$session->setting->set(preventProxyCache => $preventProxyCache );

diag("site URL tests");

my $sitename = $session->config->get('sitename')->[0];
is ( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL from config');

$session->url->setSiteURL('http://webgui.org');
is ( $session->url->getSiteURL, 'http://webgui.org', 'override config setting with setSiteURL');

$session->url->setSiteURL('http://'.$sitename);
is ( $session->url->getSiteURL, 'http://'.$sitename, 'restore config setting');

diag("compliancy tests");

$url  = 'level1 /level2/level3   ';
$url2 = 'level1-/level2/level3';

is ( $session->url->makeCompliant($url), $url2, 'language specific URL compliance');

SKIP: {
	skip("getRequestedUrl requires a valid Apache request object",1);
	ok(undef,"getRequestedUrl");
}

