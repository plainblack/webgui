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
# This tests WebGUI::Asset::Sku::Product

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Deep;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Product;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $node = WebGUI::Asset::Sku::Product->getProductImportNode($session);
isa_ok($node, 'WebGUI::Asset::Wobject::Folder', 'getProductImportNode returns a Folder');
is($node->getId, 'PBproductimportnode001', 'Product Import Node has the correct GUID');

my $product1 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'});
my $product2 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'});
my $product3 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'});

my $getAProduct = WebGUI::Asset::Sku::Product->getAllProducts($session);
isa_ok($getAProduct, 'CODE', 'getAllProducts returns a sub ref');
my $counter = 0;
my $productIds = [];
while( my $product = $getAProduct->()) {
    ++$counter;
    push @{ $productIds }, $product->getId;
}
is($counter, 3, 'getAllProducts: returned only 3 Products');
cmp_bag($productIds, [$product1->getId, $product2->getId, $product3->getId], 'getAllProduct returned the correct 3 products');

$product1->purge;
$product2->purge;
$product3->purge;

#----------------------------------------------------------------------------
# Cleanup
END {

}

1;
