#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use HTML::TokeParser;
use DateTime;
use DateTime::Format::Strptime;
use Data::Dumper;

use Test::More; # increment this value for each test you create
use Test::Deep;

plan tests => 48;

my $session = WebGUI::Test->session;

my $http = $session->http;

use Test::MockObject::Extends;

##This tests mocks http's getCookies so that it doesn't have to
##try and implement the mod_perl cookie handling code.
$http = Test::MockObject::Extends->new($http);
my $cookieName = $session->config->getCookieName;
my $varId = $session->var->getId();

$http->mock( getCookies => sub { return {$cookieName => $varId} } );

isa_ok($http, 'WebGUI::Session::Http', 'session has correct object type');

####################################################
#
# setStatus, getStatus
#
####################################################

$http->setStatus('123');

is($http->getStatus, '123', 'getStatus: returns correct code');

$http->setStatus('');

is($http->getStatus, '200', 'getStatus: returns default code');

$http->setStatus('', 'packets are great');

####################################################
#
# isRedirect
#
####################################################

$http->setStatus('200');
ok(!$http->isRedirect, 'isRedirect: 200 is not');

$http->setStatus('301');
ok($http->isRedirect, '... 301 is');

$http->setStatus('302');
ok($http->isRedirect, '... 302 is too');
$http->setStatus('200');

####################################################
#
# setMimeType, getMimeType
#
####################################################

$http->setMimeType('');
is($http->getMimeType, 'text/html; charset=UTF-8', 'set/get MimeType: default is text/html');

$http->setMimeType('image/jpeg');
is($http->getMimeType, 'image/jpeg', 'set/get MimeType: set specific type and get it');
$http->setMimeType('');

####################################################
#
# setStreamedFile, getStreamedFile
#
####################################################

$http->setStreamedFile('');
is($http->getStreamedFile, undef, 'set/get StreamedFile: false values return undef, empty string');
$http->setStreamedFile(0);
is($http->getStreamedFile, undef, 'set/get StreamedFile: false values return undef, empty string');

$http->setStreamedFile('/home/streaming');
is($http->getStreamedFile, '/home/streaming', 'set/get StreamedFile: set specific location and get it');
$http->setStreamedFile('');

####################################################
#
# setFilename, getFilename
#
####################################################

$http->setFilename('foo.bin');
is($http->getFilename, 'foo.bin', 'set/get Filename: filename passed');
is($http->getMimeType(), 'application/octet-stream', 'set/get Filename: default mime type is octet/stream');

$http->setFilename('foo.txt','text/plain');
is($http->getFilename, 'foo.txt', 'set/get Filename: filename set');
is($http->getMimeType(), 'text/plain', 'set/get Filename: mime type set');
$http->setFilename('');
$http->setMimeType('');

####################################################
#
# setLastModified, getLastModified
#
####################################################

is($http->getLastModified, undef, 'getLastModified: default is undef');

$http->setLastModified(12);
is($http->getLastModified, 12, 'set/get LastModified: epoch date set');
$http->setLastModified(undef);

####################################################
#
# setCacheControl, getCacheControl
#
####################################################

is($http->getCacheControl, 1, 'getCacheControl: default is 1');

$http->setCacheControl("none");
is($http->getCacheControl, "none", 'set/get CacheControl: set to "none"');
$http->setCacheControl(7200);
is($http->getCacheControl, 7200, 'set/get CacheControl: set to 7200');
$http->setCacheControl(0);
is($http->getCacheControl, 1, 'set/get CacheControl: set to 0 returns 1');
$http->setCacheControl(undef);

####################################################
#
# setRedirect, getRedirectLocation
#
####################################################

$session->request->uri('/here/later');

$http->setRedirect('/here/now');
is($http->getStatus, 302, 'setRedirect: sets HTTP status');
is($http->getRedirectLocation, '/here/now', 'setRedirect: redirect location');

$session->style->useEmptyStyle(1);
my $styled = $session->style->generateAdditionalHeadTags();
my @metas = fetchMultipleMetas($styled);
my $expectedMetas = [
	{
		'http-equiv' => 'refresh',
		'content' => '0; URL=/here/now'
	},
];
cmp_bag(\@metas, $expectedMetas, 'setRedirect:sets meta tags in the style object');

$session->request->uri('/here/now');
$session->url->{_requestedUrl} = '';
my $sessionAsset = $session->asset;
$session->{_asset} = WebGUI::Asset->getDefault($session);
my $defaultAssetUrl = $session->asset->getUrl;

is($http->setRedirect($defaultAssetUrl), undef, 'setRedirect: returns undef if returning to self and no params');

$session->request->setup_body({ param1 => 'value1' });
isnt($http->setRedirect('/here/now'), undef, 'setRedirect: does not return undef if returning to self but there are params');

$session->{_asset} = $sessionAsset;

