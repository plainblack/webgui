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
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use XML::Simple;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::ShipDriver::USPSInternational;

plan tests => 34;

#----------------------------------------------------------------------------
# Init
my $session   = WebGUI::Test->session;
my $user      = WebGUI::User->create($session);
WebGUI::Test->usersToDelete($user);
$session->user({user => $user});

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# put your tests here


my ($driver2, $cart);

my $versionTag = WebGUI::VersionTag->getWorking($session);

my $home = WebGUI::Asset->getDefault($session);

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

$versionTag->commit;
addToCleanup($versionTag);

#######################################################################
#
# definition
#
#######################################################################

my $definition;
my $e; ##Exception variable, used throughout the file

eval { $definition = WebGUI::Shop::ShipDriver::USPSInternational->definition(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'definition takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    '... checking error message',
);


isa_ok(
    $definition = WebGUI::Shop::ShipDriver::USPSInternational->definition($session),
    'ARRAY'
);


#######################################################################
#
# create
#
#######################################################################

my $options = {
                label   => 'Intl USPS Driver',
                enabled => 1,
              };

$driver2 = WebGUI::Shop::ShipDriver::USPSInternational->create($session, $options);
addToCleanup($driver2);

isa_ok($driver2, 'WebGUI::Shop::ShipDriver::USPSInternational');
isa_ok($driver2, 'WebGUI::Shop::ShipDriver');

#######################################################################
#
# getName
#
#######################################################################

is (WebGUI::Shop::ShipDriver::USPSInternational->getName($session), 'U.S. Postal Service, International', 'getName returns the human readable name of this driver');

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

my $driver = WebGUI::Shop::ShipDriver::USPSInternational->create($session, {
    label    => 'Shipping from Shawshank',
    enabled  => 1,
});
addToCleanup($driver);

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
    organization => 'ProcoliX',
    address1 => 'Rotterdamseweg 183C',
    city => 'Delft', code => '2629HD',
    country => 'Netherlands',
});
my $sdhAddress = $addressBook->addAddress({
    label => 'other side of planet',
    organization => 'SDH',
    country => 'Australia',
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
$rockHammer2->update({shippingAddressId => $sdhAddress->getId});
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
my $properties = $driver->get();
$properties->{userId}   = $userId;
$properties->{shipType} = '9';
$driver->update($properties);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
my @shippableUnits = $driver->_getShippableUnits($cart);

my $xml = $driver->buildXML($cart, @shippableUnits);
like($xml, qr/<IntlRateRequest USERID="[^"]+"/, 'buildXML: checking userId is an attribute of the IntlRateRequest tag');
like($xml, qr/<Package ID="0"/, 'buildXML: checking ID is an attribute of the Package tag');

my $xmlData = XMLin($xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);
cmp_deeply(
    $xmlData,
    {
        IntlRateRequest => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    Pounds      => '1',        Ounces         => '8.0',
                    Machinable  => 'true',     Country        => 'Netherlands',
                    MailType    => 'Package',  
                },
            ],
        }
    },
    'buildXML: 1 item in cart'
);

like($xml, qr/IntlRateRequest USERID.+?Package ID=.+?Pounds.+?Ounces.+?Machinable.+?MailType.+?Country.+?/, '... and tag order');

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
                    AreasServed    => ignore(), Prohibitions   => ignore(),
                    ExpressMail    => ignore(), CustomsForms   => ignore(),
                    Observations   => ignore(), Restrictions   => ignore(),
                    Service        => [
                        {
                            ID             => ignore(),
                            MaxWeight      => ignore(),
                            MaxDimensions  => ignore(),
                            MailType       => 'Package',
                            Ounces         => '8',
                            Pounds         => '1',
                            Country        => 'NETHERLANDS',
                            Machinable     => 'true',
                            Postage        => num(100,99),
                            SvcCommitments => ignore(),
                            SvcDescription => ignore(),
                        },
                        (ignore())x12,
                    ],
                },
            ],
        },
        '... returned data from USPS in correct format.  If this test fails, the driver may need to be updated'
    );

}

my $cost = $driver->_calculateFromXML(
    {
        IntlRateResponse => {
            Package => [
                {
                    ID => 0,
                    Service => [
                        {
                            ID        => '9',
                            Postage   => '5.25',
                            MaxWeight => '70'
                        },
                        {
                            ID        => '11',
                            Postage   => '7.25',
                            MaxWeight => '70'
                        },
                    ],
                },
            ],
        },
    },
    @shippableUnits
);

is($cost, 5.25, '_calculateFromXML calculates shipping cost correctly for 1 item in the cart');

$bibleItem = $bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
@shippableUnits = $driver->_getShippableUnits($cart);

$xml = $driver->buildXML($cart, @shippableUnits);
$xmlData = XMLin( $xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);

