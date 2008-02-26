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
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 7;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Ship');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::Ship', $tests unless $loaded;

#######################################################################
#
# getDrivers
#
#######################################################################

my $drivers;

eval { $drivers = WebGUI::Shop::Ship->getDrivers(); };
like ($@, qr/getDrivers requires a session object/, 'getDrivers croaks without session');

$drivers = WebGUI::Shop::Ship->getDrivers($session);

cmp_deeply(
    $drivers,
    [ 'WebGUI::Shop::ShipDriver::FlatRate' ],
    'getDrivers: WebGUI only ships with 1 default shipping driver',
);

#######################################################################
#
# create
#
#######################################################################

eval { $drivers = WebGUI::Shop::Ship->create(); };
like ($@, qr/create requires a session object/, 'create croaks without session');

eval { $drivers = WebGUI::Shop::Ship->create($session); };
like ($@, qr/create requires the name of a class/, 'create croaks without a class');

eval { $drivers = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FreeShipping'); };
like ($@, qr/The requested class \S+ is not enabled in your WebGUI configuration file/, 'create croaks without a configured class');

eval { $drivers = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FlatRate'); };
like ($@, qr/You must pass a hashref of options to create a new ShipDriver object/, 'create croaks without options to build a object with');

eval { $drivers = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FlatRate', {}); };
like ($@, qr/You must pass a hashref of options to create a new ShipDriver object/, 'create croaks without options to build a object with');


#######################################################################
#
# new
#
#######################################################################

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from shipper');
}
