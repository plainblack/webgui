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

# This script uses Test::WWW::Mechanize to test the operation of Auth
# NOTE: This mostly tests Auth's common methods, even though it uses
# WebGUI::Auth::WebGUI.

# no form: tests assume that the form exists on the page
# displayLogin: tests go to ?op=auth;method=displayLogin after going to 
#   unauthorized page
# returnUrl: tests use returnUrl= to try to return to the right place

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

# Override some settings to make things easier to test
# userFunctionStyleId 
$session->setting->set( 'userFunctionStyleId', 'PBtmpl0000000000000132' );
# specialState
$session->setting->set( 'specialState', '' );

# Create a user for testing purposes
my $USERNAME    = 'dufresne';
my $IDENTIFIER  = 'ritahayworth';
my $user        = WebGUI::User->new( $session, "new", "something new" );
WebGUI::Test->addToCleanup($user);
$user->username( $USERNAME );
$user->addToGroups( ['3'] );
my $auth        = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->update( 
    'identifier'    => $auth->hashPassword($IDENTIFIER)
);

my ($redirect, $response, $url);

# Get the site's base URL
my $baseUrl         = 'http://localhost/';

my $httpAuthUrl = 'http://' . $USERNAME . ':' . $IDENTIFIER . '@' . $session->config->get('sitename')->[0];
# $httpAuthUrl    .= ':8000'; # no easy way to automatically find this
$httpAuthUrl    .= $session->config->get('gateway');

# Make an asset we can login on
my $tag = WebGUI::VersionTag->getWorking($session);
my $node            = WebGUI::Test->asset;
my $asset
    = $node->addChild({
        className       => 'WebGUI::Asset::Wobject::Article',
        description     => "ARTICLE",
        url             => time . 'loginAsset',
        groupIdView     => 2,   # Registered Users
        groupIdEdit     => 3,   # Admins
        styleTemplateId => 'PBtmpl0000000000000132', 
    });
my $assetUrl    = $baseUrl . $asset->get('url');
$tag->commit;
my $node  = $node->cloneFromDb;
my $asset = $asset->cloneFromDb;

#----------------------------------------------------------------------------
# Tests

my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );

#----------------------------------------------------------------------------
# no form: Test logging in on a normal page sends the user back to the same page
$mech->get( $assetUrl );
$mech->base_is( $assetUrl, "We got the page we were expecting" );
$url    = $assetUrl . '?op=auth;method=login;username=' . $USERNAME . ';identifier=' . $IDENTIFIER; 
$mech->get_ok( $url );
$mech->base_is( $assetUrl, "We weren't redirected anywhere" );
$mech->content_contains( "ARTICLE", "We are shown the article" );


#----------------------------------------------------------------------------
# no form: Test logging in on a normal page sends user back to same page AFTER at least one
# failed attempt
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl );
$mech->base_is( $assetUrl, "We got the page we were expecting" );
$url    = $assetUrl . '?op=auth;method=login;username=' . $USERNAME . ';identifier=nowai';
$mech->get( $url );
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);
$mech->base_is( $assetUrl, "We weren't redirected anywhere" );
$mech->content_contains( "ARTICLE", "We are shown the article" );


#----------------------------------------------------------------------------
# displayLogin: Test logging in on a normal page sends the user back to the same page
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl ); 
$mech->base_is( $assetUrl, "We got the page we were expecting" );
$mech->get_ok( $assetUrl . "?op=auth;method=displayLogin" );
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);

$mech->base_is( $assetUrl, "We were redirected to the same page after login" );

#----------------------------------------------------------------------------
# displayLogin: Test logging in on a normal page sends user back to same page AFTER at least one
# failed attempt
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl );
$mech->base_is( $assetUrl, "We got the page we were expecting" );
$mech->get_ok( $assetUrl . "?op=auth;method=displayLogin" );
$mech->submit_form( 
    with_fields => {
        username        => $USERNAME,
        identifier      => 'innocence',
    },
);
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);

$mech->base_is( $assetUrl, "We were redirected to the same page after login and failing once");

#----------------------------------------------------------------------------
# displayLogin: Test logging in on an operation other than ?op=auth
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl . '?op=listUsers' );
$mech->base_is( $assetUrl . '?op=listUsers', "We got the page we were expecting" );
$mech->get_ok( $assetUrl . "?op=auth;method=displayLogin" );
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);

$mech->base_is( $assetUrl, "We weren't redirected");

#----------------------------------------------------------------------------
# displayLogin: Test logging in on an operation other than ?op=auth after at least one 
# failed attempt
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl . '?op=listUsers' );
$mech->base_is( $assetUrl . '?op=listUsers', "We got the page we were expecting" );
$mech->get_ok( $assetUrl . "?op=auth;method=displayLogin" );
$mech->submit_form( 
    with_fields => {
        username        => $USERNAME,
        identifier      => 'innocence',
    },
);
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);

$mech->base_is( $assetUrl, "We weren't redirected" );


#----------------------------------------------------------------------------
# displayLogin: Test logging in after directly going to ?op=auth;method=init
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get_ok( $assetUrl . '?op=auth;method=init' );
$mech->base_is( $assetUrl . '?op=auth;method=init', "We got the page we were expecting" );
$mech->get_ok( $assetUrl . "?op=auth;method=displayLogin" );
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);

$mech->base_is( $assetUrl, "We were redirected to the right page" );


#----------------------------------------------------------------------------
# displayLogin: Test logging in after directly going to ?op=auth;method=init and failing
# at least once.
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get_ok( $assetUrl . '?op=auth;method=init' );
$mech->base_is( $assetUrl . '?op=auth;method=init', "We got the page we were expecting" );
$mech->get_ok( $assetUrl . "?op=auth;method=displayLogin" );
$mech->submit_form( 
    with_fields => {
        username        => $USERNAME,
        identifier      => 'innocence',
    },
);
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);

$mech->base_is( $assetUrl, "We were redirected to the right place" );

#----------------------------------------------------------------------------
# returnUrl: Test logging in on a normal page sends the user back to the same page
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl );
$mech->base_is( $assetUrl, "We got the page we were expecting" );
$url    = $assetUrl 
        . '?op=auth;returnUrl=%2Froot%2Fimport;method=login;username=' 
        . $USERNAME . ';identifier=' . $IDENTIFIER;
$mech->get_ok( $url );
$mech->base_is( $baseUrl . 'root/import', "We were redirected properly" );


#----------------------------------------------------------------------------
# returnUrl: Test logging in on a normal page sends user back to same page AFTER at least one
# failed attempt
$mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get( $assetUrl );
$mech->base_is( $assetUrl, "We got the page we were expecting" );
$url    = $assetUrl 
        . '?op=auth;returnUrl=%2Froot%2Fimport;method=login;username=' 
        . $USERNAME . ';identifier=nowai';
$mech->get( $url );
$mech->submit_form_ok( 
    {
        with_fields => {
            username        => $USERNAME,
            identifier      => $IDENTIFIER,
        },
    },
);
$mech->base_is( $assetUrl, "We don't get redirected" );

done_testing;