cmp_deeply(
    $xmlData,
    {
        IntlRateRequest => {
            USERID => $userId,
            Package => [
                {
                    ID => 0,
                    Pounds      => '2',        Ounces         => '0.0',
                    Machinable  => 'true',     Country        => 'Netherlands',
                    MailType    => 'Package',  
                },
                {
                    ID => 1,
                    Pounds      => '1',        Ounces         => '8.0',
                    Machinable  => 'true',     Country        => 'Netherlands',
                    MailType    => 'Package',  
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
}

$cost = $driver->_calculateFromXML(
    {
        IntlRateResponse => {
            Package => [
                {
                    ID => 0,
                    Service => [
                        {
                            ID        => '9',
                            Postage   => '7.00',
                            MaxWeight => '70'
                        },
                        {
                            ID        => '11',
                            Postage   => '9.00',
                            MaxWeight => '70'
                        },
                    ],
                },
                {
                    ID => 1,
                    Service => [
                        {
                            ID        => '9',
                            Postage   => '5.25',
                            MaxWeight => '70'
                        },
                        {
                            ID        => '11',
                            Postage   => '7.25',
                            MaxWeight => '70'
                        },
                    ],
                },
            ],
        },
    },
    @shippableUnits
);

is($cost, 12.25, '_calculateFromXML calculates shipping cost correctly for 2 items in the cart');

$bibleItem->setQuantity(2);
@shippableUnits = $driver->_getShippableUnits($cart);

$cost = $driver->_calculateFromXML(
    {
        IntlRateResponse => {
            Package => [
                {
                    ID => 0,
                    Service => [
                        {
                            ID        => '9',
                            Postage   => '7.00',
                            MaxWeight => '70'
                        },
                        {
                            ID        => '11',
                            Postage   => '9.00',
                            MaxWeight => '70'
                        },
                    ],
                },
                {
                    ID => 1,
                    Service => [
                        {
                            ID        => '9',
                            Postage   => '5.25',
                            MaxWeight => '70'
                        },
                        {
                            ID        => '11',
                            Postage   => '7.25',
                            MaxWeight => '70'
                        },
                    ],
                },
            ],
        },
    },
    @shippableUnits
);
is($cost, 19.25, '_calculateFromXML calculates shipping cost correctly for 2 items in the cart, with quantity of 2');

$rockHammer2 = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $bigHammer));
$rockHammer2->update({shippingAddressId => $sdhAddress->getId});
@shippableUnits = $driver->_getShippableUnits($cart);
$xml = $driver->buildXML($cart, @shippableUnits);

$xmlData = XMLin( $xml,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);

cmp_deeply(
    $xmlData,
    {
        IntlRateRequest => {
            USERID  => $userId,
            Package => [
                {
                    ID => 0,
                    Pounds      => '2',        Ounces         => '0.0',
                    Machinable  => 'true',     Country        => 'Netherlands',
                    MailType    => 'Package',  
                },
                {
                    ID => 1,
                    Pounds      => '12',       Ounces         => '0.0',
                    Machinable  => 'true',     Country        => 'Australia',
                    MailType    => 'Package',  
                },
                {
                    ID => 2,
                    Pounds      => '1',        Ounces         => '8.0',
                    Machinable  => 'true',     Country        => 'Netherlands',
                    MailType    => 'Package',  
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
}

#######################################################################
#
# Check too heavy for my shipping type
#
#######################################################################

$cart->empty;
$properties = $driver->get();
$properties->{shipType} = '9';
$driver->update($properties);

SKIP: {

    skip 'No userId for testing', 2 unless $hasRealUserId;

    my $heavyHammer = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $bigHammer));
    $heavyHammer->setQuantity(2);
    $cost = eval { $driver->calculate($cart); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::Shop::RemoteShippingRate', "USPS returns error when package is too heavy for the selected service");
    cmp_deeply(
        $e,
        methods(
            error => 'Selected shipping service not available',
        ),
        '... checking error message',
    );

    $heavyHammer->setQuantity(20);
    $cost = eval { $driver->calculate($cart); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::Shop::RemoteShippingRate', "USPS returns error when package is too heavy for any service");

}

#######################################################################
#
# Check for throwing an exception
#
#######################################################################

my $userId  = $driver->get('userId');
$properties = $driver->get();
$properties->{userId} = '_NO_NO_NO_NO';
$driver->update($properties);

$cost = eval { $driver->calculate($cart); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::Shop::RemoteShippingRate', 'calculate throws an exception when a bad userId is used');

$properties->{userId} = $userId;
$driver->update($properties);

my $dutchAddress = $addressBook->addAddress({
    label        => 'american',
    organization => 'Plain Black Corporation',
    address1     => '1360 Regent St. #145',
    city         => 'Madison', state => 'WI', code => '53715',
    country      => 'United States',
});

$cart->update({shippingAddressId => $dutchAddress->getId});
$cost = eval { $driver->calculate($cart); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', "calculate won't calculate for domestic countries");

$cart->update({shippingAddressId => $workAddress->getId});

