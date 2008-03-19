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
# This tests WebGUI::Asset::Sku, which is the base class for commerce items

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 19;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root = WebGUI::Asset->getRoot($session);
my $sku = $root->addChild({
        className=>"WebGUI::Asset::Sku",
        title=>"Test Sku",
        });
isa_ok($sku, "WebGUI::Asset::Sku");

$sku->addToCart;

$sku->applyOptions({
        test1   => "YY"
        });

my $options = $sku->getOptions;
is($options->{test1}, "YY", "Can set and get an option.");


is($sku->getMaxAllowedInCart, 99999999, "Got a valid default max in cart.");
is($sku->getQuantityAvailable, 99999999, "skus should have an unlimited quantity by default");
is($sku->getQuantityAvailable, $sku->getMaxAllowedInCart, "quantity available and max allowed in cart should be the same");
is($sku->getPrice, 0.00, "Got a valid default price.");
is($sku->getWeight, 0, "Got a valid default weight.");
is($sku->getTaxRate, undef, "Tax rate is not overridden.");
$sku->update({overrideTaxRate=>1, taxRateOverride=>5});
is($sku->getTaxRate, 5, "Tax rate is overridden.");
isnt($sku->processStyle, "", "Got some style information.");
is($sku->onAdjustQuantityInCart, undef, "onAdjustQuantityInCart should exist and return undef");
is($sku->onCompletePurchase, undef, "onCompletePurchase should exist and return undef");
is($sku->onRemoveFromCart, undef, "onRemoveFromCart should exist and return undef");
is($sku->isRecurring, 0, "skus are not recurring by default");
is($sku->isShippingRequired, 0, "skus are not shippable by default");
is($sku->getConfiguredTitle, $sku->getTitle, "configured title and title should be the same by default");

isa_ok($sku->getCart, "WebGUI::Shop::Cart", "can get a cart object");
my $item = $sku->addToCart;
isa_ok($item, "WebGUI::Shop::CartItem", "can add to cart");
$item->cart->delete;

my $loadSku = WebGUI::Asset::Sku->newBySku($session, $sku->get("sku"));
is($loadSku->getId, $sku->getId, "newBySku() works.");

$sku->purge;

#----------------------------------------------------------------------------
# Cleanup
END {

}

1;
