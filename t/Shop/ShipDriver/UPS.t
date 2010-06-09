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
use WebGUI::Shop::ShipDriver::UPS;
use Locales;
#my $locales = Locales->new('en');
#diag Dumper [ $locales->get_territory_names() ];
#diag $locales->get_code_from_territory('United States');

#----------------------------------------------------------------------------
# Init
my $session   = WebGUI::Test->session;
my $user      = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($user);
$session->user({user => $user});

#----------------------------------------------------------------------------
# Tests

plan tests => 41;

#----------------------------------------------------------------------------
# put your tests here

my $storage;
my ($driver);
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

my $feather = $home->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    isShippingRequired => 1,     title => 'Feathers',
    shipsSeparately    => 0,
});

my $blueFeather = $feather->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'blue feather',  price     => 1.00,
        varSku    => 'blue',          weight    => 0.001,
        quantity  => 999999,
    }
);

$versionTag->commit;
addToCleanup($versionTag);
foreach my $asset($rockHammer, $bible, $feather) {
    $asset = $asset->cloneFromDb;
}

#######################################################################
#
# definition
#
#######################################################################

my $definition;
my $e; ##Exception variable, used throughout the file

eval { $definition = WebGUI::Shop::ShipDriver::UPS->definition(); };
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
    $definition = WebGUI::Shop::ShipDriver::UPS->definition($session),
    'ARRAY'
);


#######################################################################
#
# create
#
#######################################################################

my $options = {
                label   => 'UPS Driver',
                enabled => 1,
              };

$driver = WebGUI::Shop::ShipDriver::UPS->create($session, $options);

isa_ok($driver, 'WebGUI::Shop::ShipDriver::UPS');
isa_ok($driver, 'WebGUI::Shop::ShipDriver');

#######################################################################
#
# getName
#
#######################################################################

is (WebGUI::Shop::ShipDriver::UPS->getName($session), 'UPS', 'getName returns the human readable name of this driver');

#######################################################################
#
# delete
#
#######################################################################

my $driverId = $driver->getId;
$driver->delete;

my $count = $session->db->quickScalar('select count(*) from shipper where shipperId=?',[$driverId]);
is($count, 0, 'delete deleted the object');

undef $driver;

#######################################################################
#
# calculate, and private methods.
#
#######################################################################

$driver = WebGUI::Shop::ShipDriver::UPS->create($session, {
    label    => 'Shipping from Shawshank',
    enabled  => 1,
    shipType => 'PARCEL',
});
addToCleanup($driver);

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
isa_ok($e, 'WebGUI::Error::InvalidParam', 'calculate throws an exception when no source country');
cmp_deeply(
    $e,
    methods(
        error => 'Driver configured without a source country.',
    ),
    '... checking error message',
);

$properties = $driver->get();
$properties->{sourceCountry} = 'United States';
$driver->update($properties);
eval { $driver->calculate() };
$e = WebGUI::Error->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'calculate throws an exception when no userId');
cmp_deeply(
    $e,
    methods(
        error => 'Driver configured without a UPS userId.',
    ),
    '... checking error message',
);

$properties = $driver->get();
$properties->{userId} = 'Me';
$driver->update($properties);
eval { $driver->calculate() };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'calculate throws an exception when no password');
cmp_deeply(
    $e,
    methods(
        error => 'Driver configured without a UPS password.',
    ),
    '... checking error message',
);

$properties = $driver->get();
$properties->{password} = 'knock knock';
$driver->update($properties);
eval { $driver->calculate() };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'calculate throws an exception when no license number');
cmp_deeply(
    $e,
    methods(
        error => 'Driver configured without a UPS license number.',
    ),
    '... checking error message',
);

my $cart = WebGUI::Shop::Cart->newBySession($session);
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
$cart->update({shippingAddressId => $workAddress->getId});

cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [(), ],
    '_getShippableUnits: empty cart'
);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [ [ [ ignore() ], ], ],
    '_getShippableUnits: one loose item in the cart'
);

$rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $bigHammer));
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [ [ [ ignore(), ignore() ], ], ],
    '_getShippableUnits: two loose items in the cart'
);

$bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $kjvBible));
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [ bag( [ ignore(), ignore() ], [ ignore() ], ), ],
    '_getShippableUnits: two loose items, and 1 ships separately item in the cart'
);

my $bibleItem = $bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
$bibleItem->setQuantity(3);
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [ bag( [ ignore(), ignore() ], [ ignore() ], [ ignore() ], [ ignore() ], [ ignore() ] ) ],
    '_getShippableUnits: two loose items, and 4 ships separately item in the cart, due to quantity'
);

my $rockHammer2 = $bible->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
$rockHammer2->update({shippingAddressId => $wucAddress->getId});
cmp_bag(
    [$driver->_getShippableUnits($cart)],
    [
        bag( [ ignore(), ignore() ], [ ignore() ], [ ignore() ], [ ignore() ], [ ignore() ] ),
        [ [ ignore() ], ],
    ],
    '_getShippableUnits: two loose items, and 4 ships separately item in the cart, and another loose item sorted by zipcode'
);

$cart->empty;
$bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
cmp_deeply(
    [$driver->_getShippableUnits($cart)],
    [ [ ignore() ], ],
    '_getShippableUnits: only 1 ships separately item in the cart'
);
$cart->empty;

my $userId = $session->config->get('testing/UPS_userId');
my $hasUPSCredentials = 1;
##If there isn't a userId, set a fake one for XML testing.
if (! $userId) {
    $hasUPSCredentials = 0;
    $userId = "blahBlahBlah";
}

my $password = $session->config->get('testing/UPS_password');
##If there isn't a password, set a fake one for XML testing.
if (! $password) {
    $hasUPSCredentials = 0;
    $password = "nyaahNyaah";
}

my $license = $session->config->get('testing/UPS_licenseNo');
##If there isn't a license, set a fake one for XML testing.
if (! $license) {
    $hasUPSCredentials = 0;
    $license = "bogey";
}

$properties = $driver->get();
$properties->{userId}                 = $userId;
$properties->{password}               = $password;
$properties->{licenseNo}              = $license;
$properties->{sourceZip}              = '97123';
$properties->{sourceCountry}          = 'United States';
$properties->{shipService}            = '03';
$properties->{pickupType}             = '01';
$properties->{customerClassification} = '04';
$properties->{residentialIndicator}   = 'residential';
$driver->update($properties);

$driver->testMode(1);

my $rockItem = $rockHammer->addToCart($rockHammer->getCollateral('variantsJSON', 'variantId', $smallHammer));
my @shippableUnits = $driver->_getShippableUnits($cart);

##Must look them up one zip at a time
my $xml = $driver->buildXML($cart, $shippableUnits[0]);
like($xml, qr/^<.xml version='1.0'.+?<.xml version=/ms, 'buildXML: has two xml declarations');
like($xml, qr/<AccessRequest xml:lang/, '... xml:lang is an attribute of AccessRequest');
#diag $xml;

my ($xmlA, $xmlR) = split /\n(?=<\?xml)/, $xml;

my $xmlAcc = XMLin($xmlA,
    KeepRoot => 1,
);

cmp_deeply(
    $xmlAcc,
    {
        AccessRequest => {
            Password   => $password,
            UserId     => $userId,
            'xml:lang' => 'en-US',
            AccessLicenseNumber => $license,
        },
    },
    '... correct access request data structure for 1 package'
);

my $xmlRate = XMLin($xmlR,
    KeepRoot => 1,
);

cmp_deeply(
    $xmlRate, {
        RatingServiceSelectionRequest => {
            'xml:lang' => 'en-US',
            PickupType             => { Code => '01', },
            CustomerClassification => { Code => '04', },
            Request                => { RequestAction => 'Rate', },
            Shipment               => {
                Shipper => {
                    Address => { PostalCode => 97123, CountryCode => 'us', },
                },
                ShipTo => {
                    Address => { PostalCode => 53715, CountryCode => 'us', ResidentialAddressIndicator => {}, },
                },
                Service => { Code => '03', },
                Package => {
                    PackagingType => { Code   => '02',  },
                    PackageWeight => { Weight => '1.5', },
                },
            },
        }
    },
    '... correct access rating request structure for 1 package'
);

