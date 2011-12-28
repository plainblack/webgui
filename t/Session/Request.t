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
use WebGUI::Session;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $response = $session->response;

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
    ok $session->request->ifModifiedSince(0), 'ifModifiedSince: empty header always returns true';

}

{
    my $http_request = HTTP::Request::Common::GET('http://'.$session->config->get('sitename')->[0]);
    $http_request->header('If-Modified-Since' => $session->datetime->epochToHttp(WebGUI::Test->webguiBirthday));
    my $session  = WebGUI::Test->newSession('nocleanup', $http_request);
    my $guard    = WebGUI::Test->cleanupGuard($session);
    ok  $session->request->ifModifiedSince(WebGUI::Test->webguiBirthday + 5), '... epoch check, true';
    ok !$session->request->ifModifiedSince(WebGUI::Test->webguiBirthday - 5), '... epoch check, false';
    ok  $session->request->ifModifiedSince(WebGUI::Test->webguiBirthday - 5, 3600), '... epoch check, made true by maxCacheTimeout';
}

done_testing;


