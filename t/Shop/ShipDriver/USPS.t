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

use strict;
use Test::More;
use Test::Deep;
use XML::Simple;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::ShipDriver::USPS;

plan tests => 66;

#----------------------------------------------------------------------------
# Init
my $session   = WebGUI::Test->session;
my $user      = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($user);
$session->user({user => $user});

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# put your tests here


my ($driver2, $cart);
my $insuranceTable =  <<EOTABLE;
5:1.00
10:2.00
15:3.00
20:4.00
25:5.00
30:6.00
EOTABLE

my $home = WebGUI::Test->asset;

my $rockHammer = $home->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    isShippingRequired => 1,     title => 'Rock Hammers',
    shipsSeparately    => 0,
});

my $smallHammer = $rockHammer->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Small rock hammer', price     => 7.50,
        varSku    => 'small-hammer',      weight    => 1.5,
        quantity  => 9999,
    }
);

my $bigHammer = $rockHammer->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Big rock hammer', price     => 19.99,
        varSku    => 'big-hammer',      weight    => 12,
        quantity  => 9999,
    }
);

my $bible = $home->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    isShippingRequired => 1,     title => 'Bibles, individuall wrapped and shipped',
    shipsSeparately    => 1,
});

my $kjvBible = $bible->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'King James Bible',  price     => 17.50,
        varSku    => 'kjv-bible',         weight    => 2.5,
        quantity  => 99999,
    }
);

my $nivBible = $bible->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'NIV Bible',    price     => 22.50,
        varSku    => 'niv-bible',    weight    => 2.0,
        quantity  => 999999,
    }
);

my $gospels = $bible->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Gospels from the new Testament',
        price     => 1.50,       varSku    => 'gospels',
        weight    => 2.0,        quantity  => 999999,
    }
);

#######################################################################
#
# new
#
#######################################################################

my $options = {
                label   => 'USPS Driver',
                enabled => 1,
              };

$driver2 = WebGUI::Shop::ShipDriver::USPS->new($session, $options);
addToCleanup($driver2);

isa_ok($driver2, 'WebGUI::Shop::ShipDriver::USPS');
isa_ok($driver2, 'WebGUI::Shop::ShipDriver');

#######################################################################
#
# getName
#
#######################################################################

is (WebGUI::Shop::ShipDriver::USPS->getName($session), 'United States Postal Service', 'getName returns the human readable name of this driver');

#######################################################################
#
# delete
#
#######################################################################

my $driverId = $driver2->getId;
$driver2->delete;

my $count = $session->db->quickScalar('select count(*) from shipper where shipperId=?',[$driverId]);
is($count, 0, 'delete deleted the object');

undef $driver2;

#######################################################################
#
# calculate, and private methods.
#
#######################################################################

my $driver = WebGUI::Shop::ShipDriver::USPS->new($session, {
    label    => 'Shipping from Shawshank',
    enabled  => 1,
    shipType => 'PARCEL',
});
addToCleanup($driver);

my $e;
eval { $driver->calculate() };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'calculate throws an exception when no zipcode has been set');
cmp_deeply(
    $e,
    methods(
        error => 'Driver configured without a source zipcode.',
    ),
    '... checking error message',
);

my $properties = $driver->get();
$properties->{sourceZip} = '97123';
$driver->update($properties);

eval { $driver->calculate() };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'calculate throws an exception when no userId');
cmp_deeply(
    $e,
    methods(
        error => 'Driver configured without a USPS userId.',
    ),
    '... checking error message',
);

