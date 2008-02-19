# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 3;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::ShipDriver');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::ShipDriver', $tests unless $loaded;

#######################################################################
#
# new
#
#######################################################################

my $driver = WebGUI::Shop::ShipDriver->new($session);

isa_ok($driver, 'WebGUI::Shop::ShipDriver');

isa_ok($driver->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $driver->session->getId, 'session method returns OUR session object');

#######################################################################
#
# definition
#
#######################################################################

#######################################################################
#
# getName
#
#######################################################################

#######################################################################
#
# getEditForm
#
#######################################################################

#######################################################################
#
# calculate
#
#######################################################################

}

#----------------------------------------------------------------------------
# Cleanup
END {
}
