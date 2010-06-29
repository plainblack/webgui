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

# Test the Auth::Twitter module
#
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 15;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Object creation

use_ok( 'WebGUI::Auth::Twitter' );

my $auth    = WebGUI::Auth::Twitter->new( $session, "Twitter" );
isa_ok( $auth, 'WebGUI::Auth::Twitter' );


#----------------------------------------------------------------------------
# API methods

my $user    = $auth->createTwitterUser( "1234", "AndyDufresne" );
WebGUI::Test->addToCleanup( $user );
isa_ok( $user, 'WebGUI::User' );
is(
    $session->db->quickScalar( 
        "SELECT fieldData FROM authentication WHERE userId=? AND authMethod=? AND fieldName=?",
        [ $user->userId, "Twitter", "twitterUserId" ],
    ),
    "1234",
    "Twitter User ID saved in authentication table",
);

my $tmpl    = $auth->getTemplateChooseUsername;
isa_ok( $tmpl, 'WebGUI::Asset::Template' );
is( $tmpl->getId, $session->setting->get('twitterTemplateIdChooseUsername'), "Template taken from settings" );

$session->setting->set( 'twitterConsumerKey' => '3hvJpBr73pa4FycNrqw' );
$session->setting->set( 'twitterConsumerSecret' => 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A' );
my $nt      = $auth->getTwitter;
isa_ok( $nt, 'Net::Twitter' );

#----------------------------------------------------------------------------
# www_ methods

# www_login
is( $auth->www_login, "redirect", "www_login always returns redirect" );
ok( $session->scratch->get('AuthTwitterToken'), 'auth token gets set to scratch' );
ok( $session->scratch->get('AuthTwitterTokenSecret'), 'auth token secret gets set to scratch' );
like( $session->http->getRedirectLocation, qr/twitter[.]com/, "redirect to twitter.com" );

# www_callback
# I have no idea how to test this...

# www_setUsername

ok( !$auth->www_setUsername, "setUsername doesn't work unless a scratch is set" );

$session->scratch->set( 'AuthTwitterUserId' => '2345' );
$session->request->setup_body( {
    newUsername     => "RedHerring",
} );
$auth->www_setUsername;

# User gets created with given twitter user id
my $userId  = $session->db->quickScalar( 
                "SELECT userId FROM authentication WHERE authMethod=? AND fieldName=? AND fieldData=?",
                [ "Twitter", "twitterUserId", "2345" ],
            );
ok( $userId, 'user exists in authentication table' );
$user = WebGUI::User->new( $session, $userId );
is( $user->username, "RedHerring", "correct username is set" );
WebGUI::Test->addToCleanup( $user );

like( 
    $auth->www_setUsername, qr/username "RedHerring" is taken/, 
    "setUsername with existing username returns error",
);

#vim:ft=perl
