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

# This tests the operation of Authentication
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Operation::Auth;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Test package for method dispatch
BEGIN { $INC{'WebGUI/Auth/TestAuth.pm'} = __FILE__; }

package WebGUI::Auth::TestAuth;

use base 'WebGUI::Auth';

sub new {
    my $self    = shift->SUPER::new(@_);
    $self->setCallable( ['callable'] );
    return bless $self, 'WebGUI::Auth::TestAuth'; # Auth requires rebless
}

sub callable {
    return "callable";
}

sub not_callable {
    return "not callable";
}

sub www_verify {
    return "verify";
}

package main;

#----------------------------------------------------------------------------
# Tests

plan tests => 10;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test the getInstance method
# By default, it returns a WebGUI::Auth::WebGUI object
my $auth = WebGUI::Operation::Auth::getInstance( $session );
ok($auth, 'getInstance returned something');
isa_ok($auth, 'WebGUI::Auth::' . $session->setting->get('authMethod') );

# Test setting authType by form var
$session->request->setup_body({
    authType        => 'TestAuth',
});
isa_ok( 
    WebGUI::Operation::Auth::getInstance( $session ),
    'WebGUI::Auth::' . $session->setting->get('authMethod'),
    'AuthType not in config file, so return default authType',
);

WebGUI::Test->originalConfig( 'authMethods' );
$session->config->addToArray( 'authMethods', 'TestAuth' );
isa_ok( 
    WebGUI::Operation::Auth::getInstance( $session ),
    'WebGUI::Auth::TestAuth',
    'AuthType in config file, so return instance of authType',
);

$session->user({ userId => 3 });
isa_ok(
    WebGUI::Operation::Auth::getInstance( $session ),
    'WebGUI::Auth::WebGUI',
    'AuthType is defined by the logged-in user, despite being in request',
);

#----------------------------------------------------------------------------
# Test the web method for auth operation
# First a clean session, without an authenticated user
$session->user({ userId => 1 });
$session->request->setup_body({});

my $output = WebGUI::Operation::Auth::www_auth($session);
like(
    $output,
    qr/<input type="hidden" name="method" value="login" /, 
    "Hidden form elements for login displayed",
);

# Become admin and test web method
$session->user({userId => 3});
$output = WebGUI::Operation::Auth::www_auth($session);
unlike(
    $output,
    qr/<input type="hidden" name="method" value="login" /, 
    "Hidden form elements for login NOT displayed to valid user",
);

# Go back to visitor and test callable dispatch
$session->user({ userId => 1 });
$session->request->setup_body({
    authType        => 'TestAuth',
    method          => 'callable',
});
eval { $output = WebGUI::Operation::Auth::www_auth( $session ); };
like( $output, qr{\bcallable\b}, 'Callable method is callable' );

# Test a method not in callable
$session->user({ userId => 1 });
$session->request->setup_body({
    authType        => 'TestAuth',
    method          => 'not_callable',
});
my $i18n = WebGUI::International->new($session);
my $error = $i18n->get(1077);
eval { $output = WebGUI::Operation::Auth::www_auth( $session ); };
like( $output, qr{$error}, 'not_callable method gives error message' );

# Test www_ dispatch
$session->user({ userId => 1 });
$session->request->setup_body({
    authType        => 'TestAuth',
    method          => 'verify',
});
eval { $output = WebGUI::Operation::Auth::www_auth( $session ); };
like( $output, qr{verify}, 'www_ callable without being setCallable' );

