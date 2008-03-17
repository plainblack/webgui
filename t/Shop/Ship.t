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

my $tests = 19;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Ship');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::Ship', $tests unless $loaded;

#######################################################################
#
# new
#
#######################################################################

my $e;
my $ship;

eval { $ship = WebGUI::Shop::Ship->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
        got   => '',
        expected => 'WebGUI::Session',
    ),
    'new: requires a session variable',
);

$ship = WebGUI::Shop::Ship->new($session);
isa_ok($ship, 'WebGUI::Shop::Ship', 'new returned the right kind of object');

isa_ok($ship->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $ship->session->getId, 'session method returns OUR session object');

#######################################################################
#
# getDrivers
#
#######################################################################

my $drivers;

$drivers = $ship->getDrivers();
my @driverClasses = keys %{$drivers};
cmp_deeply(
    \@driverClasses,
    [ 'WebGUI::Shop::ShipDriver::FlatRate' ],
    'getDrivers: WebGUI only ships with 1 default shipping driver',
);

#######################################################################
#
# addShipper
#
#######################################################################

my $shipper;

eval { $shipper = $ship->addShipper(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addShipper croaks without a class');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a class to create an object',
    ),
    'addShipper croaks without a class',
);

eval { $shipper = $ship->addShipper('WebGUI::Shop::ShipDriver::FreeShipping'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addShipper croaks without a configured class');
cmp_deeply(
    $e,
    methods(
        error => 'The requested class is not enabled in your WebGUI configuration file',
        param => 'WebGUI::Shop::ShipDriver::FreeShipping',
    ),
    'addShipper croaks without a configured class',
);

eval { $shipper = $ship->addShipper('WebGUI::Shop::ShipDriver::FlatRate'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addShipper croaks without options to build a object with');
cmp_deeply(
    $e,
    methods(
        error => 'You must pass a hashref of options to create a new ShipDriver object',
    ),
    'addShipper croaks without options to build a object with',
);

eval { $shipper = $ship->addShipper('WebGUI::Shop::ShipDriver::FlatRate', {}); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addShipper croaks without options to build a object with');
cmp_deeply(
    $e,
    methods(
        error => 'You must pass a hashref of options to create a new ShipDriver object',
    ),
    'addShipper croaks without options to build a object with',
);

my $driver = $ship->addShipper('WebGUI::Shop::ShipDriver::FlatRate', { enabled=>1, label=>q{Jake's Jailbird Airmail}});
isa_ok($driver, 'WebGUI::Shop::ShipDriver::FlatRate', 'added a new, configured FlatRate driver');

#######################################################################
#
# getShippers
#
#######################################################################

my $shippers;
my $driver2 = $ship->addShipper('WebGUI::Shop::ShipDriver::FlatRate', { enabled=>1, label=>q{Tommy's cut-rate shipping}});

$shippers = $ship->getShippers();
is(scalar @{$shippers}, 2, 'getShippers: got both shippers');

my @shipperNames = map { $_->get("label") } @{ $shippers };
cmp_bag(
    \@shipperNames,
    [q{Jake's Jailbird Airmail},q{Tommy's cut-rate shipping}],
    'Returned shippers have the right data'
);

#######################################################################
#
# getOptions
#
#######################################################################

eval { $shippers = $ship->getOptions(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'getOptions takes exception to not giving it a cart');
cmp_deeply(
    $e,
    methods(
        error => 'Need a cart.',
    ),
    'getOptions takes exception to not giving it a cart',
);

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from shipper');
}
