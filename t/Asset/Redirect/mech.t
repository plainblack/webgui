# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This script uses Test::WWW::Mechanize to test the operation of the Redirect
# asset.
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI::Session;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create a user for testing purposes
my $user        = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($user);
$user->username( 'dufresne' );
my $identifier  = 'ritahayworth';
my $auth        = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->saveParams( $user->userId, $user->authMethod, {
    'identifier'    => Digest::MD5::md5_base64( $identifier ),
});

my ($mech, $redirect, $response);

# Get the site's base URL
my $baseUrl         = 'http://' . $session->config->get('sitename')->[0];
$baseUrl            .= $session->config->get('gateway');

# Set some constants
my $redirectUrl     = time . "shawshank";
my $testContent     = "Perhaps if you've gone this far, you'd be willing to go further.";
my $snippetUrl      = time . "zejuatenejo";
my $redirectToUrl   = $snippetUrl . "?name=value";
my $redirectToAsset
    = WebGUI::Test->asset(
        className       => 'WebGUI::Asset::Snippet',
        url             => $snippetUrl,
        snippet         => $testContent,
    );
my $tag1 = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($tag1);
$tag1->commit;
$redirectToAsset = $redirectToAsset->cloneFromDb;

my $count = time;   # A known count for url uniqueness

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Test operation with a public Redirect
$redirect
    = WebGUI::Test->asset(
        className       => 'WebGUI::Asset::Redirect',
        redirectUrl     => $redirectToUrl,
        url             => $redirectUrl . ++$count,
    );
my $tag2 = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($tag2);
$tag2->commit;
$redirect = $redirect->cloneFromDb;

$mech   = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/', 'initialize mech object with session');
$mech->get_ok($snippetUrl, 'snippet can be fetched');
$mech->get_ok( $redirectUrl . $count, "We get the redirect" );
$mech->content_contains( $testContent, "We made it to the snippet" );

$response = $mech->res->previous;
ok( $response, 'There were at least two requests' );
is(
    $response->headers->header('location'),
    $redirectToUrl,
    'We were redirected to the right URL'
);

#----------------------------------------------------------------------------
# Test operation with a private Redirect through a login
$redirect
    = WebGUI::Test->asset(
        className       => 'WebGUI::Asset::Redirect',
        redirectUrl     => $redirectToUrl,
        url             => $redirectUrl . ++$count,
        groupIdView     => 2,
        groupIdEdit     => 3,
    );

my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag);
$redirect = $redirect->cloneFromDb;

$mech       = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get( $baseUrl . $redirectUrl . $count );
$mech->submit_form_ok( {
    with_fields     => {
        username        => $user->username,
        identifier      => $identifier,
    },
}, 'Sent login form' );
$mech->content_contains( $testContent, "We made it to the snippet through the login" );

$response = $mech->res->previous;
ok( $response, 'There were at least two requests' );
is(
    $response->headers->header('location'),
    $redirectToUrl,
    "We were redirected to the right URL",
);


#----------------------------------------------------------------------------
# Test operation with a private Redirect through a login with translate
# query params
$redirect
    = WebGUI::Test->asset(
        className           => 'WebGUI::Asset::Redirect',
        redirectUrl         => $redirectToUrl,
        url                 => $redirectUrl . ++$count,
        groupIdView         => 2,
        groupIdEdit         => 3,
        forwardQueryParams  => 1,
    );

my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag);
$redirect = $redirect->cloneFromDb;

my $extraParams = 'extra=hi';
$mech       = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get( $baseUrl . $redirectUrl . $count . '?' . $extraParams );
$mech->submit_form_ok( {
    with_fields     => {
        username        => $user->username,
        identifier      => $identifier,
    },
}, 'Sent login form' );
$mech->content_contains( $testContent, "We made it to the snippet through the login" );

$response = $mech->res->previous;
ok( $response, 'There were at least two requests' );
TODO: {
    local $TODO = 'Add forwarding of query parameters to Redirect asset';
    is(
        $response->headers->header('location'),
        $redirectToUrl . ';' . $extraParams,
        "We were redirected to the right URL with forwarded query params",
    );
};

done_testing;

#vim:ft=perl
