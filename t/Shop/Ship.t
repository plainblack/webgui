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
use Test::Deep;
use Test::Exception;
use JSON;
use HTML::Form;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Cart;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Ship');

my $storage;
my $driver;
my $driver2;
my $ship;

#######################################################################
#
# new
#
#######################################################################

dies_ok { $ship = WebGUI::Shop::Ship->new(); } 'new takes an exception to not giving it a session variable';

lives_ok { $ship = WebGUI::Shop::Ship->new(session => $session); } 'new takes hash arguments';
lives_ok { $ship = WebGUI::Shop::Ship->new($session); } 'new takes a bare session object';
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
cmp_bag(
    \@driverClasses,
    [
        'WebGUI::Shop::ShipDriver::FlatRate',
        'WebGUI::Shop::ShipDriver::USPS',
        'WebGUI::Shop::ShipDriver::USPSInternational',
        'WebGUI::Shop::ShipDriver::UPS',
    ],
    'getDrivers: All default shipping drivers present',
);

#######################################################################
#
# addShipper
#
#######################################################################

my $shipper;

my $e;

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

$driver = $ship->addShipper('WebGUI::Shop::ShipDriver::FlatRate', { enabled=>1, label=>q{Jake's Jailbird Airmail}, groupToUse=>7});
isa_ok($driver, 'WebGUI::Shop::ShipDriver::FlatRate', 'added a new, configured FlatRate driver');

#######################################################################
#
# getShippers
#
#######################################################################

my $shippers;
$driver2 = $ship->addShipper('WebGUI::Shop::ShipDriver::FlatRate', { enabled=>0, label=>q{Tommy's cut-rate shipping}, groupToUse=>7});

$shippers = $ship->getShippers();

is(scalar @{$shippers}, 3, 'getShippers: got both shippers, even though one is not enabled');

my @shipperNames = map { $_->get("label") } @{ $shippers };
cmp_bag(
    \@shipperNames,
    [q{Jake's Jailbird Airmail},q{Tommy's cut-rate shipping},q{Free Shipping}, ],
    'Returned shippers have the right data'
);

#######################################################################
#
# getOptions
#
#######################################################################

my $defaultDriver = WebGUI::Shop::ShipDriver->new($session, 'defaultfreeshipping000');

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

my $cart = WebGUI::Shop::Cart->create($session);
eval { $shippers = $ship->getOptions($cart) };
$e = Exception::Class->caught();
ok(!$e, 'No exception thrown for getOptions with a cart argument');

cmp_deeply(
    $shippers,
    {
        $defaultDriver->getId => {
            label => $defaultDriver->get('label'),
            price => ignore(),
        },
        $driver->getId => {
            label => $driver->get('label'),
            price => ignore(),
        },
    },
    'getOptions returns the two enabled shipping drivers'
);

$cart->delete;

done_testing();

#----------------------------------------------------------------------------
# Cleanup
END {
    $driver->delete;
    $driver2->delete;
}
