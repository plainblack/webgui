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
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Cart;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 9;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $cart = WebGUI::Shop::Cart->create($session);

isa_ok($cart, "WebGUI::Shop::Cart");
isa_ok($cart->session, "WebGUI::Session");

my $root = WebGUI::Asset->getRoot($session);
my $product = $root->addChild($session, {
    className=>"WebGUI::Asset::Sku::Product",
    title=>"Test Product",
    price=>4.99
    });

$cart->addItem($product, 1);
is(scalar(@{$cart->getItems}), 1, "Added an item to the cart.");
like($cart->getId, qr/[A-Za-z0-9\_\-]{22}/, "Id looks like a guid.");

is(ref($cart->get), "HASH", "Cart properties are a hash reference.");
is($cart->get("sessionId"), $session->getId, "Can retrieve a value from the cart properties.");
$cart->set({shippingAddressId => "XXXX"});
is($cart->get("shippingAddressId"), "XXXX", "Can set values to the cart properties.");

my $id = $cart->getId;
$cart->delete;
is($cart, undef, "Can destroy cart.");
is($session->db->quickScalar("select count(*) from cartItems where cartId=?",[$id]), 0, "Items are also removed from cart.");


#----------------------------------------------------------------------------
# Cleanup
END {

}
