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

# Write a little about what this script tests.
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Auth;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my @cleanupUsernames    = ();   # Will be cleaned up when we're done
my $auth;   # will be used to create auth instances
my ($request, $oldRequest, $output);

#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test createAccountSave and returnUrl together
# Set up request
my $createAccountSession = WebGUI::Test->newSession(0, {
    returnUrl       => 'REDIRECT_URL',
});

$auth           = WebGUI::Auth->new( $createAccountSession );
my $username    = $createAccountSession->id->generate;
push @cleanupUsernames, $username;
$output         = $auth->createAccountSave( $username, { }, "PASSWORD" ); 
WebGUI::Test->addToCleanup(sub {
    for my $username ( @cleanupUsernames ) {
        # We don't create actual, real users, so we have to cleanup by hand
        my $userId  = $session->db->quickScalar(
            "SELECT userId FROM users WHERE username=?",
            [ $username ]
        );
        
        my @tableList
            = qw{authentication users userProfileData groupings inbox userLoginLog};

        for my $table ( @tableList ) {
            $session->db->write(
                "DELETE FROM $table WHERE userId=?",
                [ $userId ]
            );
        }
    }
});

is(
    $createAccountSession->http->getRedirectLocation, 'REDIRECT_URL',
    "returnUrl field is used to set redirect after createAccountSave",
);

#----------------------------------------------------------------------------
# Test login and returnUrl together
# Set up request

my $loginSession = WebGUI::Test->newSession(0, {
    returnUrl       => 'REDIRECT_LOGIN_URL',
});

$auth           = WebGUI::Auth->new( $loginSession, 3 );
my $username    = $loginSession->id->generate;
push @cleanupUsernames, $username;
$session->setting->set('showMessageOnLogin', 0);
$output         = $auth->login;

is(
    $loginSession->http->getRedirectLocation, 'REDIRECT_LOGIN_URL',
    "returnUrl field is used to set redirect after login",
);
is $output, undef, 'login returns undef when showMessageOnLogin is false';

