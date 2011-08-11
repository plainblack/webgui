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
#use Test::Exception;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::TestException;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 18;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Pay');

my $storage;
my $newDriver;
my $anotherDriver;

#######################################################################
#
# new
#
#######################################################################

my $e;
my $pay;


throws_deeply ( sub { $pay = WebGUI::Shop::Pay->new(); }, 
    'WebGUI::Error::InvalidObject', 
    {
        error       => 'Must provide a session variable',
        got         => '',
        expected    => 'WebGUI::Session',
    },
    'new takes an exception to not giving it a session variable'
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

throws_deeply ( sub { $gateway = $pay->addPaymentGateway(); },
    'WebGUI::Error::InvalidParam',
    { 
        error => 'Must provide a class to create an object' 
    },
    'addPaymentGateway croaks without a class',
);

throws_deeply ( sub { $gateway = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::NoSuchDriver'); },
    'WebGUI::Error::InvalidParam',
    {
        error => 'The requested class is not enabled in your WebGUI configuration file',
        param => 'WebGUI::Shop::PayDriver::NoSuchDriver',
    },
    'addPaymentGateway croaks without a configured class',
);

throws_deeply ( sub { $gateway = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', 'JAL'); },
    'WebGUI::Error::InvalidParam', 
    {
        error => 'You must pass a hashref of options to create a new PayDriver object',
    },
    'addPaymentGateway croaks without options to build a object with',
);

throws_deeply ( sub { $gateway = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', {}); },
    'WebGUI::Error::InvalidParam',
    {
        error => 'You must pass a hashref of options to create a new PayDriver object',
    },
    'addPaymentGateway croaks without options to build a object with',
);

my $options = {
    enabled => 1,
    label   => 'Cold, stone hard cash',
};
$newDriver = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', $options);
WebGUI::Test->addToCleanup($newDriver);
isa_ok($newDriver, 'WebGUI::Shop::PayDriver::Cash', 'added a new, configured Cash driver');
is($newDriver->get('label'), 'Cold, stone hard cash', 'label passed correctly to paydriver');


#TODO: check if options are stored.


#######################################################################
#
# getDrivers
#
#######################################################################

my $drivers = $pay->getDrivers();

my $defaultPayDrivers = {
    'WebGUI::Shop::PayDriver::Cash'          => 'Cash',
    'WebGUI::Shop::PayDriver::ITransact'     => 'Credit Card (ITransact)',
    'WebGUI::Shop::PayDriver::Ogone'         => 'Ogone',
    'WebGUI::Shop::PayDriver::PayPal::PayPalStd'       => 'PayPal',
    'WebGUI::Shop::PayDriver::PayPal::ExpressCheckout' => 'PayPal Express Checkout',
    'WebGUI::Shop::PayDriver::CreditCard::AuthorizeNet' => 'Credit Card (Authorize.net)',
};

cmp_deeply( $drivers, $defaultPayDrivers, 'getDrivers returns the default PayDrivers');

#######################################################################
#
# getOptions
#
#######################################################################

throws_deeply( sub { $drivers = $pay->getOptions(); },
    'WebGUI::Error::InvalidParam',
    {
        error => 'Need a cart.',
    },
    'getOptions takes exception to not giving it a cart',
);

#TODO: Check th crap getOptions returns

#######################################################################
#
# getPaymentGateway
#
#######################################################################

throws_deeply( sub { $gateway = $pay->getPaymentGateway(); },
    'WebGUI::Error::InvalidParam',
    {
        error   => q{Must provide a paymentGatewayId},
    },
    'getPaymentGateway throws exception without paymentGatewayId',
);

throws_deeply( sub { $gateway = $pay->getPaymentGateway('NoSuchThing'); },
    'WebGUI::Error::ObjectNotFound',
    {   
        error   => q{payment gateway not found in db},
        id      => 'NoSuchThing',
    },
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
$anotherDriver = $pay->addPaymentGateway('WebGUI::Shop::PayDriver::Cash', $otherOptions);
WebGUI::Test->addToCleanup($anotherDriver);

my $gateways = $pay->getPaymentGateways;
my @returnedIds = map {$_->get('label')} @{ $gateways };
cmp_bag(
    \@returnedIds,
    [ 
        qw/Cash ITransact/, 'Even harder cash', 'Cold, stone hard cash',
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

