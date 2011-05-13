#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# this test file is now slightly badly named since the functions in 
# WebGUI::Session::HTTML have all been migrated to 
# WebGUI::Session::Request and ::Response.  still, these tests need
# to continue to pass.

use strict;

use WebGUI::Test;
use WebGUI::Session;
use HTML::TokeParser;
use DateTime;
use DateTime::Format::Strptime;
use Data::Dumper;

use Test::More; # increment this value for each test you create
use Test::Deep;

my $session = WebGUI::Test->session;

my $http     = $session->http;
my $response = $session->response;

use Test::MockObject::Extends;

##This tests mocks http's getCookies so that it doesn't have to
##try and implement the mod_perl cookie handling code.
$http = Test::MockObject::Extends->new($http);
my $cookieName = $session->config->getCookieName;
my $varId = $session->getId();

$http->mock( getCookies => sub { return {$cookieName => $varId} } );

isa_ok($http, 'WebGUI::Session::Http', 'session has correct object type');

####################################################
#
# isRedirect
#
####################################################

$response->status('200');
ok(!$http->isRedirect, 'isRedirect: 200 is not');

$response->status('301');
ok($http->isRedirect, '... 301 is');

$response->status('302');
ok($http->isRedirect, '... 302 is too');
$response->status('200');

####################################################
#
# setStreamedFile, getStreamedFile
#
####################################################

$http->setStreamedFile('');
is($http->getStreamedFile, undef, 'set/get StreamedFile: false values return undef, empty string');
$http->setStreamedFile(undef);
is($http->getStreamedFile, undef, 'set/get StreamedFile: false values return undef, empty string');

my $actual_file = $session->config->get('uploadsPath') . '/9e/a3/9ea37e148e517d4ae3d6326f691d848f/previous.gif'; # arbitrary file that exactually exists and hopefully will continue for a while
$http->setStreamedFile( $actual_file );
is($http->getStreamedFile, $actual_file, 'set/get StreamedFile: set specific location and get it');

do {
    eval { 
        $http->setStreamedFile( $actual_file . '_but_actually_not_an_actual_file_because_someone_appended_a_bunch_of_bloody_garbage_to_it' );
    };
    my $e = WebGUI::Error->caught("WebGUI::Error::InvalidFile");
    my $errorMessage = $e->error;
    ok($errorMessage =~ m/No such file or directory/, "set/get StreamedFile: setting a non-existant file blows stuff up but that's okay because it's handled gracefully" );
};

$http->setStreamedFile('');

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
# setRedirect
#
####################################################

$session->request->uri('/here/later');

$http->setRedirect('/here/now');
is($response->status, 302, 'setRedirect: sets HTTP status');
is($response->location, '/here/now', 'setRedirect: redirect location');

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
            'Content-Type' => 'text/html; charset=UTF-8',
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
    $response->status(200);
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
    $response->header( 'Content-Disposition' => qq{attachment; filename="image.png"});
    $response->content_type('image/png');
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

done_testing;

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
