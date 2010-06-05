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
# This tests WebGUI::Asset::Sku::Donation

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Deep;
use Test::Exception;
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

plan tests => 34;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root = WebGUI::Asset->getRoot($session);
my $product = $root->addChild({
    className => "WebGUI::Asset::Sku::Product",
    title     => "Rock Hammer",
});
isa_ok($product, "WebGUI::Asset::Sku::Product");
ok(! exists $product->{_collateral}, 'object cache does not exist yet');

my $vid = $product->setCollateral('variantsJSON', 'vid', 'new', {a => 'aye', b => 'bee'});

isa_ok($product->{_collateral}, 'HASH', 'object cache created for collateral');
isnt($vid, 'new', 'setCollateral assigns a new id to collateral without one');
ok($session->id->valid($vid), 'a valid id was generated for the new collateral entry');

my $json;
$json = $product->get('variantsJSON');
my $jsonData = JSON::from_json($json);
cmp_deeply(
    $jsonData,
    [ {a => 'aye', b => 'bee', vid => $vid } ],
    'Correct JSON data stored when collateral is empty',
);

my $dbJson = $session->db->quickScalar('select variantsJSON from Product where assetId=?', [$product->getId]);
is($json, $dbJson, 'db updated with correct JSON');

my $vid2 = $product->setCollateral('variantsJSON', 'vid', 'new', {c => 'see', d => 'dee'});

my $collateral = $product->getAllCollateral('variantsJSON');
isa_ok($collateral, 'ARRAY', 'getAllCollateral returns an array ref');
cmp_deeply(
    $collateral,
    [
        {a => 'aye', b => 'bee', vid => $vid  },
        {c => 'see', d => 'dee', vid => $vid2 },
    ],
    'setCollateral: new always appends to the end',
);

$product->setCollateral('variantsJSON', 'vid', 'pollyWollyDoodle', {a => 'see', b => 'dee'});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye', b => 'bee', vid => $vid  },
        {c => 'see', d => 'dee', vid => $vid2 },
    ],
    'setCollateral: non-existant value of key does not set data',
);

$product->setCollateral('variantsJSON', 'brooks', $vid, {a => 'see', b => 'dee'});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye', b => 'bee', vid => $vid  },
        {c => 'see', d => 'dee', vid => $vid2 },
    ],
    'setCollateral: non-existant key with real value does not set data',
);

$product->setCollateral('variantsJSON', 'vid', $vid2, {a => 'see', b => 'dee', vid => $vid2});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye', b => 'bee', vid => $vid  },
        {a => 'see', b => 'dee', vid => $vid2 },
    ],
    'setCollateral: set by index works',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 'vid', "new"),
    {},
    'getCollateral: value=new returns an empty hashref',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 'vid'),
    {},
    'getCollateral: undef value returns an empty hashref',
);

cmp_deeply(
    $product->getCollateral('variantsJSON'),
    {},
    'getCollateral: undef keyName returns an empty hashref',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 'vid', 'neverAValidGUID'),
    {},
    'getCollateral: non-existant value with valid key returns an empty hashRef',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 'xvid', $vid),
    {},
    'getCollateral: non-existant key with valid value returns an empty hashRef',
);

cmp_deeply(
    $product->getCollateral('variantsJSON', 'vid', $vid2),
    {a => 'see', b => 'dee', 'vid' => $vid2 },
    'getCollateral: get by keyName and value works',
);

my $vid3 = $product->setCollateral('variantsJSON', 'vid', 'new', { a => 'alpha', b => 'beta'});

$product->deleteCollateral('variantsJSON', 'vid', $vid2);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',   b => 'bee',  vid => $vid  },
        {a => 'alpha', b => 'beta', vid => $vid3 },
    ],
    'deleteCollateral: delete by keyName and value works',
);

$product->deleteCollateral('variantsJSON', 'vid', 'andyDufresne');
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',   b => 'bee',  vid => $vid  },
        {a => 'alpha', b => 'beta', vid => $vid3 },
    ],
    'deleteCollateral: non-existant value with valid key does not delete',
);

$product->deleteCollateral('variantsJSON', 'vid', $vid3);
my $vid4 = $product->setCollateral('variantsJSON', 'vid', 'new', { a => 'alligators', b => 'bursting'});
my $vid5 = $product->setCollateral('variantsJSON', 'vid', 'new', { a => 'ah',         b => 'bay'});
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',          b => 'bee'     , 'vid' => $vid  },
        {a => 'alligators',   b => 'bursting', 'vid' => $vid4 },
        {a => 'ah',           b => 'bay',      'vid' => $vid5 },
    ],
    'setup correct for moving collateral',
);

