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

# Make sure the Wizard content handler does its job correctly
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

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# 

use_ok( 'WebGUI::Content::Wizard' );

ok( !WebGUI::Content::Wizard::handler( $session ), "Declines correctly" );

$session->request->setup_body( {
    op              => 'wizard',
    wizard_class    => 'WebGUI::Wizard::HelloWorld',
} );
is( WebGUI::Content::Wizard::handler( $session ), "Hello World!\n", "Accepts request and returns response" );

package WebGUI::Wizard::HelloWorld;

use base "WebGUI::Wizard";

sub _get_steps { return ["hello"] }
sub www_hello { return "Hello World!\n" }
sub wrapStyle { return $_[1] }

#vim:ft=perl
