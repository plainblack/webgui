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
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 3;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# figure out if the test can actually run

my $e;

my $loaded = use_ok('WebGUI::Shop::PayDriver::PayPal::PayPalStd');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::PayDriver::PayPal::PayPalStd', $tests unless $loaded;

#######################################################################
#
# getName
#
#######################################################################
my $driver;
my $options = {
    label           => 'PayPal',
    enabled         => 1,
    group           => 3,
    receiptMessage  => 'Pannenkoeken zijn nog lekkerder met spek',
};

$driver = WebGUI::Shop::PayDriver::PayPal::PayPalStd->create( $session, $options );

isa_ok  ($driver, 'WebGUI::Shop::PayDriver');
isa_ok  ($driver, 'WebGUI::Shop::PayDriver::PayPal::PayPalStd');

is($driver->getName($session), 'PayPal', 'getName returns the human readable name of this driver');

#######################################################################
#
# delete
#
#######################################################################

$driver->delete;

undef $driver;

}

#----------------------------------------------------------------------------
# Cleanup
END {
}
