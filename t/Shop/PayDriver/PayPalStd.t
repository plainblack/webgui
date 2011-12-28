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

# Write a little about what this script tests.
# 
#

use strict;
use Test::More;
use Test::Deep;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::PayDriver::PayPal::PayPalStd;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 3;

#----------------------------------------------------------------------------
# figure out if the test can actually run

my $e;

#######################################################################
#
# getName
#
#######################################################################
my $driver;
my $options = {
    label           => 'PayPal',
    enabled         => 1,
    groupToUse      => 3,
};

$driver = WebGUI::Shop::PayDriver::PayPal::PayPalStd->new( $session, $options );
WebGUI::Test->addToCleanup($driver);

isa_ok  ($driver, 'WebGUI::Shop::PayDriver');
isa_ok  ($driver, 'WebGUI::Shop::PayDriver::PayPal::PayPalStd');

is($driver->getName($session), 'PayPal', 'getName returns the human readable name of this driver');

#vim:ft=perl
