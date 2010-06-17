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

# This "test" script shoves products into the table so that the upgrade translation
# process can be tested.
#
# Here's what we're looking for after the upgrade runs.
# 1) Correct number of products translated
# 2) All revisions translated
# 3) Variants created for each Product Wobject
# 4) If no productNumber is defined, then it makes one for you.
# 5) Titles are truncated to 30 characters and used as the short description
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Tax;
use WebGUI::Asset::Wobject::Product;
use WebGUI::VersionTag;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# put your tests here

##Create products by hand

my $tag = WebGUI::VersionTag->getWorking($session);

my $properties1 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'one',
    price         => 10.00,
    productNumber => '#1',
    title         => 'product 1',
    description   => 'First product',
};

my $root = WebGUI::Asset->getRoot($session);
my $product1 = $root->addChild($properties1);

note ref $product1;

my $properties2 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'two',
    price         => 20.00,
    productNumber => '#2',
    title         => 'product 2',
    description   => 'Second product',
};

my $product2 = $root->addChild($properties2);

note ref $product2;

$tag->commit;
sleep 2;

$tag = WebGUI::VersionTag->getWorking($session);

my $product1a = $product1->addRevision({price => 11.11});

my $properties3 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'three',
    price         => 20.00,
    title         => 'no product number',
    description   => 'third product',
};

my $product3 = $root->addChild($properties3);

my $properties4 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'four',
    price         => 7.77,
    description   => 'no title',
};

my $product4 = $root->addChild($properties4);

my $properties5 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'five',
    price         => 7.77,
    title         => 'extremely long title that will be truncated to only 30 chars in the variant',
    description   => 'fourth product',
};

my $product5 = $root->addChild($properties5);

my $propertiesa = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'accessory Product',
    price         => 1.00,
    title         => 'accessory Product',
    description   => 'accessory Product',
};

my $producta = $root->addChild($propertiesa);

$session->db->write('insert into Product_accessory (assetId, accessoryAssetId, sequenceNumber) values (?,?,?)', [$producta->getId, $product5->getId, 1]);
$session->db->write('insert into Product_accessory (assetId, accessoryAssetId, sequenceNumber) values (?,?,?)', [$producta->getId, $product4->getId, 2]);

my $propertiesr = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'related_Product',
    price         => 2.00,
    title         => 'related Product',
    description   => 'related Product',
};

my $productr = $root->addChild($propertiesr);

$session->db->write('insert into Product_related (assetId, relatedAssetId, sequenceNumber) values (?,?,?)', [$productr->getId, $product4->getId, 1]);
$session->db->write('insert into Product_related (assetId, relatedAssetId, sequenceNumber) values (?,?,?)', [$productr->getId, $product5->getId, 2]);

my $propertiess = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'specification_Product',
    price         => 3.33,
    title         => 'specification Product',
    description   => 'specification Product',
};

my $products = $root->addChild($propertiess);

$products->setCollateral('Product_specification', 'Product_specificationId', {
    name => 'pitch',
    value => '440',
    units => 'Hertz',
});

my $propertiesf = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'feature_Product',
    price         => 3.33,
    title         => 'feature Product',
    description   => 'feature Product',
};

my $productf = $root->addChild($propertiesf);

$productf->setCollateral('Product_feature', 'Product_featureId', {
    feature => 'leather interior',
});

$productf->setCollateral('Product_feature', 'Product_featureId', {
    feature => '25% less code',
});

my $propertiesb = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'benefit_Product',
    price         => 4.44,
    title         => 'benefit Product',
    description   => 'benefit Product',
};

my $productb = $root->addChild($propertiesb);

$productb->setCollateral('Product_benefit', 'Product_benefitId', {
    benefit => 'holds mixed nuts',
});

$productb->setCollateral('Product_benefit', 'Product_benefitId', {
    benefit => 'automatic sodium monitoring',
});

$tag->commit;

note "Done.";
