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
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Cart;
use WebGUI::Shop::Ship;
use WebGUI::Shop::Transaction;
use JSON;
use HTML::Form;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $tests = 28;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# figure out if the test can actually run

note('Testing existence');
my $loaded = use_ok('WebGUI::Shop::PayDriver::ITransact');

my $e;
my $ship = WebGUI::Shop::Ship->new($session);
my $cart = WebGUI::Shop::Cart->newBySession($session);
my $shipper = $ship->getShipper('defaultfreeshipping000');
my $address = $cart->getAddressBook->addAddress( { firstName => 'Ellis Boyd', lastName => 'Redding'} );
$cart->update({
    shippingAddressId => $address->getId,
    shipperId         => $shipper->getId,
});
my $transaction;

my $versionTag = WebGUI::VersionTag->getWorking($session);

my $home = WebGUI::Asset->getDefault($session);

my $rockHammer = $home->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    isShippingRequired => 0,     title => 'Rock Hammers',
    shipsSeparately    => 0,
});

my $smallHammer = $rockHammer->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Small rock hammer', price     => 7.50,
        varSku    => 'small-hammer',      weight    => 1.5,
        quantity  => 9999,
    }
);

my $foreignHammer = $rockHammer->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => '錘',                price     => 7.00,
        varSku    => 'foreigh-hammer',    weight    => 1.0,
        quantity  => 9999,
    }
);


$versionTag->commit;
WebGUI::Test->tagsToRollback($versionTag);

my $hammerItem = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));

SKIP: {

skip 'Unable to load module WebGUI::Shop::PayDriver::ITransact', $tests unless $loaded;

#######################################################################
#
# definition
#
#######################################################################

note('Testing definition');
my $definition;

eval { $definition = WebGUI::Shop::PayDriver::ITransact->definition(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'definition takes an exception to not giving it a session variable');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'definition: requires a session variable',
);

#######################################################################
#
# create
#
#######################################################################

my $driver;

# Test incorrect for parameters

eval { $driver = WebGUI::Shop::PayDriver::ITransact->create(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it a session object');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'create takes exception to not giving it a session object',
);

eval { $driver = WebGUI::Shop::PayDriver::ITransact->create($session,  {}); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'create takes exception to giving it an empty hashref of options');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a hashref of options',
    ),
    'create takes exception to not giving it an empty hashref of options',
);

my $vendorId = $session->config->get("testing/ITransact/vendorId");
my $password = $session->config->get("testing/ITransact/password");
my $hasTestAccount = $vendorId && $password;

if (!$vendorId) {
    $vendorId = "joeUser";
}
if (!$password) {
    $password = "joePass";
}

my $options = {
    label           => 'Fast and harmless',
    enabled         => 1,
    groupToUse      => 3,
    vendorId        => $vendorId,
    password        => $password,
    useCVV2         => 1,
};

$driver = WebGUI::Shop::PayDriver::ITransact->create( $session, $options );

isa_ok  ($driver, 'WebGUI::Shop::PayDriver::ITransact', 'create creates WebGUI::Shop::PayDriver object');
like($driver->getId, $session->id->getValidator, 'driver id is a valid GUID');

#######################################################################
#
# session
#
#######################################################################

isa_ok      ($driver->session,  'WebGUI::Session',          'session method returns a session object');
is          ($session->getId,   $driver->session->getId,    'session method returns OUR session object');

#######################################################################
#
# paymentGatewayId, getId
#
#######################################################################

like        ($driver->paymentGatewayId, $session->id->getValidator, 'got a valid GUID for paymentGatewayId');
is          ($driver->getId,            $driver->paymentGatewayId,  'getId returns the same thing as paymentGatewayId');

#######################################################################
#
# className
#
#######################################################################

is          ($driver->className, ref $driver, 'className property set correctly');

#######################################################################
#
# options
#
#######################################################################

cmp_deeply(
    $driver->options,
    superhashof( $options ),
    'options accessor works'
);

#######################################################################
#
# getName
#
#######################################################################

eval { WebGUI::Shop::PayDriver::ITransact->getName(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'getName requires a session object passed to it');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'getName requires a session object passed to it',
);

is(WebGUI::Shop::PayDriver::ITransact->getName($session), 'Credit Card (ITransact)', 'getName returns the human readable name of this driver');

#######################################################################
#
# get
#
#######################################################################

cmp_deeply  ($driver->get,              $driver->options,       'get works like the options method with no param passed');
is          ($driver->get('enabled'),   1,                      'get the enabled entry from the options');
is          ($driver->get('label'),     'Fast and harmless',    'get the label entry from the options');

my $optionsCopy = $driver->get;
$optionsCopy->{label} = 'And now for something completely different';
isnt(
    $driver->get('label'),
    'And now for something completely different',
    'hashref returned by get() is a copy of the internal hashref'
);

#######################################################################
#
# _generatePaymentRequestXML
#
#######################################################################

my $dt = WebGUI::DateTime->new($session, time());
$dt->add({ years => 1, });

##Make a fake card that never expires
$driver->{_cardData} = {
    acct     => '5454545454545454',
    expMonth => $dt->strftime("%m"),
    expYear  => $dt->year,
    cvv2     => '1234',
};

$driver->{_billingAddress} = {
    firstName   => 'Ellis Boyd',
    lastName    => 'Redding',
    address1    => '#2 Row 30265',
    city        => 'Shawshank',
    state       => 'Maine',
    code        => '97025',
    country     => 'USA',
    phoneNumber => '555.555.5555',
    email       => '30265@shawshank.gov',
};


$transaction = WebGUI::Shop::Transaction->create($session, {
    paymentMethod => $driver,
    cart          => $cart,
    isRecurring   => $cart->requiresRecurringPayment,
});

my $xml = $driver->_generatePaymentRequestXML($transaction);

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'Validate components of the XML');
}

#######################################################################
#
# doXmlRequest
#
#######################################################################

SKIP: {
    skip "Skipping XML requests to ITransact due to lack of userId and password", 2 unless $hasTestAccount;
    my $response = eval { $driver->doXmlRequest($xml) };
    note 'doXmlrequest';
    isa_ok($response, 'HTTP::Response', 'returns a HTTP::Response object');
    ok( $response->is_success, '... was successful');
}

my $hammer2 = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $foreignHammer));
$transaction->addItem({ item => $hammer2 });
my $xml = $driver->_generatePaymentRequestXML($transaction);

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'Validate components of the XML with two items in cart');
}

SKIP: {
    skip "Skipping XML requests to ITransact due to lack of userId and password", 2 unless $hasTestAccount;
    my $response = eval { $driver->doXmlRequest($xml) };
    isa_ok($response, 'HTTP::Response', 'returns a HTTP::Response object');
    ok( $response->is_success, '... was successful');
    note $response->content;
}

#######################################################################
#
# delete
#
#######################################################################

$driver->delete;

my $count = $session->db->quickScalar('select count(*) from paymentGateway where paymentGatewayId=?', [
    $driver->paymentGatewayId
]);

is ($count, 0, 'delete deleted the object');

undef $driver;

#----------------------------------------------------------------------------
# Cleanup

}

END: {
    $cart->delete;
    $transaction->delete if defined $transaction;
}
#vim:ft=perl
