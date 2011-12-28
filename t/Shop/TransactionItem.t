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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Test::Exception;
use Test::MockObject::Extends;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Cart;
use WebGUI::Shop::Ship;
use WebGUI::Shop::Transaction;
use WebGUI::Shop::PayDriver::ITransact;
use JSON;
use HTML::Form;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({userId => 3});


#----------------------------------------------------------------------------
# Tests

plan tests => 8;

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
$rockHammer = $rockHammer->cloneFromDb;
$cart->update({gatewayId => 'gzUxkEZJxREF9JpylOg2zw',}); ##Cash checkout
my $transaction = WebGUI::Shop::Transaction->new($session, {
    cart          => $cart,
    isRecurring   => $cart->requiresRecurringPayment,
});
##Block sending emails and inbox messages on this transation
$transaction = Test::MockObject::Extends->new($transaction);
$transaction->set_true('sendNotifications');

WebGUI::Test->addToCleanup($versionTag, $transaction);

my $credit = WebGUI::Shop::Credit->new($session, '3');
WebGUI::Test->addToCleanup(sub { $credit->purge });

my $hammer2 = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $foreignHammer));
my $transactionItem = $transaction->addItem({ item => $hammer2 });

$transaction->update({isSuccessful => 1});

$transactionItem->update({orderStatus => 'Cancelled'});
$transactionItem->issueCredit;
is $credit->getSum, '0.00', 'issueCredit fails if the item is Cancelled';

$transactionItem->update({orderStatus => 'Shipped'});
$transactionItem->issueCredit;
is $credit->getSum, '7.00', '... succeeds if the item is not Cancelled';
is $transactionItem->get('orderStatus'), 'Cancelled', '... item status updated to Cancelled';

$transaction->update({isSuccessful => 0});
$transactionItem->update({orderStatus => 'Not Shipped'});
$transactionItem->issueCredit;
is $credit->getSum, '7.00', 'issueCredit is unchanged when the transaction is not successful';
is $transactionItem->get('orderStatus'), 'Not Shipped', '... item status unchanged';

$transaction->update({isSuccessful => 1});

$transactionItem->update({orderStatus => 'Shipped'});
$rockHammer->purge;
lives_ok { $transactionItem->issueCredit } 'issueCredit does not die if the asset does not exist';
is $credit->getSum, '14.00', '... credit is still issued';
is $transactionItem->get('orderStatus'), 'Cancelled', '... item status still updated';

#vim:ft=perl