$cart = WebGUI::Shop::Cart->newBySession($session);
addToCleanup($cart);
my $addressBook = $cart->getAddressBook;
my $workAddress = $addressBook->addAddress({
    label => 'work',
    organization => 'Plain Black Corporation',
    address1 => '1360 Regent St. #145',
    city => 'Madison', state => 'WI', code => '53715',
    country => 'United States',
});
my $wucAddress = $addressBook->addAddress({
    label => 'wuc',
    organization => 'Madison Concourse Hotel',
    address1 => '1 W Dayton St',
    city => 'Madison', state => 'WI', code => '53703',
    country => 'United States',
});
my $zip4Address = $addressBook->addAddress({
    label => 'work-zip4',
    organization => 'Plain Black Corporation',
    address1 => '1360 Regent St. #145',
    city => 'Madison', state => 'WI', code => '53715-1255',
    country => 'United States',
});
$cart->update({shippingAddressId => $workAddress->getId});

cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [(), ],
    '_getShippableUnits: empty cart'
);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [[ ignore() ], ],
    '_getShippableUnits: one loose item in the cart'
);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $bigHammer));
cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [[ ignore(), ignore() ], ],
    '_getShippableUnits: two loose items in the cart'
);

$bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $kjvBible));
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [[ ignore(), ignore() ], [ ignore(), ], ],
    '_getShippableUnits: two loose items, and 1 ships separately item in the cart'
);

my $bibleItem = $bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
$bibleItem->setQuantity(5);
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [[ ignore(), ignore() ], [ ignore() ], [ ignore() ], ],
    '_getShippableUnits: two loose items, and 2 ships separately item in the cart, regarless of quantity for the new item'
);

my $rockHammer2 = $bible->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
$rockHammer2->update({shippingAddressId => $wucAddress->getId});
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [[ ignore(), ignore() ], [ ignore() ], [ ignore() ], [ ignore() ], ],
    '_getShippableUnits: two loose items, and 2 ships separately item in the cart, and another loose item sorted by zipcode'
);

$cart->empty;
$bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [ [ ignore() ], ],
    '_getShippableUnits: only 1 ships separately item in the cart'
);
$cart->empty;

my $userId = $session->config->get('testing/USPS_userId');
my $hasRealUserId = 1;
##If there isn't a userId, set a fake one for XML testing.
if (! $userId) {
    $hasRealUserId = 0;
    $userId = "blahBlahBlah";
}
$properties = $driver->get();
$properties->{userId}    = $userId;
$properties->{sourceZip} = '97123';
$driver->update($properties);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
my @shippableUnits = $driver->_getShippableUnits($cart);

$properties = $driver->get();
$properties->{addInsurance}   = 1;
$properties->{insuranceRates} = $insuranceTable;
$driver->update($properties);

is($driver->_calculateInsurance(@shippableUnits), 2, '_calculateInsurance: one item in cart with quantity=1, calculates insurance');

$properties->{addInsurance}   = 0;
$driver->update($properties);
is($driver->_calculateInsurance(@shippableUnits), 0, '_calculateInsurance: returns 0 if insurance is not enabled');

$properties->{addInsurance}   = 1;
$properties->{insuranceRates} = '';
$driver->update($properties);
is($driver->_calculateInsurance(@shippableUnits), 0, '_calculateInsurance: returns 0 if rates are not set');

my $xml = $driver->buildXML($cart, @shippableUnits);
like($xml, qr/<RateV3Request USERID="[^"]+"/, 'buildXML: checking userId is an attribute of the RateV3Request tag');
like($xml, qr/<Package ID="0"/, 'buildXML: checking ID is an attribute of the Package tag');

my $xmlData = XMLin($xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);
cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'PARCEL',
                    Machinable     => 'true',
                },
            ],
        }
    },
    'buildXML: PARCEL service, 1 item in cart'
);

like($xml, qr/RateV3Request USERID.+?Package ID=.+?Service.+?ZipOrigination.+?ZipDestination.+?Pounds.+?Ounces.+?Size.+?Machinable/, '... and tag order');

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to USPS successful');
    my $xmlData = XMLin($response->content, ForceArray => [qw/Package/],);
    cmp_deeply(
        $xmlData,
        {
            Package => [
                {
                    ID             => 0,
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Machinable     => ignore(), Ounces         => ignore(),
                    Pounds         => ignore(), Size           => ignore(),
                    Zone           => ignore(), Container      => {},
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(10,10),  ##A number around 10...
                    }
                },
            ],
        },
        '... returned data from USPS in correct format.  If this test fails, the driver may need to be updated'
    );

}