####################################################
#
# setNoHeader and sendHeader
#
####################################################

##Force settings
$session->setting->set('preventProxyCache', 0);

##Clear request object for next two tests
$session->{_request} = undef;

is($http->getNoHeader, undef, 'getNoHeader: defaults to undef');
$http->setNoHeader(1);
is($http->getNoHeader, 1, 'get/set NoHeader: returns set value');
is($http->sendHeader, undef, 'sendHeader returns undef when setNoHeader is true');

$http->setNoHeader(0);
is($http->sendHeader, undef, 'sendHeader returns undef when no request object is available');

####################################################
#
# sendHeader, redirect
#
####################################################

{
    ##A new, clean session
    my $session1 = WebGUI::Test->newSession('noCleanup');
    my $guard   = WebGUI::Test->cleanupGuard($session1);

    $session1->http->setRedirect('/here/there');
    $session1->http->sendHeader;
    is($session1->response->status, 302, 'sendHeader as redirect: status set to 301');
    cmp_deeply(
        headers_out($session1->response->headers),
        {
            'Location' => '/here/there',
        },
        '... location set'
    );
}

####################################################
#
# sendHeader, Status, LastModified, default mime-type, cache headers.
#
####################################################

{

    ##A new, clean session
    my $session  = WebGUI::Test->newSession('nocleanup');
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;
    $http->setStatus(200, 'Just spiffy');
    $http->setMimeType('');
    $session->request->protocol('');
    $http->setLastModified(1200);

    $http->sendHeader();
    is($response->status, 200, 'sendHeader: status set');
    cmp_deeply(
        [ $response->content_type ],
        [ 'text/html', 'charset=UTF-8']
        , '... default mimetype'
    );
    cmp_deeply(
        headers_out($response->headers),
        {
           'Last-Modified' => $session->datetime->epochToHttp(1200),
           'Cache-Control' => 'must-revalidate, max-age=1',
           'Content-Type'  => 'text/html; charset=UTF-8',
        },
        '... normal headers'
    );
}

####################################################
#
# sendHeader, mime-type, filename/attachment, recent HTTP protocol
#
####################################################

{
    ##A new, clean session
    my $session  = WebGUI::Test->newSession('nocleanup', { SERVER_PROTOCOL => 'HTTP 1.1', });
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;
    $http->setFilename('image.png');
    $http->setMimeType('image/png');
    $http->sendHeader();
    is($response->headers->content_type, 'image/png', 'sendHeader: mimetype');
    cmp_deeply(
        headers_out($response->headers),
        {
            'Last-Modified'       => $session->datetime->epochToHttp(time()),
            'Content-Disposition' => q!attachment; filename="image.png"!,
            'Content-Type'        => 'image/png',
            'Cache-Control'       => 'must-revalidate, max-age=1'
        },
        '... normal headers'
    );
}
####################################################
#
# sendHeader, old HTTP protocol
#
####################################################
{
    ##A new, clean session
    my $http_request = HTTP::Request::Common::GET('http://'.$session->config->get('sitename')->[0]);
    $http_request->protocol('HTTP/1.0');
    my $session  = WebGUI::Test->newSession('nocleanup', $http_request);
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;
    my $time = $session->datetime->epochToHttp(time());
    $http->sendHeader();
    my $headers       = headers_out($response->headers);
    my $expire_header = $headers->{Expires};
    my $delta = deltaHttpTimes($session->datetime->epochToHttp(), $expire_header);
    cmp_ok($delta->seconds, '<=', 1, 'sendHeader, old HTTP protocol: adds extra cache header field');
    cmp_deeply(
        $headers,
        {
            'Last-Modified' => ignore(),
            'Cache-Control' => 'must-revalidate, max-age=1',
            'Content-Type'  => 'text/html; charset=UTF-8',
            'Expires'       => ignore(),
        },
        '... checking headers'
    );

}

####################################################
#
# sendHeader, old HTTP protocol, cacheControl set to 500
#
####################################################

{
    ##A new, clean session
    my $http_request = HTTP::Request::Common::GET('http://'.$session->config->get('sitename')->[0]);
    $http_request->protocol('HTTP/1.0');
    my $session  = WebGUI::Test->newSession('nocleanup', $http_request);
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;
    $http->setCacheControl(500);
    $http->sendHeader();
    my $headers       = headers_out($response->headers);
    my $expire_header = $headers->{Expires};
    my $delta = deltaHttpTimes($session->datetime->epochToHttp(time+500), $expire_header);
    cmp_ok($delta->seconds, '<=', 2, 'sendHeader, old HTTP protocol, cacheControl=500: adds extra cache header field');
    cmp_deeply(
        $headers,
        {
            'Last-Modified' => ignore(),
            'Cache-Control' => 'must-revalidate, max-age=500',
            'Content-Type'  => 'text/html; charset=UTF-8',
            'Expires'       => ignore(),
        },
        '... checking headers'
    );

}

