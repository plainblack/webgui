# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI::Session;
plan skip_all => 'set WEBGUI_LIVE to enable this test' unless $ENV{WEBGUI_LIVE};

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );
my @versionTags     = ( WebGUI::VersionTag->getWorking( $session ) );

# Override some settings to make things easier to test
# userFunctionStyleId 
$session->setting->set( 'userFunctionStyleId', 'PBtmpl0000000000000132' );
# specialState
$session->setting->set( 'specialState', '' );

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
    = $node->addChild({ 
        className       => 'WebGUI::Asset::Snippet', 
        url             => $snippetUrl,
        snippet         => $testContent,
    });
$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests

if ( !eval { require Test::WWW::Mechanize; 1; } ) {
    plan skip_all => 'Cannot load Test::WWW::Mechanize. Will not test.';
}
$mech    = Test::WWW::Mechanize->new;
$mech->get( $baseUrl );
if ( !$mech->success ) {
    plan skip_all => "Cannot load URL '$baseUrl'. Will not test.";
}

plan tests => 12;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test operation with a public Redirect
push @versionTags, WebGUI::VersionTag->getWorking( $session );
$redirect       
    = $node->addChild({
        className       => 'WebGUI::Asset::Redirect',
        redirectUrl     => $redirectToUrl,
        url             => $redirectUrl . scalar(@versionTags),
    });
$versionTags[-1]->commit;

$mech   = Test::WWW::Mechanize->new;
$mech->get_ok( $baseUrl . $redirectUrl . scalar(@versionTags), "We get the redirect" );
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
push @versionTags, WebGUI::VersionTag->getWorking( $session );
$redirect
    = $node->addChild({
        className       => 'WebGUI::Asset::Redirect',
        redirectUrl     => $redirectToUrl,
        url             => $redirectUrl . scalar(@versionTags),
        groupIdView     => 2,
        groupIdEdit     => 3,
    });
$versionTags[-1]->commit;

$mech       = Test::WWW::Mechanize->new;
$mech->get( $baseUrl . $redirectUrl . scalar(@versionTags) ); 
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
push @versionTags, WebGUI::VersionTag->getWorking( $session );
$redirect
    = $node->addChild({
        className           => 'WebGUI::Asset::Redirect',
        redirectUrl         => $redirectToUrl,
        url                 => $redirectUrl . scalar(@versionTags),
        groupIdView         => 2,
        groupIdEdit         => 3,
        forwardQueryParams  => 1,
    });
$versionTags[-1]->commit;

my $extraParams = 'extra=hi';
$mech       = Test::WWW::Mechanize->new;
$mech->get( $baseUrl . $redirectUrl . scalar(@versionTags) . '?' . $extraParams ); 
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


#----------------------------------------------------------------------------
# Cleanup
END {
    for my $tag ( @versionTags ) {
        $tag->rollback;
    }

}