my $cost = $driver->_calculateFromXML(
    {
        RateV3Response => {
            Package => [
                {
                    ID => 0,
                    Postage => {
                        Rate => 5.25,
                    },
                },
            ],
        },
    },
    @shippableUnits
);

is($cost, 5.25, '_calculateFromXML calculates shipping cost correctly for 1 item in the cart');

$bibleItem = $bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
@shippableUnits = $driver->_getShippableUnits($cart);

is(calculateInsurance($driver), 7, '_calculateInsurance: two items in cart with quantity=1, calculates insurance');

$xml = $driver->buildXML($cart, @shippableUnits);
$xmlData = XMLin( $xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);

cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '2',        Ounces         => '0.0',
                    Size           => 'REGULAR',  Service        => 'PARCEL',
                    Machinable     => 'true',
                },
                {
                    ID => 1,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'PARCEL',
                    Machinable     => 'true',
                },
            ],
        }
    },
    'Validate XML structure and content for 2 items in the cart'
);

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to USPS successful for 2 items in cart');
    my $xmlData = XMLin($response->content, ForceArray => [qw/Package/],);
    cmp_deeply(
        $xmlData,
        {
            Package => [
                {
                    ID             => 0,
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Machinable     => ignore(), Ounces         => '0.0',
                    Pounds         => 2,        Size           => ignore(),
                    Zone           => ignore(), Container      => {},
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(10,10),  ##A number around 10...
                    }
                },
                {
                    ID             => 1,
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Machinable     => ignore(), Ounces         => '8.0',
                    Pounds         => 1,        Size           => ignore(),
                    Zone           => ignore(), Container      => {},
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(10,10),  ##A number around 10...
                    }
                },
            ],
        },
        '... returned data from USPS in correct format for 2 items in cart.  If this test fails, the driver may need to be updated'
    );

}

$cost = $driver->_calculateFromXML(
    {
        RateV3Response => {
            Package => [
                {
                    ID => 0,
                    Postage => {
                        Rate => 7.00,
                    },
                },
                {
                    ID => 1,
                    Postage => {
                        Rate => 5.25,
                    },
                },
            ],
        },
    },
    @shippableUnits
);

is($cost, 12.25, '_calculateFromXML calculates shipping cost correctly for 2 items in the cart');

$bibleItem->setQuantity(2);
@shippableUnits = $driver->_getShippableUnits($cart);

is(calculateInsurance($driver), 8, '_calculateInsurance: two items in cart with quantity=2, calculates insurance');

$cost = $driver->_calculateFromXML(
    {
        RateV3Response => {
            Package => [
                {
                    ID => 0,
                    Postage => {
                        Rate => 7.00,
                    },
                },
                {
                    ID => 1,
                    Postage => {
                        Rate => 5.25,
                    },
                },
            ],
        },
    },
    @shippableUnits
);
is($cost, 19.25, '_calculateFromXML calculates shipping cost correctly for 2 items in the cart, with quantity of 2');

$rockHammer2 = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $bigHammer));
$rockHammer2->update({shippingAddressId => $wucAddress->getId});
@shippableUnits = $driver->_getShippableUnits($cart);
is(calculateInsurance($driver), 12, '_calculateInsurance: calculates insurance');
$xml = $driver->buildXML($cart, @shippableUnits);

$xmlData = XMLin( $xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);

cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '2',        Ounces         => '0.0',
                    Size           => 'REGULAR',  Service        => 'PARCEL',
                    Machinable     => 'true',
                },
                {
                    ID => 1,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'PARCEL',
                    Machinable     => 'true',
                },
                {
                    ID => 2,
                    ZipDestination => '53703',    ZipOrigination => '97123',
                    Pounds         => '12',       Ounces         => '0.0',
                    Size           => 'REGULAR',  Service        => 'PARCEL',
                    Machinable     => 'true',
                },
            ],
        }
    },
    'Validate XML structure and content for 3 items in the cart, 3 shippable items'
);

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to USPS successful for 3 items in cart');
    my $xmlData = XMLin($response->content, ForceArray => [qw/Package/],);
    cmp_deeply(
        $xmlData,
        {
            Package => [
                {
                    ID             => 0,
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Machinable     => ignore(), Ounces         => '0.0',
                    Pounds         => 2,        Size           => ignore(),
                    Zone           => ignore(), Container      => {},
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(10,10),  ##A number around 10...
                    }
                },
                {
                    ID             => 1,
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Machinable     => ignore(), Ounces         => '8.0',
                    Pounds         => 1,        Size           => ignore(),
                    Zone           => ignore(), Container      => {},
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(10,10),  ##A number around 10...
                    }
                },
                {
                    ID             => 2,
                    ZipOrigination => ignore(), ZipDestination => 53703,
                    Machinable     => ignore(), Ounces         => '0.0',
                    Pounds         => 12,       Size           => ignore(),
                    Zone           => ignore(), Container      => {},
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(20,20),  ##A number around 20...
                    }
                },
            ],
        },
        '... returned data from USPS in correct format for 3 items in cart.  If this test fails, the driver may need to be updated'
    );

}

my $xmlData = XMLin(q{<?xml version="1.0"?>
<RateV3Response><Package ID="0"><ZipOrigination>97123</ZipOrigination><ZipDestination>53715</ZipDestination><Pounds>2</Pounds><Ounces>0.0</Ounces><Size>REGULAR</Size><Machinable>TRUE</Machinable><Zone>7</Zone><Postage CLASSID="4"><MailService>Parcel Post</MailService><Rate>7.62</Rate></Postage></Package><Package ID="1"><ZipOrigination>97123</ZipOrigination><ZipDestination>53715</ZipDestination><Pounds>1</Pounds><Ounces>8.0</Ounces><Size>REGULAR</Size><Machinable>TRUE</Machinable><Zone>7</Zone><Postage CLASSID="4"><MailService>Parcel Post</MailService><Rate>7.62</Rate></Postage></Package><Package ID="2"><ZipOrigination>97123</ZipOrigination><ZipDestination>53703</ZipDestination><Pounds>12</Pounds><Ounces>0.0</Ounces><Size>REGULAR</Size><Machinable>TRUE</Machinable><Zone>7</Zone><Postage CLASSID="4"><MailService>Parcel Post</MailService><Rate>16.67</Rate></Postage></Package></RateV3Response>
}, KeepRoot => 1, ForceArray => [qw/Package/],);

my $cost = $driver->_calculateFromXML($xmlData, @shippableUnits);
is $cost, "39.53", 'calculating shipping cost for separate shipping addreses in 1 transaction';

#######################################################################
#
# Test Priority shipping setup
#
#######################################################################

$cart->empty;
$properties = $driver->get();
$properties->{shipType} = 'PRIORITY';
$driver->update($properties);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
@shippableUnits = $driver->_getShippableUnits($cart);
$xml = $driver->buildXML($cart, @shippableUnits);
my $xmlData = XMLin($xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);
cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'PRIORITY',
                    Machinable     => 'true',     Container      => 'FLAT RATE BOX',
                },
            ],
        }
    },
    'buildXML: PRIORITY service, 1 item in cart'
);
like($xml, qr/RateV3Request USERID.+?Package ID=.+?Service.+?ZipOrigination.+?ZipDestination.+?Pounds.+?Ounces.+?Container.+?Size.+?Machinable/, '... and tag order');

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to USPS successful');
    my $xmlData = XMLin($response->content, ForceArray => [qw/Package/],);
    cmp_deeply(
        $xmlData,
        {
            Package => [
                {
                    ID             => 0,
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Container      => ignore(), Ounces         => ignore(), ##Machinable missing, added Container
                    Pounds         => ignore(), Size           => ignore(),
                    Zone           => ignore(),
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(10,10),  ##A number around 10...
                    }
                },
            ],
        },
        '... returned data from USPS in correct format.  If this test fails, the driver may need to be updated'
    );

}

