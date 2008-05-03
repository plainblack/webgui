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
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Product;
use JSON;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root = WebGUI::Asset->getRoot($session);
my $product = $root->addChild({
        className =>"WebGUI::Asset::Sku::Product",
        title     =>"Test Donation",
        price     => 44.44,
        });
isa_ok($product, "WebGUI::Asset::Sku::Product");
ok(! exists $product->{_collateral}, 'object cache does not exist yet');

$product->setCollateral('variantsJSON', 'new', {a => 'aye', b => 'bee'});

isa_ok($product->{_collateral}, 'HASH', 'object cache created for collateral');

my $json;
$json = $product->get('variantsJSON');
my $jsonData = from_json($json);
cmp_bag(
    $jsonData,
    [ {a => 'aye', b => 'bee' } ],
    'Correct JSON data stored when collateral is empty',
);

$product->purge;


#----------------------------------------------------------------------------
# Cleanup
END {

}

1;
