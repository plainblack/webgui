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

my @getRefererUrlTests = (
	{
		input => undef,
		output => undef,
		comment => 'getRerererUrl returns undef unless there is a referrer',
	},
	{
		input => 'http://www.domain.com/myUrl.html',
		output => 'myUrl.html',
		comment => 'getRefererUrl returns the url minus the gateway',
	},
	{
		input => 'http://www.domain.com/myUrl.html?op=switchAdminOn',
		output => 'myUrl.html',
		comment => 'getRefererUrl returns the url minus the gateway',
	},
	{
		input => 'https://www.site.com/myUrl.html',
		output => 'myUrl.html',
		comment => 'getRefererUrl handles SSL urls',
	},
	{
		input => 'itunes://www.site.com/myUrl.html',
		output => undef,
		comment => 'getRefererUrl only handles HTTP protocols',
	},
	{
		input => 'http://site/myUrl.html',
		output => 'myUrl.html',
		comment => 'getRefererUrl will also parse weird URLs',
	},
);

use Test::More;
use Test::MockObject::Extends;
use Test::MockObject;
plan tests => 31 + scalar(@getRefererUrlTests);

my $session = WebGUI::Test->session;

#Enable caching
my $preventProxyCache = $session->setting->get('preventProxyCache');

$session->setting->set('preventProxyCache', 0) if ($preventProxyCache);

my $url = 'http://localhost.localdomain/foo';
my $url2;

$url2 = $session->url->append($url,'a=b');
is( $url2, $url.'?a=b', 'append first pair');

$url2 = $session->url->append($url2,'c=d');
is( $url2, $url.'?a=b;c=d', 'append second pair');

$session->config->{_config}->{'gateway'} = '/';

is ( $session->config->get('gateway'), '/', 'Set gateway for downstream tests');

$url2 = $session->url->gateway;
is ( $url2, '/', 'gateway method, no args');

$url2 = $session->url->gateway('/home');
is ( $url2, '/home', 'gateway method, pageUrl with leading slash');

$url2 = $session->url->gateway('home');
is ( $url2, '/home', 'gateway method, pageUrl without leading slash');

#Disable caching
$session->setting->set(preventProxyCache => 1);

is ( 1, $session->setting->get('preventProxyCache'), 'disable proxy caching');

$url2 = $session->url->gateway('home');
like ( $url2, qr{/home\?noCache=\d+,\d+$}, 'check proxy prevention setting');

#Enable caching
$session->setting->set(preventProxyCache => 0);

$url = '/home';
$url2 = $session->url->gateway($url,'a=b');
is( $url2, '/home?a=b', 'append one pair via gateway');

#Restore original proxy cache setting so downstream tests work with no surprises
$session->setting->set(preventProxyCache => $preventProxyCache );


#######################################
#
# setSiteUrl and getSiteUrl
#
#######################################

