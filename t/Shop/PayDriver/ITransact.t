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

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Cart;
use WebGUI::Shop::Ship;
use WebGUI::Shop::Transaction;
use WebGUI::Shop::PayDriver::ITransact;
use JSON;
use HTML::Form;
use WebGUI::Shop::PayDriver::ITransact;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({userId => 3});


#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# figure out if the test can actually run

my $e;
my $ship = WebGUI::Shop::Ship->new($session);
my $cart = WebGUI::Shop::Cart->newBySession($session);
WebGUI::Test->addToCleanup($cart);
my $shipper = $ship->getShipper('defaultfreeshipping000');
my $address = $cart->getAddressBook->addAddress( {
    label     => 'red',
    firstName => 'Ellis Boyd', lastName => 'Redding',
    address1  => 'cell block #5',
    city      => 'Shawshank',      state     => 'MN',
    code      => '55555',          country   => 'United States of America',
    phoneNumber => '555.555.5555', email     => 'red@shawshank.gov',
} );
$cart->update({
    billingAddressId  => $address->getId,
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
WebGUI::Test->addToCleanup($versionTag);
$rockHammer = $rockHammer->cloneFromDb;

my $ship = WebGUI::Shop::Ship->new($session);
my $cart = WebGUI::Shop::Cart->newBySession($session);
WebGUI::Test->addToCleanup($cart);
my $shipper = $ship->getShipper('defaultfreeshipping000');
my $address = $cart->getAddressBook->addAddress( { firstName => 'Ellis Boyd', lastName => 'Redding'} );
$cart->update({
    shippingAddressId => $address->getId,
    shipperId         => $shipper->getId,
});

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

$cart->update({gatewayId => $driver->getId,});
$transaction = WebGUI::Shop::Transaction->new($session, {
    cart          => $cart,
    isRecurring   => $cart->requiresRecurringPayment,
});
WebGUI::Test->addToCleanup($transaction);

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
    skip "Skipping XML requests to ITransact due to lack of real userId and password", 2 unless $hasTestAccount;
    note 'doXmlrequest';
    my $response = eval { $driver->doXmlRequest($xml) };
    my $ok_response = isa_ok($response, 'HTTP::Response', 'returns a HTTP::Response object');
    SKIP: {
        skip "Skipping response check since we did not get a response", 1 unless $ok_response;
        ok( $response->is_success, '... was successful');
    }
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
}

done_testing;

#vim:ft=perl
