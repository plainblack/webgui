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

my $tests = 25;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Pay');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::Pay', $tests unless $loaded;

#######################################################################
#
# new
#
#######################################################################

my $e;
my $pay;

eval { $pay = WebGUI::Shop::Pay->new(); };
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

$pay = WebGUI::Shop::Pay->new($session);
isa_ok($pay, 'WebGUI::Shop::Pay', 'new returned the right kind of object');

#######################################################################
#
# session
#
#######################################################################

isa_ok($pay->session, 'WebGUI::Session', 'session method returns a session object');
is($session->getId, $pay->session->getId, 'session method returns OUR session object');



#######################################################################
#
# addPaymentGateway
#
#######################################################################

my $gateway;

eval { $gateway = $pay->addPaymentGateway(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addPaymentGateway croaks without a class');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a class to create an object',
    ),
    'addPaymentGateway croaks without a class',
);

eval { $gateway = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::NoSuchDriver'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addPaymentGateway croaks without a configured class');
cmp_deeply(
    $e,
    methods(
        error => 'The requested class is not enabled in your WebGUI configuration file',
        param => 'WebGUI::Shop::PayDriver::NoSuchDriver',
    ),
    'addPaymentGateway croaks without a configured class',
);

eval { $gateway = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addPaymentGateway croaks without options to build a object with');
cmp_deeply(
    $e,
    methods(
        error => 'You must pass a hashref of options to create a new PayDriver object',
    ),
    'addPaymentGateway croaks without options to build a object with',
);

eval { $gateway = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', {}); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'addPaymentGateway croaks without options to build a object with');
cmp_deeply(
    $e,
    methods(
        error => 'You must pass a hashref of options to create a new PayDriver object',
    ),
    'addPaymentGateway croaks without options to build a object with',
);

my $options = {
    enabled => 1,
    label   => 'Cold, stone hard cash',
};
my $newDriver = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', $options);
isa_ok($newDriver, 'WebGUI::Shop::PayDriver::Cash', 'added a new, configured Cash driver');

diag ('----> THE NEXT TEST IS SUPPOSED TO FAIL! REMOVE WHEN RESOLVED. <----');
isnt ($newDriver->label, 'TEMPORARY_LABEL', 'fail test until the addPaymentGateway interface is resolved.');

#TODO: check if options are stored.

#######################################################################
#
# getDrivers
#
#######################################################################

my $drivers = $pay->getDrivers();

my $defaultPayDrivers = {
    'WebGUI::Shop::PayDriver::Cash'     => 'Cash',
};

cmp_deeply(
    $drivers,
    $defaultPayDrivers,
    'getDrivers returns the default PayDrivers',
);

#######################################################################
#
# getOptions
#
#######################################################################

eval { $drivers = $pay->getOptions(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'getOptions takes exception to not giving it a cart');
cmp_deeply(
    $e,
    methods(
        error => 'Need a cart.',
    ),
    'getOptions takes exception to not giving it a cart',
);

#######################################################################
#
# getPaymentGateway
#
#######################################################################

eval { $gateway = $pay->getPaymentGateway(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'getPaymentDriver throws an exception when no paymentGatewayId is passed');
cmp_deeply(
    $e,
    methods(
        error   => q{Must provide a paymentGatewayId},
    ),
    'getPaymentGateway throws exception without paymentGatewayId',
);

eval { $gateway = $pay->getPaymentGateway('NoSuchThing'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'getPaymentGateway thows exception when a non-existant paymentGatewayId is passed');
cmp_deeply(
    $e,
    methods(
        error   => q{payment gateway not found in db},
        id      => 'NoSuchThing',
    ),
    'getPaymentGateway throws exception when called with a non-existant paymentGatewayId',
);

$gateway = $pay->getPaymentGateway( $newDriver->getId );
isa_ok($gateway, 'WebGUI::Shop::PayDriver::Cash', 'returned payment gateway has correct class');
is($gateway->getId, $newDriver->getId, 'getPaymentGateway instantiated the requested driver');

#######################################################################
#
# getPaymentGateways
#
#######################################################################

# Create an extra driver for testing purposes
my $otherOptions = {
    enabled     => 1,
    label       => 'Even harder cash',
};
my $anotherDriver = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', $otherOptions);

my $gateways = $pay->getPaymentGateways;
my @returnedIds = map {$_->getId} @{ $gateways };
cmp_bag(
    \@returnedIds,
    [ 
        $newDriver->getId,
        $anotherDriver->getId,
    ],
    'getPaymentGateways returns all create payment drivers',
);

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


}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from paymentGateway');
}