#######################################################################
#
# Test EXPRESS shipping setup
#
#######################################################################

$properties = $driver->get();
$properties->{shipType} = 'EXPRESS';
$driver->update($properties);

$xml = $driver->buildXML($cart, @shippableUnits);
my $xmlData = XMLin($xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);
cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'EXPRESS',
                    Machinable     => 'true',
                },
            ],
        }
    },
    'buildXML: EXPRESS service, 1 item in cart'
);
like($xml, qr/RateV3Request USERID.+?Package ID=.+?Service.+?ZipOrigination.+?ZipDestination.+?Pounds.+?Ounces.+?Size.+?Machinable/, '... and tag order');

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '... _doXmlRequest to USPS successful');
    my $xmlData = XMLin($response->content, ForceArray => [qw/Package/],);
    cmp_deeply(
        $xmlData,
        {
            Package => [
                {
                    ID             => 0,        Container      => {},
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Ounces         => ignore(), Pounds         => ignore(),
                    Size           => ignore(), Zone           => ignore(),
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(30,30),  ##A number around 10...
                    }
                },
            ],
        },
        '... returned data from USPS in correct format.  If this test fails, the driver may need to be updated'
    );

}

#######################################################################
#
# Test PRIORITY VARIABLE shipping setup
#
#######################################################################

$properties = $driver->get();
$properties->{shipType} = 'PRIORITY VARIABLE';
$driver->update($properties);

$xml = $driver->buildXML($cart, @shippableUnits);
my $xmlData = XMLin($xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);
cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'PRIORITY',
                    Machinable     => 'true',#     Container      => 'VARIABLE',
                },
            ],
        }
    },
    'buildXML: PRIORITY, VARIABLE service, 1 item in cart'
);
like($xml, qr/RateV3Request USERID.+?Package ID=.+?Service.+?ZipOrigination.+?ZipDestination.+?Pounds.+?Ounces.+?Size.+?Machinable/, '... and tag order');

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '... _doXmlRequest to USPS successful');
    my $xmlData = XMLin($response->content, ForceArray => [qw/Package/],);
    cmp_deeply(
        $xmlData,
        {
            Package => [
                {
                    ID             => 0,        Container      => {},
                    ZipOrigination => ignore(), ZipDestination => ignore(),
                    Ounces         => ignore(), Pounds         => ignore(),
                    Size           => ignore(), Zone           => ignore(),
                    Postage        => {
                        CLASSID     => ignore(),
                        MailService => ignore(),
                        Rate        => num(8,8),  ##A number around 10...
                    }
                },
            ],
        },
        '... returned data from USPS in correct format.  If this test fails, the driver may need to be updated'
    );

}

#######################################################################
#
# Test ZIP+4 format domestic code
#
#######################################################################
$cart->update({shippingAddressId => $zip4Address->getId});

my $xmlData = XMLin($driver->buildXML($cart, @shippableUnits),
    KeepRoot   => 1,
    ForceArray => ['Package'],
);
cmp_deeply(
    $xmlData,
    {
        RateV3Request => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    ZipDestination => '53715',    ZipOrigination => '97123',
                    Pounds         => '1',        Ounces         => '8.0',
                    Size           => 'REGULAR',  Service        => 'PRIORITY',
                    Machinable     => 'true',#     Container      => 'VARIABLE',
                },
            ],
        }
    },
    'buildXML: removed plus4 part of zipcode'
);

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $cost = eval { $driver->calculate($cart); };
    my $e    = Exception::Class->caught();
    ok( ! ref $e, 'no exception thrown for zip+4 address');
    cmp_deeply($cost, num(10,9.99), 'zip+4 address returns a valid cost');

}

