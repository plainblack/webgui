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

my $tests = 27;
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
my $e;

eval { $drivers = WebGUI::Shop::Ship->getDrivers(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'getDrivers takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'getDrivers: requires a session variable',
);


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
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'create: requires a session variable',
);

eval { $drivers = WebGUI::Shop::Ship->create($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create croaks without a class');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a class to create an object',
    ),
    'create croaks without a class',
);


eval { $drivers = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FreeShipping'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create croaks without a configured class');
cmp_deeply(
    $e,
    methods(
        error => 'The requested class is not enabled in your WebGUI configuration file',
        param => 'WebGUI::Shop::ShipDriver::FreeShipping',
    ),
    'create croaks without a configured class',
);

eval { $drivers = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FlatRate'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create croaks without options to build a object with');
cmp_deeply(
    $e,
    methods(
        error => 'You must pass a hashref of options to create a new ShipDriver object',
    ),
    'create croaks without options to build a object with',
);

eval { $drivers = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FlatRate', {}); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create croaks without options to build a object with');
cmp_deeply(
    $e,
    methods(
        error => 'You must pass a hashref of options to create a new ShipDriver object',
    ),
    'create croaks without options to build a object with',
);

my $driver = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FlatRate', { enabled=>1, label=>q{Jake's Jailbird Airmail}});
isa_ok($driver, 'WebGUI::Shop::ShipDriver::FlatRate', 'created a new, configured FlatRate driver');


#######################################################################
#
# new
#
#######################################################################

my $oldDriver;

eval { $oldDriver = WebGUI::Shop::Ship->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'new takes exception to not giving it a session object',
);

eval { $oldDriver = WebGUI::Shop::Ship->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a shipperId');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a shipperId',
    ),
    'new takes exception to not giving it a shipperId',
);

eval { $oldDriver = WebGUI::Shop::Ship->new($session, 'notEverAnId'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'new croaks unless the requested shipperId object exists in the db');
cmp_deeply(
    $e,
    methods(
        error => 'shipperId not found in db',
        id    => 'notEverAnId',
    ),
    'new croaks unless the requested shipperId object exists in the db',
);

my $driverCopy = WebGUI::Shop::Ship->new($session, $driver->shipperId);

is($driverCopy->getId,     $driver->getId,           'same id');
is($driverCopy->className, $driver->className,       'same className');
cmp_deeply($driverCopy->options,   $driver->options, 'same options');

#######################################################################
#
# getShippers
#
#######################################################################

my $shippers;
my $driver2 = WebGUI::Shop::Ship->create($session, 'WebGUI::Shop::ShipDriver::FlatRate', { enabled=>1, label=>q{Tommy's cut-rate shipping}});

eval { $shippers = WebGUI::Shop::Ship->getShippers(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'getShippers takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'getShippers takes exception to not giving it a session object',
);


$shippers = WebGUI::Shop::Ship->getShippers($session);
is(scalar @{$shippers}, 2, 'getShippers: got both shippers');

my @shipperNames = map { $_->options()->{label} } @{ $shippers };
cmp_bag(
    \@shipperNames,
    [q{Jake's Jailbird Airmail},q{Tommy's cut-rate shipping}],
    'Returned shippers have the right data'
);

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from shipper');
}
