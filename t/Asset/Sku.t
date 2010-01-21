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

plan tests => 22;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root = WebGUI::Asset->getRoot($session);
warn "Make sku\n";
my $sku = $root->addChild({
        className=>"WebGUI::Asset::Sku",
        title=>"Test Sku",
        });
isa_ok($sku, "WebGUI::Asset::Sku");
addToCleanup($sku);

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
isnt($sku->processStyle, "", "Got some style information.");
is($sku->onAdjustQuantityInCart, undef, "onAdjustQuantityInCart should exist and return undef");
is($sku->onCompletePurchase, undef, "onCompletePurchase should exist and return undef");
is($sku->onRemoveFromCart, undef, "onRemoveFromCart should exist and return undef");
is($sku->isRecurring, 0, "skus are not recurring by default");
is($sku->isShippingRequired, 0, "skus are not shippable by default");
is($sku->getConfiguredTitle, $sku->getTitle, "configured title and title should be the same by default");
is($sku->shipsSeparately, 0, 'shipsSeparately return 0 by default');
is($sku->isShippingSeparately, 0, 'isShippingSeparately return 0 by default');

$sku->shipsSeparately(1);
is($sku->isShippingSeparately, 0, 'isShippingSeparately only returns true when isShippingRequired AND shipsSeparately');

{
    local *WebGUI::Asset::Sku::isShippingRequired = sub { return 1};
    is($sku->isShippingSeparately, 1, 'isShippingSeparately only returns true when isShippingRequired AND shipsSeparately');
}

ok(! $sku->isShippingRequired, 'Making sure that GLOB is no longer in effect');

isa_ok($sku->getCart, "WebGUI::Shop::Cart", "can get a cart object");
my $item = $sku->addToCart;
isa_ok($item, "WebGUI::Shop::CartItem", "can add to cart");
$item->cart->delete;

my $loadSku = WebGUI::Asset::Sku->newBySku($session, $sku->get("sku"));
is($loadSku->getId, $sku->getId, "newBySku() works.");