####################################################
#
# sendHeader, preventProxyCache changes cache headers
#
####################################################

##Clear request object to run a new set of requests
{
    ##A new, clean session
    my $session  = WebGUI::Test->newSession('nocleanup');
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;

    $session->setting->set('preventProxyCache', 1);

    $http->sendHeader();
    cmp_deeply(
        headers_out($response->headers),
        {
            'Content-Type'  => 'text/html; charset=UTF-8',
            'Cache-Control' => 'private, max-age=1, no-cache',
            'Pragma'        => 'no-cache',
        },
        'sendHeader: Cache-Control setting when preventProxyCache set'
    );

    $session->setting->set('preventProxyCache', 0);
}

####################################################
#
# sendHeader, cacheControl=none changes cache headers
#
####################################################

{
    ##A new, clean session
    my $session  = WebGUI::Test->newSession('nocleanup');
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;
    $http->setCacheControl('none');
    $http->sendHeader();
    cmp_deeply(
        headers_out($response->headers),
        {
            'Cache-Control' => 'private, max-age=1, no-cache',
            'Content-Type'  => 'text/html; charset=UTF-8',
            'Pragma'        => 'no-cache',
        },
        'sendHeader: Cache-Control setting when cacheControl="none"'
    );
}

####################################################
#
# sendHeader, non-visitor user changes cache headers
#
####################################################

{
    ##A new, clean session
    my $session  = WebGUI::Test->newSession('nocleanup');
    my $guard    = WebGUI::Test->cleanupGuard($session);
    my $http     = $session->http;
    my $response = $session->response;
    $session->user({userId => 3});

    $http->sendHeader();
    cmp_deeply(
        headers_out($response->headers),
        {
            'Cache-Control' => 'private, max-age=1, no-cache',
            'Content-Type'  => 'text/html; charset=UTF-8',
            'Pragma'        => 'no-cache',
        },
        'sendHeader: Cache-Control setting when user is not Visitor'
    );

}

####################################################
#
# ifModifiedSince
#
####################################################
##Clear request object to run a new set of requests

{
    ##A new, clean session
    my $http_request = HTTP::Request::Common::GET('http://'.$session->config->get('sitename')->[0]);
    $http_request->header('If-Modified-Since' => '');
    my $session  = WebGUI::Test->newSession('nocleanup', $http_request);
    my $guard    = WebGUI::Test->addToCleanup($session);
    ok $session->http->ifModifiedSince(0), 'ifModifiedSince: empty header always returns true';

}

{
    my $http_request = HTTP::Request::Common::GET('http://'.$session->config->get('sitename')->[0]);
    $http_request->header('If-Modified-Since' => $session->datetime->epochToHttp(WebGUI::Test->webguiBirthday));
    my $session  = WebGUI::Test->newSession('nocleanup', $http_request);
    my $guard    = WebGUI::Test->cleanupGuard($session);
    ok  $session->http->ifModifiedSince(WebGUI::Test->webguiBirthday + 5), '... epoch check, true';
    ok !$session->http->ifModifiedSince(WebGUI::Test->webguiBirthday - 5), '... epoch check, false';
    ok  $session->http->ifModifiedSince(WebGUI::Test->webguiBirthday - 5, 3600), '... epoch check, made true by maxCacheTimeout';
}

####################################################
#
# Utility functions
#
####################################################

=head2 fetchMultipleMetas ($text)

Parse a piece of text as HTML, and extract out all the meta tags from it.  Returns the meta
tags as a list.

=cut

sub fetchMultipleMetas {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);
	my @metas = ();

	while (my $token = $p->get_tag('meta')) {
		my $params = $token->[1];
		delete $params->{'/'};  ##delete unary slash from XHTML output
		push @metas, $params;
	}

	return @metas;
}

=head2 deltaHttpTimes ($http1, $http2)

Takes two dates in HTTP format, and returns $http1 - $http2

=cut

sub deltaHttpTimes {
	my ($http1, $http2) = @_;
	my $httpParser = DateTime::Format::Strptime->new(pattern =>'%a, %d %b %Y %H:%M:%S', time_zone => 'GMT');
	my $dt1 = $httpParser->parse_datetime($http1);
	my $dt2 = $httpParser->parse_datetime($http2);
	my $delta_time = $dt1-$dt2;
}

=head2 headers_out ($header_object)

Returns an array reference of HTTP headers, as hashrefs, from a HTTP::Headers object, to make comparison with
Test::Deep easier.

=cut

sub headers_out {
	my ($head_obj) = @_;
    my $headers = {};
    foreach my $field_name ($head_obj->header_field_names) {
        $headers->{$field_name} = $head_obj->header($field_name);
    }
    return $headers;
}
