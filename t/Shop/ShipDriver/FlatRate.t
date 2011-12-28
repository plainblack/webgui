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

use strict;
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

plan tests => 17;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Shop::ShipDriver::FlatRate');

#######################################################################
#
# create
#
#######################################################################

my $options = {
                label   => 'flat rate, ship weight, items in the cart',
                enabled => 1,
                flatFee => 1.00,
                percentageOfPrice => 5,
                pricePerWeight    => 0.5,
                pricePerItem      => 0.1,
              };

my $driver2 = WebGUI::Shop::ShipDriver::FlatRate->new($session, $options);
$driver2->write;
WebGUI::Test->addToCleanup($driver2);

isa_ok($driver2, 'WebGUI::Shop::ShipDriver::FlatRate');

isa_ok($driver2, 'WebGUI::Shop::ShipDriver');

#######################################################################
#
# getName
#
#######################################################################

is (WebGUI::Shop::ShipDriver::FlatRate->getName($session), 'Flat Rate', 'getName returns the human readable name of this driver');

#######################################################################
#
# getEditForm
#
#######################################################################

my $form = $driver2->getEditForm;

isa_ok($form, 'WebGUI::FormBuilder', 'getEditForm returns an HTMLForm object');

my $html = $form->toHtml;

##Any URL is fine, really
my @forms = HTML::Form->parse($html, 'http://www.webgui.org');
is (scalar @forms, 1, 'getEditForm generates just 1 form');

my @inputs = $forms[0]->inputs;
is (scalar @inputs, 13, 'getEditForm: the form has 13 controls');

my @interestingFeatures;
foreach my $input (@inputs) {
    my $name = $input->name;
    my $type = $input->type;
    push @interestingFeatures, { name => $name, type => $type };
}

cmp_deeply(
    \@interestingFeatures,
    [
        {
            name => "send",
            type => 'submit',
        },
        {
            name => 'shop',
            type => 'hidden',
        },
        {
            name => 'method',
            type => 'hidden',
        },
        {
            name => 'do',
            type => 'hidden',
        },
        {
            name => 'driverId',
            type => 'hidden',
        },
        {
            name => 'label',
            type => 'text',
        },
        {
            name => 'enabled',
            type => 'radio',
        },
        {
            name => 'groupToUse',
            type => 'option',
        },
        {
            name => '__groupToUse_isIn',
            type => 'hidden',
        },
        {
            name => 'flatFee',
            type => 'text',
        },
        {
            name => 'percentageOfPrice',
            type => 'text',
        },
        {
            name => 'pricePerWeight',
            type => 'text',
        },
        {
            name => 'pricePerItem',
            type => 'text',
        },
    ],
    'getEditForm made the correct form with all the elements'

);

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
# calculate
#
#######################################################################

my $car = WebGUI::Test->asset->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    title              => 'Automobiles',
    isShippingRequired => 1,
});

my $crappyCar = $car->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => '1987 Ford Escort',
        varSku    => 'crappy-car',
        price     => 600,
        weight    => 1500,
        quantity  => 5,
    }
);

my $goodCar = $car->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => '2004 Honda MPV minivan',
        varSku    => 'used van',
        price     => 15_000,
        weight    => 2000,
        quantity  => 15,
    }
);

my $reallyNiceCar = $car->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Cadillac XLR-V',
        varSku    => 'nice-car',
        price     => 90_000,
        weight    => 3000,
        quantity  => 4,
    }
);

$options = {
    label   => 'flat rate, ship weight',
    enabled => 1,
    flatFee => 1.00,
    percentageOfPrice => 0,
    pricePerWeight    => 100,
    pricePerItem      => 10,
};

my $driver = WebGUI::Shop::ShipDriver::FlatRate->new($session, $options);
WebGUI::Test->addToCleanup($driver);

my $cart = WebGUI::Shop::Cart->newBySession($session);
WebGUI::Test->addToCleanup($cart);

$car->addToCart($car->getCollateral('variantsJSON', 'variantId', $crappyCar));
is($driver->calculate($cart), 1511, 'calculate by weight, perItem and flat fee work');

$car->addToCart($car->getCollateral('variantsJSON', 'variantId', $reallyNiceCar));
is($driver->calculate($cart), 4521, 'calculate by weight, perItem and flat fee work for two items');

$options = {
    label   => 'percentage of price',
    enabled => 1,
    flatFee => 0.00,
    percentageOfPrice => 1/3*100,
    pricePerWeight    => 0,
    pricePerItem      => 0,
};
$driver->update($options);
is($driver->calculate($cart), 30_200, 'calculate by percentage of price');

$cart->empty();
$driver->update({
    label   => 'flat fee for shipsSeparately test',
    enabled => 1,
    flatFee => 1,
    percentageOfPrice => 0,
    pricePerWeight    => 0,
    pricePerItem      => 0,
});

my $key = WebGUI::Test->asset->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    title              => 'Key',
    isShippingRequired => 1,
    shipsSeparately    => 1,
});

my $metalKey = $key->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'metal key',
        varSku    => 'metal-key',
        price     => 1.00,
        weight    => 1.00,
        quantity  => 1e9,
    }
);

my $bioKey = $key->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'biometric key',
        varSku    => 'bio-key',
        price     => 5.00,
        weight    => 1.00,
        quantity  => 1e9,
    }
);

my $boughtCar = $car->addToCart($car->getCollateral('variantsJSON', 'variantId', $reallyNiceCar));
my $firstKey  = $key->addToCart($key->getCollateral('variantsJSON', 'variantId', $metalKey));
is($driver->calculate($cart), 2, 'shipsSeparately: returns two, one for ships separately, one for ships bundled');

$boughtCar->adjustQuantity();
is($driver->calculate($cart), 2, '... returns two, one for ships separately, one for ships bundled, even for two items');

$firstKey->adjustQuantity();
is($driver->calculate($cart), 3, '... returns three, two for ships separately, one for ships bundled, even for two items');

$key->update({shipsSeparately => 0});
is($driver->calculate($cart), 1, '... returns one, since all can be bundled together now');

$car->update({shipsSeparately => 1});
$key->update({shipsSeparately => 1});
is($driver->calculate($cart), 4, '... returns four, since all must be shipped separately now');
