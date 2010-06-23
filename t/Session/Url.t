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
use WebGUI::PseudoRequest;
use WebGUI::Session;
use WebGUI::Asset;

my @getRefererUrlTests = (
	{
		input => undef,
		output => undef,
		comment => 'getRefererUrl returns undef unless there is a referrer',
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
plan tests => 81 + scalar(@getRefererUrlTests);

my $session = WebGUI::Test->session;

my $pseudoRequest = WebGUI::PseudoRequest->new();
$session->{_request} = $pseudoRequest;

#disable caching
my $preventProxyCache = $session->setting->get('preventProxyCache');

$session->setting->set('preventProxyCache', 0);

#######################################
#
# append
#
#######################################

my $url = 'http://localhost.localdomain/foo';
my $url2;

$url2 = $session->url->append($url,'a=b');
is( $url2, $url.'?a=b', 'append first pair');

$url2 = $session->url->append($url2,'c=d');
is( $url2, $url.'?a=b;c=d', 'append second pair');

#######################################
#
# gateway
#
#######################################

my $gateway = $session->config->get('gateway');
$session->config->set('gateway', '/');

is( $session->config->get('gateway'), '/', 'Set gateway for downstream tests');

$url2 = $session->url->gateway;
is( $url2, '/', 'gateway: args');

$url2 = $session->url->gateway('/home');
is( $url2, '/home', 'gateway: with leading slash');

$url2 = $session->url->gateway('home');
is( $url2, '/home', 'gateway: without leading slash');

#Disable caching
$session->setting->set(preventProxyCache => 1);

is( 1, $session->setting->get('preventProxyCache'), 'gateway: disable proxy caching');

$url2 = $session->url->gateway('home');
like( $url2, qr{/home\?noCache=\d+:\d+$}, 'gateway: check proxy prevention setting');

$url2 = $session->url->gateway('home','',1);
is( $url2, '/home', 'gateway: skipPreventProxyCache');

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
is( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL from config as http_host');
my $config_port;
if ($session->config->get('webServerPort')) {
	$config_port = $session->config->get('webServerPort');
}

$session->url->setSiteURL('http://webgui.org');
is( $session->url->getSiteURL, 'http://webgui.org', 'override config setting with setSiteURL');

##Create a fake environment hash so we can muck with it.
my %mockEnv = %ENV;
my $env = $session->env;
$env = Test::MockObject::Extends->new($env);
$env->mock('get', sub { return $mockEnv{$_[1]} } );

$mockEnv{HTTPS} = "on";
$session->url->setSiteURL(undef);
is( $session->url->getSiteURL, 'https://'.$sitename, 'getSiteURL from config as http_host with SSL');

$mockEnv{HTTPS} = "";
$mockEnv{HTTP_HOST} = "devsite.com";
$session->url->setSiteURL(undef);
is( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL where requested host is not a configured site');

my @config_sitename = @{ $session->config->get('sitename') };
$session->config->addToArray('sitename', 'devsite.com');
$session->url->setSiteURL(undef);
is( $session->url->getSiteURL, 'http://devsite.com', 'getSiteURL where requested host is not the first configured site');

$session->setting->set('hostToUse', 'sitename');
$session->url->setSiteURL(undef);
is( $session->url->getSiteURL, 'http://'.$sitename, 'getSiteURL where illegal host has been requested');

$session->config->set('webServerPort', 80);
$session->url->setSiteURL(undef);
is( $session->url->getSiteURL, 'http://'.$sitename.':80', 'getSiteURL with a port');

$session->config->set('webServerPort', 8880);
$session->url->setSiteURL(undef);
is( $session->url->getSiteURL, 'http://'.$sitename.':8880', 'getSiteURL with a non-standard port');

$session->url->setSiteURL('http://'.$sitename);
is( $session->url->getSiteURL, 'http://'.$sitename, 'restore config setting');
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

is( $session->url->makeCompliant($url), $url2, 'language specific URL compliance');


#######################################
#
# getRequestedUrl
#
#######################################

my $originalRequest = $session->request;  ##Save the original request object
$session->{_request} = undef;

is($session->url->getRequestedUrl, undef, 'getRequestedUrl returns undef unless it has a request object');
$session->{_request} = $originalRequest;

$pseudoRequest->uri('empty');
is($session->request->uri, 'empty', 'Validate Mock Object operation');

$pseudoRequest->uri('full');
is($session->request->uri, 'full', 'Validate Mock Object operation #2');

$pseudoRequest->uri('/path1/file1');
is($session->url->getRequestedUrl, 'path1/file1', 'getRequestedUrl, fetch');

$pseudoRequest->uri('/path2/file2');
is($session->url->getRequestedUrl, 'path1/file1', 'getRequestedUrl, check cache of previous result');

$session->url->{_requestedUrl} = undef;  ##Manually clear cached value
$pseudoRequest->uri('/path2/file2?param1=one;param2=two');
is($session->url->getRequestedUrl, 'path2/file2', 'getRequestedUrl, does not return params');

#######################################
#
# page
#
#######################################

my $sessionAsset = $session->asset;
$session->asset(undef);

$session->url->{_requestedUrl} = undef;  ##Manually clear cached value
$pseudoRequest->uri('/path1/">file1');
is($session->url->page, '/path1/%22%3Efile1', 'page with no args returns getRequestedUrl through gateway, escaping the requested URL for safety');

is($session->url->page('op=viewHelpTOC;topic=Article'), '/path1/%22%3Efile1?op=viewHelpTOC;topic=Article', 'page: pairs are appended');

$url2 = 'http://'.$session->config->get('sitename')->[0].'/path1/%22%3Efile1';
is($session->url->page('',1), $url2, 'page: withFullUrl includes method and sitename');

$session->setting->set('preventProxyCache', 0);

is($session->url->page('','',1), '/path1/%22%3Efile1', 'page: skipPreventProxyCache is a no-op with preventProxyCache off in settings');
$session->setting->set('preventProxyCache', 1);
my $cacheableUrl = $session->url->page('','',1);
is($cacheableUrl, '/path1/%22%3Efile1', 'page: skipPreventProxyCache does not change url');

like($session->url->page('','',0), qr(^/path1/%22%3Efile1\?noCache=\d{0,4}:\d+$), 'page: noCache added');

##Restore original setting
$session->setting->set('preventProxyCache', $preventProxyCache);

my $defaultAsset = WebGUI::Asset->getDefault($session);
$session->asset($defaultAsset);
is($session->url->page, $session->url->gateway($defaultAsset->get('url')), 'page:session asset trumps requestedUrl');
$session->asset($sessionAsset);
#######################################
#
# getReferrerUrl
#
#######################################

$mockEnv{'HTTP_REFERER'} = 'test';

is($session->env->get('HTTP_REFERER'), 'test', 'testing overridden ENV');

foreach my $test (@getRefererUrlTests) {
	$mockEnv{HTTP_REFERER} = $test->{input};
	is($session->url->getRefererUrl, $test->{output}, $test->{comment});
}

#######################################
#
# makeAbsolute
#
#######################################

is($session->url->makeAbsolute('page1', '/layer1/layer2/'), '/layer1/layer2/page1', 'makeAbsolute: use a different root');
is($session->url->makeAbsolute('page1', '/layer1/page2'), '/layer1/page1', 'makeAbsolute: use a second root that is one level shallower');
is($session->url->makeAbsolute('page1'), '/page1', 'makeAbsolute: default baseUrl from session->asset');

#######################################
#
# extras
#
#######################################

my $origExtras = $session->config->get('extrasURL');
my $extras  = $origExtras;

my $savecdn = $session->config->get('cdn');
if ($savecdn) {
    $session->config->delete('cdn');
}
# Note: the CDN configuration will be reverted in the END

is($session->url->extras, $extras.'/', 'extras method returns URL to extras with a trailing slash');
is($session->url->extras('foo.html'), join('/', $extras,'foo.html'), 'extras method appends to the extras url');
is($session->url->extras('/foo.html'), join('/', $extras,'foo.html'), 'extras method removes extra slashes');
is($session->url->extras('/dir1//foo.html'), join('/', $extras,'dir1/foo.html'), 'extras method removes extra slashes anywhere');

$extras = 'http://mydomain.com/';
$session->config->set('extrasURL', $extras);

is($session->url->extras('/foo.html'),       join('', $extras,'foo.html'),      'extras method removes extra slashes');
is($session->url->extras('/dir1//foo.html'), join('', $extras,'dir1/foo.html'), 'extras method removes extra slashes anywhere');

$extras = 'https://mydomain.com/';
$session->config->set('extrasURL', $extras);

is($session->url->extras('/foo.html'),       join('', $extras,'foo.html'),      'extras method removes extra slashes');
is($session->url->extras('/dir1//foo.html'), join('', $extras,'dir1/foo.html'), 'extras method removes extra slashes anywhere');

$extras = 'http://mydomain.com/';
$session->config->set('extrasURL', $extras);

my $cdnCfg = { "enabled"       => 1,
               "extrasCdn"     => "http://extras.example.com/",
               "extrasSsl"     => "https://ssl.example.com/",
               "extrasExclude" => ["^tiny"]
             };
$session->config->set('cdn', $cdnCfg);
is($session->url->extras('/dir1/foo.html'), join('', $cdnCfg->{extrasCdn}, 'dir1/foo.html'),
   'extras cleartext with CDN');
is($session->url->extras('tinymce'), join('', $extras, 'tinymce'),
   'extras exclusion from CDN');
# Note: env is already mocked above.
$mockEnv{HTTPS} = 'on';
is($session->url->extras('/dir1/foo.html'), join('', $cdnCfg->{extrasSsl}, 'dir1/foo.html'),
   'extras using extrasSsl with HTTPS');
$mockEnv{HTTPS} = undef;
$mockEnv{SSLPROXY} = 1;
is($session->url->extras('/dir1/foo.html'), join('', $cdnCfg->{extrasSsl}, 'dir1/foo.html'),
   'extras using extrasSsl with SSLPROXY');
delete $mockEnv{SSLPROXY};

$session->config->set('extrasURL', $origExtras);

# partial cleanup here; complete cleanup in END block
$session->config->delete('cdn');

#######################################
#
# escape and unescape
# Our goal in this test is just to show that the calls to the URI module work,
# not to test the URI methods themselves
#
#######################################

my $escapeString = '10% is enough;';
my $escapedString = $session->url->escape($escapeString);
my $unEscapedString = $session->url->unescape($escapeString);
is($escapedString, '10%25%20is%20enough%3B', 'escape method');
is($unEscapedString, '10% is enough;', 'unescape method');

#######################################
#
# urlize
# part of urlize is calling makeCompliant, which is tested elsewhere.
# these tests will just make sure that it was called correctly and
# check other urlize behavior
#
#######################################

is($session->url->urlize('HOME/PATH1'), 'home/path1', 'urlize: urls are lower cased');
is($session->url->urlize('home/'), 'home', '... trailing slashes removed');
is($session->url->urlize('home is where the heart is'), 'home-is-where-the-heart-is', '... makeCompliant translates spaces to dashes');
is($session->url->urlize('/home'), 'home', '... removes initial slash');
is($session->url->urlize('home/../out-of-bounds'),    'home/out-of-bounds', '... removes multiple ../');
is($session->url->urlize('home/./here'),              'home/here', '... removes multiple ./');
is($session->url->urlize('home/../../out-of-bounds'), 'home/out-of-bounds', '... removes multiple ../');
is($session->url->urlize('home/././here'),            'home/here', '... removes multiple ./');

#######################################
#
# getBackToSiteURL
#
#######################################

$sessionAsset = $session->asset;
$session->{_asset} = undef;
$session->url->{_requestedUrl} = undef;  ##Manually clear cached value
$pseudoRequest->uri('/goBackToTheSite');

is($session->url->getBackToSiteURL, '/goBackToTheSite', 'getBackToSiteURL: when session asset is undefined, the method falls back to using page');

$session->asset($sessionAsset);
is($session->url->getBackToSiteURL, $session->asset->getUrl, q!getBackToSiteURL: for most regular old assets, it takes you back to the assets container!);

my $defaultAssetUrl = WebGUI::Asset->getDefault($session)->getUrl;

$session->asset( WebGUI::Asset->getImportNode($session) );
is(
    $session->url->getBackToSiteURL, 
    $defaultAssetUrl,
    q!getBackToSiteURL: importNode asset returns you to the default Asset!
);

$session->asset( WebGUI::Asset->getMedia($session) );
is(
    $session->url->getBackToSiteURL, 
    $defaultAssetUrl,
    q!getBackToSiteURL: Media Folder asset returns you to the default Asset!
);

$session->asset( WebGUI::Asset->getRoot($session) );
is(
    $session->url->getBackToSiteURL, 
    $defaultAssetUrl,
    q!getBackToSiteURL: Root returns you to the default Asset!
);

TODO: {
    local $TODO = 'extra tests for getBackToSiteURL';
    ok(0, 'test a child of the import node');
    ok(0, 'test a child of the media folder');
}

my $versionTag = WebGUI::VersionTag->getWorking($session);
my $statefulAsset = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });
$versionTag->commit;
$session->asset( $statefulAsset );

$statefulAsset->{_properties}{state} = 'published';
is(
    $session->url->getBackToSiteURL, 
    WebGUI::Asset->getRoot($session)->getUrl,
    q!getBackToSiteURL: When asset state is published, it returns you to the Assets container!
);

$statefulAsset->{_properties}{state} = 'trash';
is(
    $session->url->getBackToSiteURL, 
    $defaultAssetUrl,
    q!getBackToSiteURL: When asset state is trash, it returns you to the default Asset!
);

$statefulAsset->{_properties}{state} = 'clipboard';
is(
    $session->url->getBackToSiteURL, 
    $defaultAssetUrl,
    q!getBackToSiteURL: When asset state is clipboard, it returns you to the default Asset!
);

#######################################
#
# forceSecureConnection
#
#######################################

my $origSSLEnabled = $session->config->get('sslEnabled');

##Test all the false cases, first

$session->config->set('sslEnabled', 0);
$mockEnv{HTTPS}    = 'not on';
$mockEnv{SSLPROXY} = 0;
ok( ! $session->url->forceSecureConnection(), 'sslEnabled must be 1 to force SSL');

$session->config->set('sslEnabled', 1);
$mockEnv{HTTPS}    = 'on';
$mockEnv{SSLPROXY} = 0;
ok( ! $session->url->forceSecureConnection(), 'HTTPS must not be "on" to force SSL');

$session->config->set('sslEnabled', 1);
$mockEnv{HTTPS}    = 'not on';
$mockEnv{SSLPROXY} = 1;
ok( ! $session->url->forceSecureConnection(), 'SSLPROXY must not be true to force SSL');
ok( ! $session->url->forceSecureConnection('/test/url'), 'all conditions must be met, even if a URL is directly passed in');

##Validate the HTTP object state before we start
$session->http->setStatus('200', 'OK');
is($session->http->getStatus, 200, 'http status is okay, 200');
is($session->http->getRedirectLocation, undef, 'redirect location is empty');

$mockEnv{HTTPS}    = 'not on';
$mockEnv{SSLPROXY} = 0;

my $secureUrl = $session->url->getSiteURL . '/foo/bar/baz/buz';
$secureUrl =~ s/http:/https:/;

ok($session->url->forceSecureConnection('/foo/bar/baz/buz'), 'forced secure connection');
is($session->http->getStatus, 302, 'http status set to redirect, 302');
is($session->http->getRedirectLocation, $secureUrl, 'redirect location set to proper passed in URL with SSL and sitename added');

$session->http->setStatus('200', 'OK');
$session->http->setRedirectLocation(undef);

$secureUrl = $session->url->getSiteURL . $session->url->page();
$secureUrl =~ s/http:/https:/;
ok($session->url->forceSecureConnection(), 'forced secure connection with no url param');
ok($session->http->isRedirect, '... and redirect status code was set');
is($session->http->getRedirectLocation, $secureUrl, '... and redirect status code was set');

$session->config->set('sslEnabled', $origSSLEnabled);

END {  ##Always clean-up
	$session->asset($sessionAsset);
	$versionTag->rollback if defined $versionTag;

	$session->config->set('sitename',           \@config_sitename);
    $session->config->set('gateway',            $gateway);
    $session->config->set('extrasURL',          $origExtras);
    $session->config->set('sslEnabled',         $origSSLEnabled) if defined $origSSLEnabled;

	if ($config_port) {
		$session->config->set($config_port);
	}
	else {
		$session->config->delete('webServerPort');
	}
	if ($savecdn) {
	   $session->config->set('cdn', $savecdn);
	} else {
	   $session->config->delete('cdn');
	}
}
