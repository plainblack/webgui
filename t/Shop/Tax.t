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

my $tests = 10;
plan tests => $tests + 1;       # Add initial use_ok test


#----------------------------------------------------------------------------
my $loaded = use_ok('WebGUI::Shop::Tax');

SKIP: {

    skip 'Unable to load module WebGUI::Shop::Tax', $tests unless $loaded;

    #######################################################################
    #
    # new 
    #
    #######################################################################

    eval { my $tax = WebGUI::Shop::Tax->new( ) };

    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new: throws error when no session object is passed' );
    is( $e->error, 'Need a session.', 'add: correct message for ommitted session object' );

    my $tax = WebGUI::Shop::Tax->new( $session );

    isa_ok( $tax, 'WebGUI::Shop::Tax', 'constructor returns instance of WebGUI::Shop::Tax' );

    #######################################################################
    #
    # session
    #
    #######################################################################

    isa_ok( $tax->session, 'WebGUI::Session', 'session method returns a session object');

    is( $session->getId, $tax->session->getId, 'session method returns OUR session object');

    #######################################################################
    #
    # calculate 
    #
    #######################################################################

    # TODO: Figure out how to test this.

    #######################################################################
    #
    # getDriver
    #
    #######################################################################

    # Try to get a non-existing plugin
    $session->setting->set( 'activeTaxPlugin', 'WebGUI::Shop::TaxDriver::HairgreaseTaxDeduction' );

    my $driver = $tax->getDriver;
    is( $driver, undef, 'getDriver returns undef when the driver cannot be loaded' );

    # Try to get an existing plugin
    $session->setting->set( 'activeTaxPlugin', 'WebGUI::Shop::TaxDriver::Generic' );
    $driver = $tax->getDriver;
    isa_ok( $driver, 'WebGUI::Shop::TaxDriver::Generic', 'getDriver returns correct plugin' );

    $driver = WebGUI::Shop::Tax->getDriver( $session );
    isa_ok( $driver, 'WebGUI::Shop::TaxDriver::Generic', 'getDriver returns correct plugin when called as class method' );

    eval { my $tax = WebGUI::Shop::Tax->getDriver() };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'getDriver throws error when no session object is passed in class context' );
    is( $e->error, 'Need a session.', 'getDriver passes correct message for ommitted session object' );

    TODO: {
        local $TODO = 'test www_ methods';
        #######################################################################
        #
        # www_do 
        #
        #######################################################################

        #######################################################################
        # 
        # www_manage 
        #
        #######################################################################

        #######################################################################
        #
        # www_setActivePlugin 
        #
        #######################################################################

        #######################################################################
        # 
        # www_setActivePluginConfirm 
        #
        #######################################################################
    }
}

#vim:ft=perl