$product->moveCollateralDown('variantsJSON', 'vid', $vid4);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',          b => 'bee'     , 'vid' => $vid  },
        {a => 'ah',           b => 'bay',      'vid' => $vid5 },
        {a => 'alligators',   b => 'bursting', 'vid' => $vid4 },
    ],
    'moveCollateralDown: worked',
);

$product->moveCollateralDown('variantsJSON', 'vid', 'shawshankRedemption');
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'aye',          b => 'bee'     , 'vid' => $vid  },
        {a => 'ah',           b => 'bay',      'vid' => $vid5 },
        {a => 'alligators',   b => 'bursting', 'vid' => $vid4 },
    ],
    'moveCollateralDown: can not move non-existant collateral item',
);

$product->moveCollateralUp('variantsJSON', 'vid', $vid5);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'ah',           b => 'bay',      'vid' => $vid5 },
        {a => 'aye',          b => 'bee'     , 'vid' => $vid  },
        {a => 'alligators',   b => 'bursting', 'vid' => $vid4 },
    ],
    'moveCollateralUp: worked',
);

$product->moveCollateralUp('variantsJSON', 'vid', $vid5);
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'ah',           b => 'bay',      'vid' => $vid5 },
        {a => 'aye',          b => 'bee'     , 'vid' => $vid  },
        {a => 'alligators',   b => 'bursting', 'vid' => $vid4 },
    ],
    'moveCollateralUp: can not move the first collateral item in the array',
);

$product->moveCollateralUp('variantsJSON', 'vid', 'brooksHadley');
cmp_deeply(
    $product->getAllCollateral('variantsJSON'),
    [
        {a => 'ah',           b => 'bay',      'vid' => $vid5 },
        {a => 'aye',          b => 'bee'     , 'vid' => $vid  },
        {a => 'alligators',   b => 'bursting', 'vid' => $vid4 },
    ],
    'moveCollateralUp: cannot move up non-existant collateral item',
);


$product->purge;
undef $product;

my $product2 = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Bible",
        });

my $vid6 = $product2->setCollateral('variantsJSON', 'vid', 'new', { s => 'scooby', d => 'doo'});
cmp_deeply(
    $product2->getCollateral('variantsJSON', 'vid', $vid6),
    { s => 'scooby', d => 'doo', vid => $vid6, },
    'Doing a set before get works okay',
);

$product2->purge;

my $product3 = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Bible",
        });

my $requestedVid = $session->id->generate();
my $bareVid = $product3->setCollateral('variantsJSON', 'bareVid', 'new', { bareVid => $requestedVid });
is($bareVid, $requestedVid, 'For single column collateral JSON, requested id = assigned id');

$product3->purge;

my $product4 = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Pinch a loaf",
        });

my $newVid;
$newVid = $product4->setCollateral('variantsJSON', 'vid', 'new', { major => 'problem', vid => 'new' });
isnt($newVid, 'new', 'setCollateral assigns a new id to collateral with an id of "new"...');
ok($session->id->valid($newVid), '... and it is a valid GUID');

$newVid = $product4->setCollateral('variantsJSON', 'vid', 'new', { major => 'problem', vid => '' });
isnt($newVid, 'new', 'setCollateral assigns a new id to collateral with an id of ""');
ok($session->id->valid($newVid), '... and it is a valid GUID');

$product4->purge;

my $product5 = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Working in the laundry",
        });

$newVid = $product5->setCollateral('variantsJSON', 'vid', 'new', { check => 'no leaks', vid => 'new' });
my $leak = $product5->getCollateral('variantsJSON', 'vid', $newVid);
$leak->{check} = 'leaky';
is( $product5->getCollateral('variantsJSON', 'vid', $newVid)->{check}, 'no leaks', 'getCollateral returns a safe copy');

$product5->purge;

##Handle wide characters

my $product6 = $root->addChild({
        className => "WebGUI::Asset::Sku::Product",
        title     => "Wide character attempt",
});

$newVid = $product6->setCollateral('variantsJSON', 'vid', 'new', { wideChar => qq!on 16\x{201d} hand-crocheted Cord!
, vid => 'new' });

my $product6a = WebGUI::Asset->newById($session, $product6->getId);
lives_ok { $product6a->getAllCollateral('variantsJSON', 'vid', $newVid); }, 'Product collateral handles wide-character encodings okay';

$product6->purge;

#----------------------------------------------------------------------------
# Cleanup
END {

    WebGUI::VersionTag->getWorking($session)->rollback;

}

1;