$cart->update({shippingAddressId => $workAddress->getId});
#######################################################################
#
# Check for throwing an exception
#
#######################################################################

my $userId  = $driver->get('userId');
$properties = $driver->get();
$properties->{userId} = '__NEVER_GOING_TO_HAPPEN__';
$driver->update($properties);

$cost = eval { $driver->calculate($cart); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::Shop::RemoteShippingRate', 'calculate throws an exception when a bad userId is used');

$properties->{userId} = $userId;
$driver->update($properties);

my $dutchAddress = $addressBook->addAddress({
    label => 'dutch',
    address1 => 'Rotterdamseweg 183C',
    city => 'Delft', code => '2629HD',
    country => 'Netherlands',
});

$cart->update({shippingAddressId => $dutchAddress->getId});
$cost = eval { $driver->calculate($cart); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', "calculate won't calculate for foreign countries");

$cart->update({shippingAddressId => $workAddress->getId});

#<?xml version="1.0"?>
#<RateV3Response><Package ID="0"><Error><Number>-2147219500</Number>
#<Source>DomesticRatesV3;clsRateV3.ValidateWeight;RateEngineV3.ProcessRequest</Source>
#<Description>Please enter the package weight.  </Description>
#<HelpFile></HelpFile><HelpContext>1000440</HelpContext></Error></Package></RateV3Response>

#######################################################################
#
# _calculateInsurance edge case
#
#######################################################################
$cart->empty;
$bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $gospels));
@shippableUnits = $driver->_getShippableUnits($cart);
is(calculateInsurance($driver), 1, '_calculateInsurance: calculates insurance using the first bin');

#######################################################################
#
# _parseInsuranceRates
#
#######################################################################

my @rates;
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("");
cmp_deeply(\@rates, [], '_parseInsuranceRates: empty string returns empty array');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates();
cmp_deeply(\@rates, [], '_parseInsuranceRates: undef returns empty array');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("2");
cmp_deeply(\@rates, [], '... bad rates #1');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates(":2");
cmp_deeply(\@rates, [], '... bad rates #2');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("a:b");
cmp_deeply(\@rates, [], '... bad rates #3');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("2:2");
cmp_deeply(\@rates, [ ['2', '2'] ], '... one line of good rates');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("2.0:2.0");
cmp_deeply(\@rates, [ ['2.0', '2.0'] ], '... one line of good rates with decimal points');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("2.0:2.0\n");
cmp_deeply(\@rates, [ ['2.0', '2.0'] ], '... one line of good rates with newline');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("2.0:2.0\r\n");
cmp_deeply(\@rates, [ ['2.0', '2.0'] ], '... one line of good rates with cr/newline');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("2.0 : 2.0\r\n");
cmp_deeply(\@rates, [ ['2.0', '2.0'] ], '... one line of good rates with cr/newline and spaces');
@rates = WebGUI::Shop::ShipDriver::USPS::_parseInsuranceRates("  2.0 : 2.0  \r\n");
cmp_deeply(\@rates, [ ['2.0', '2.0'] ], '... one line of good rates with cr/newline and more spaces');

#----------------------------------------------------------------------------
# Cleanup

sub calculateInsurance {
    my $driver = shift;
    my $properties = $driver->get();
    $properties->{addInsurance}   = 1;
    $properties->{insuranceRates} = $insuranceTable;
    $driver->update($properties);

    my $insurance = $driver->_calculateInsurance(@shippableUnits);

    $properties->{addInsurance}   = 0;
    $driver->update($properties);

    return $insurance;
}
