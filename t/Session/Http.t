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
use WebGUI::PseudoRequest;
use WebGUI::Session;
use HTML::TokeParser;
use DateTime;
use DateTime::Format::Strptime;
use Data::Dumper;

use Test::More; # increment this value for each test you create
use Test::Deep;

my $num_tests = 41;

plan tests => $num_tests;
 
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
# setStatus, getStatus, getStatusDescription
#
####################################################

$http->setStatus('123');

is($http->getStatus, '123', 'getStatus: returns correct code');
is($http->getStatusDescription, 'OK', 'getStatusDescription: returns default description via getStatus');

$http->setStatus('');

is($http->getStatusDescription, 'OK', 'getStatusDescription: returns default description via itself');
is($http->getStatus, '200', 'getStatus: returns default code');

$http->setStatus('', 'packets are great');

is($http->getStatusDescription, 'packets are great', 'getStatusDescription: returns correct description');

####################################################
#
# isRedirect
#
####################################################

$http->setStatus('200');
is($http->isRedirect, '', 'isRedirect: is not');

$http->setStatus('302');
is($http->isRedirect, 1, 'isRedirect: is too');
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

##Let's make a "request object" :)
my $request = WebGUI::PseudoRequest->new();
$session->{_request} = $request;

$session->request->uri('/here/later');

$http->setRedirect('/here/now');
is($http->getStatus, 302, 'setRedirect: sets HTTP status');
is($http->getStatusDescription, 'Redirect', 'setRedirect: sets HTTP status description');
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

$request->uri('/here/now');
$session->url->{_requestedUrl} = '';
is($http->setRedirect('/here/now'), undef, 'setRedirect: returns undef if returning to self and no params');

$request->setup_body({ param1 => 'value1' });
isnt($http->setRedirect('/here/now'), undef, 'setRedirect: does not return undef if returning to self but there are params');

####################################################
#
# setNoHeader and sendHeader
#
####################################################

##Force settings
my $origPreventProxyCache = $session->setting->get('preventProxyCache');
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

##Clear request object to run a new set of requests
$request = WebGUI::PseudoRequest->new();
$session->{_request} = $request;

$http->setRedirect('/here/there');
$http->sendHeader;
is($request->status, 301, 'sendHeader as redirect: status set to 301');
is_deeply($request->headers_out->fetch, {'Location' => '/here/there'}, 'sendHeader as redirect: location set');

##Clear request object to run a new set of requests
$request = WebGUI::PseudoRequest->new();
$session->{_request} = $request;
$http->setStatus(200, 'Just spiffy');
$http->setMimeType('');
$http->setLastModified(1200);
$http->setNoHeader(0);

$http->sendHeader();
is($request->status, 200, 'sendHeader: status set');
is($request->status_line, '200 Just spiffy', 'sendHeader: status_line set');
is($request->content_type, 'text/html; charset=UTF-8', 'sendHeader: default mimetype');
is($request->no_cache, undef, 'sendHeader: no_cache undefined');
my $expected_headers = {
    'Last-Modified' => $session->datetime->epochToHttp(1200),
    'Cache-Control' => 'must-revalidate, max-age=1',
};
cmp_deeply($request->headers_out->fetch, $expected_headers, 'sendHeader: normal headers');

$http->setNoHeader(0);
$http->setFilename('image.png');
$http->sendHeader();
is_deeply(
	$request->headers_out->fetch,
	{
		'Last-Modified' => $session->datetime->epochToHttp(1200),
		'Content-Disposition' => q!attachment; filename="image.png"!,
        'Cache-Control' => 'must-revalidate, max-age=1',
	},
	'sendHeader: normal headers'
);

##Clear request object to run a new set of requests
$request = WebGUI::PseudoRequest->new();
$session->{_request} = $request;
$http->setFilename('');
$http->setNoHeader(0);
$session->user({userId => 3});
$http->sendHeader();

####################################################
#
# Utility functions
#
####################################################

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

sub deltaHttpTimes {
	my ($http1, $http2) = @_;
	my $httpParser = DateTime::Format::Strptime->new(pattern =>'%a, %d %b %Y %H:%M:%S', time_zone => 'GMT');
	my $dt1 = $httpParser->parse_datetime($http1);
	my $dt2 = $httpParser->parse_datetime($http2);
	my $delta_time = $dt1-$dt2;
}


END {
	$session->setting->set('preventProxyCache', $origPreventProxyCache);
}
