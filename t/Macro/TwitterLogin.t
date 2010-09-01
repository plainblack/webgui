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

# Test the TwitterLogin macro
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 10;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# TwitterLogin macro

use_ok( 'WebGUI::Macro::TwitterLogin' );

# Twitter auth must be enabled
my $authMethods = $session->config->get('authMethods');
$session->config->set('authMethods', ["WebGUI","LDAP"]);
is( WebGUI::Macro::TwitterLogin::process($session), "", "Twitter must be enabled in config" );
$session->config->set('authMethods', [ @{$authMethods}, "Twitter" ]);

$session->user({userId => 3});
is( WebGUI::Macro::TwitterLogin::process($session), "", "User must be Visitor" );
$session->user({userId => 1});

my $twitterEnabled  = $session->setting->get('twitterEnabled');
$session->setting->set('twitterEnabled', 0 );
is( WebGUI::Macro::TwitterLogin::process( $session ), "", "Twitter Auth must be enabled in settings" );
$session->setting->set('twitterEnabled', 1 );

# Default twitter login image
my $output  = WebGUI::Macro::TwitterLogin::process( $session );
like( $output, qr/<a href/, "macro contains link" );
like( $output, qr/op=auth/, "link to auth" );
like( $output, qr/authType=Twitter/, "contains authType specifically" );
like( $output, qr/twitter_login[.]png/, "contains default twitter login image" );

# Custom twitter login image
my $output  = WebGUI::Macro::TwitterLogin::process( $session, "custom_image.png" );
unlike( $output, qr/twitter_login[.]png/, "doesn't contain default twitter login image" );
like( $output, qr/custom_image[.]png/, "contains custom login image" );

$session->setting->set('twitterEnabled', $twitterEnabled );
$session->config->set( 'authMethods', $authMethods );

#vim:ft=perl