SKIP: {

    skip 'No UPS credentials for testing', 3 unless $hasUPSCredentials;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to UPS successful for 1 package');
    #diag $response->content;
    my $xmlData = XMLin($response->content, ForceArray => [qw/RatedPackage/],);
    ok($xmlData->{Response}->{ResponseStatusCode}, '... responseCode is successful');
    ok($xmlData->{RatedShipment}->{TotalCharges}->{MonetaryValue}, '... total charges returned');
    #diag($xmlData->{RatedShipment}->{TotalCharges}->{MonetaryValue});

}

$rockItem->setQuantity(2);
@shippableUnits = $driver->_getShippableUnits($cart);
$xml = $driver->buildXML($cart, $shippableUnits[0]);
SKIP: {

    skip 'No UPS credentials for testing', 3 unless $hasUPSCredentials;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to UPS successful for 1 item, quantity=2');
    #diag $response->content;
    my $xmlData = XMLin($response->content, ForceArray => [qw/RatedPackage/],);
    ok($xmlData->{Response}->{ResponseStatusCode}, '... responseCode is successful');
    ok($xmlData->{RatedShipment}->{TotalCharges}->{MonetaryValue}, '... total charges returned');
    #diag($xmlData->{RatedShipment}->{TotalCharges}->{MonetaryValue});

}


TODO: {
    local $TODO = 'single item shipping cost calculation';
    ok(0, 'call _calculateFromXML with arranged data');
}


$bibleItem = $bible->addToCart($bible->getCollateral('variantsJSON', 'variantId', $nivBible));
@shippableUnits = $driver->_getShippableUnits($cart);
$xml = $driver->buildXML($cart, @shippableUnits);

($xmlA, $xmlR) = split /\n(?=<\?xml)/, $xml;

#diag $xmlR;

$xmlRate = XMLin( $xmlR,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);

#diag Dumper $xmlRate;

cmp_deeply(
    $xmlRate, {
        RatingServiceSelectionRequest => {
            'xml:lang' => 'en-US',
            PickupType             => { Code => '01', },
            CustomerClassification => { Code => '04', },
            Request                => { RequestAction => 'Rate', },
            Shipment               => {
                Shipper => {
                    Address => { PostalCode => 97123, CountryCode => 'us', },
                },
                ShipTo => {
                    Address => { PostalCode => 53715, CountryCode => 'us', ResidentialAddressIndicator => {}, },
                },
                Service => { Code => '03', },
                Package => bag(
                    {
                        PackagingType => { Code   => '02',  },
                        PackageWeight => { Weight => '3.0', },
                    },
                    {
                        PackagingType => { Code   => '02',  },
                        PackageWeight => { Weight => '2.0', },
                    },
                ),
            },
        }
    },
    '... correct access rating request structure for two packages in cart'
);

SKIP: {

    skip 'No UPS credentials for testing', 3 unless $hasUPSCredentials;

    my $response = $driver->_doXmlRequest($xml);
    ok($response->is_success, '_doXmlRequest to UPS successful for two package in 1 request');
    my $xmlData = XMLin($response->content, ForceArray => [qw/RatedPackage/],);
    ok($xmlData->{Response}->{ResponseStatusCode}, '... responseCode is successful');
    ok($xmlData->{RatedShipment}->{TotalCharges}->{MonetaryValue}, '... total charges returned');
}

ok($driver->getEditForm(), 'getEditForm');

$cart->empty;
$feather->addToCart($feather->getCollateral('variantsJSON', 'variantId', $blueFeather));
$xml = $driver->buildXML($cart, $driver->_getShippableUnits($cart));
($xmlA, $xmlR) = split /\n(?=<\?xml)/, $xml;

$xmlRate = XMLin( $xmlR,
    KeepRoot   => 1,
    ForceArray => ['Package'],
);

is (
    $xmlRate->{RatingServiceSelectionRequest}->{Shipment}->{Package}->[0]->{PackageWeight}->{Weight},
    '0.1',
    'Weight is clipped at 0.1 pounds.'
);

$cart->empty;
