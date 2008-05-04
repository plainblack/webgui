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
# This tests WebGUI::Asset::Sku::Donation

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Deep;
use JSON;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Product;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 24;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root = WebGUI::Asset->getRoot($session);
my $product = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Rock Hammer",
        });
isa_ok($product, "WebGUI::Asset::Sku::Product");
ok(! exists $product->{_collateral}, 'object cache does not exist yet');

$product->setCollateral('variantsJSON', 'new', {a => 'aye', b => 'bee'});

isa_ok($product->{_collateral}, 'HASH', 'object cache created for collateral');

my $json;
$json = $product->get('variantsJSON');
my $jsonData = from_json($json);
cmp_deeply(
    $jsonData,
    [ {a => 'aye', b => 'bee' } ],
    'Correct JSON data stored when collateral is empty',
);

my $dbJson = $session->db->quickScalar('select variantsJSON from Product where assetId=?', [$product->getId]);
is($json, $dbJson, 'db updated with correct JSON');

$product->setCollateral('variantsJSON', 'new', {c => 'see', d => 'dee'});

my $collateral = $product->getAllCollateral('variantsJSON');
isa_ok($collateral, 'ARRAY', 'getAllCollateral returns an array ref');
cmp_deeply(
    $collateral,
    [
        {a => 'aye', b => 'bee' },
        {c => 'see', d => 'dee' },
    ],
    'setCollateral: new always appends to the end',
);

$product->setCollateral('variantsJSON', 2, {a => 'see', b => 'dee'});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye', b => 'bee' },
        {c => 'see', d => 'dee' },
    ],
    'setCollateral: out of range index does not work',
);

$product->setCollateral('variantsJSON', 1, {a => 'see', b => 'dee'});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye', b => 'bee' },
        {a => 'see', b => 'dee' },
    ],
    'setCollateral: set by index works',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', "new"),
    {},
    'getCollateral: index=new returns an empty hashref',
);

cmp_deeply(
    $product->getCollateral('variantsJSON'),
    {},
    'getCollateral: undef index returns an empty hashref',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 3),
    {},
    'getCollateral: out of range index returns an empty hashref',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 1),
    {a => 'see', b => 'dee' },
    'getCollateral: get by index works',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', -1),
    {a => 'see', b => 'dee' },
    'getCollateral: negative index works',
);

$product->setCollateral('variantsJSON', 'new', { a => 'alpha', b => 'beta'});

$product->deleteCollateral('variantsJSON', 1);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',   b => 'bee' },
        {a => 'alpha', b => 'beta' },
    ],
    'deleteCollateral: delete by index works',
);

$product->deleteCollateral('variantsJSON', 4);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',   b => 'bee' },
        {a => 'alpha', b => 'beta' },
    ],
    'deleteCollateral: out of range index does not delete',
);

$product->deleteCollateral('variantsJSON', -1);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',   b => 'bee' },
    ],
    'deleteCollateral: negative index works',
);

$product->setCollateral('variantsJSON', 'new', { a => 'alligators', b => 'bursting'});
$product->setCollateral('variantsJSON', 'new', { a => 'ah',         b => 'bay'});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',          b => 'bee' },
        {a => 'alligators',   b => 'bursting' },
        {a => 'ah',           b => 'bay' },
    ],
    'setup correct for moving collateral',
);

$product->moveCollateralDown('variantsJSON', 1);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',          b => 'bee' },
        {a => 'ah',           b => 'bay' },
        {a => 'alligators',   b => 'bursting' },
    ],
    'moveCollateralDown: worked',
);

$product->moveCollateralDown('variantsJSON', 3);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',          b => 'bee' },
        {a => 'ah',           b => 'bay' },
        {a => 'alligators',   b => 'bursting' },
    ],
    'moveCollateralDown: can not move out of range collateral item',
);

$product->moveCollateralUp('variantsJSON', 1);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'ah',           b => 'bay' },
        {a => 'aye',          b => 'bee' },
        {a => 'alligators',   b => 'bursting' },
    ],
    'moveCollateralUp: worked',
);

$product->moveCollateralUp('variantsJSON', 0);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'ah',           b => 'bay' },
        {a => 'aye',          b => 'bee' },
        {a => 'alligators',   b => 'bursting' },
    ],
    'moveCollateralUp: can not move the first collateral item in the array',
);

$product->moveCollateralUp('variantsJSON', 5);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'ah',           b => 'bay' },
        {a => 'aye',          b => 'bee' },
        {a => 'alligators',   b => 'bursting' },
    ],
    'moveCollateralUp: out of range index does not do anything',
);

$product->purge;
undef $product;

my $product2 = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Bible",
        });

$product2->setCollateral('variantsJSON', 'new', { s => 'scooby', d => 'doo'});
cmp_deeply(
    $product2->getCollateral('variantsJSON', 0),
    { s => 'scooby', d => 'doo'},
    'Doing a set before get works okay',
);

$product2->purge;

#----------------------------------------------------------------------------
# Cleanup
END {

}

1;
