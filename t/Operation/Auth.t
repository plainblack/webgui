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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Operation::Auth;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test the getInstance method
# By default, it returns a WebGUI::Auth::WebGUI object
my $auth = WebGUI::Operation::Auth::getInstance( $session );
ok($auth, 'getInstance returned something');
isa_ok($auth, 'WebGUI::Auth::WebGUI');

# Test the web method for auth operation
# First a clean session, without an authenticated user
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