##Memorize the current setting and set up the default setting to start tests.
my $setting_hostToUse = $session->setting->get('hostToUse');
$session->setting->set('hostToUse', 'HTTP_HOST');
my $sitename = $session->config->get('sitename')->[0];
is ( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL from config as http_host');
my $config_port;
if ($session->config->get('webServerPort')) {
	$config_port = $session->config->get('webServerPort');
}

$session->url->setSiteURL('http://webgui.org');
is ( $session->url->getSiteURL, 'http://webgui.org', 'override config setting with setSiteURL');

##Create a fake environment hash so we can muck with it.
our %mockEnv = %ENV;
$session->{_env}->{_env} = \%mockEnv;

$mockEnv{HTTPS} = "on";
$session->url->setSiteURL(undef);
is ( $session->url->getSiteURL, 'https://'.$sitename, 'getSiteURL from config as http_host with SSL');

$mockEnv{HTTPS} = "";
$mockEnv{HTTP_HOST} = "devsite.com";
$session->url->setSiteURL(undef);
is ( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL where requested host is not a configured site');

my @config_sitename = @{ $session->config->get('sitename') };
$session->config->addToArray('sitename', 'devsite.com');
$session->url->setSiteURL(undef);
is ( $session->url->getSiteURL, 'http://devsite.com', 'getSiteURL where requested host is not the first configured site');

$session->setting->set('hostToUse', 'sitename');
$session->url->setSiteURL(undef);
is ( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL where illegal host has been requested');

$session->config->set('webServerPort', 80);
$session->url->setSiteURL(undef);
is ( $session->url->getSiteURL, 'http://'.$sitename.':80', 'getSiteURL with a port');

$session->config->set('webServerPort', 8880);
$session->url->setSiteURL(undef);
is ( $session->url->getSiteURL, 'http://'.$sitename.':8880', 'getSiteURL with a non-standard port');

$session->url->setSiteURL('http://'.$sitename);
is ( $session->url->getSiteURL, 'http://'.$sitename, 'restore config setting');
$session->config->set('sitename', \@config_sitename);
$session->setting->set('hostToUse', $setting_hostToUse);
if ($config_port) {
	$session->config->set('webServerPort', $config_port);
}
else {
	$session->config->delete('webServerPort');
}

$url  = 'level1 /level2/level3   ';
$url2 = 'level1-/level2/level3';

is ( $session->url->makeCompliant($url), $url2, 'language specific URL compliance');

my $originalRequest = $session->request;  ##Save the original request

is ($session->url->getRequestedUrl, undef, 'getRequestedUrl returns undef unless it has a request object');

my $newRequest = Test::MockObject->new;
my $requestedUrl = 'empty';
$newRequest->set_bound('uri', \$requestedUrl);
$session->{_request} = $newRequest;

##Validate new MockObject

is ($session->request->uri, 'empty', 'Validate Mock Object operation');

$requestedUrl = 'full';
is ($session->request->uri, 'full', 'Validate Mock Object operation #2');

$requestedUrl = '/path1/file1';
is ($session->url->getRequestedUrl, 'path1/file1', 'getRequestedUrl, fetch');

$requestedUrl = '/path2/file2';
is ($session->url->getRequestedUrl, 'path1/file1', 'getRequestedUrl, check cache of previous result');

$session->url->{_requestedUrl} = undef;  ##Manually clear cached value
$requestedUrl = '/path2/file2?param1=one;param2=two';
is ($session->url->getRequestedUrl, 'path2/file2', 'getRequestedUrl, does not return params');

$session->url->{_requestedUrl} = undef;  ##Manually clear cached value
$requestedUrl = '/path1/file1';
is ($session->url->page, '/path1/file1', 'page with no args returns getRequestedUrl through gateway');

$url2 = 'http://'.$session->config->get('sitename')->[0].'/path1/file1';
is ($session->url->page('',1), $url2, 'page, withFullUrl includes method and sitename');


#######################################
#
# getReferrerUrl
#
#######################################

$mockEnv{'HTTP_REFERER'} = 'test';

is($session->env->get('HTTP_REFERER'), 'test', 'testing MockObject');

foreach my $test (@getRefererUrlTests) {
	$mockEnv{HTTP_REFERER} = $test->{input};
	is($session->url->getRefererUrl, $test->{output}, $test->{comment});
}

#######################################
#
# makeAbsolute
#
#######################################

TODO: {
	local $TODO = "makeAbsolute TODO's";
	ok(0, 'go back and refigure out how the page method works to test makeAbsoluate with default params');
}

is($session->url->makeAbsolute('page1', '/layer1/layer2/'), '/layer1/layer2/page1', 'use a different root');
is($session->url->makeAbsolute('page1', '/layer1/page2'), '/layer1/page1', 'use a second root that is one level shallower');

END {
	$session->config->set('sitename', \@config_sitename);
	$session->setting->set('hostToUse', $setting_hostToUse);
	if ($config_port) {
		$session->config->set($config_port);
	}
	else {
		$session->config->delete('webServerPort');
	}
}
