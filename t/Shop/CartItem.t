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
use WebGUI::Asset;
use WebGUI::Shop::CartItem;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $root = WebGUI::Asset->getRoot($session);
my $product = $root->addChild($session, {
    className=>"WebGUI::Asset::Sku::Product",
    title=>"Test Product",
    price=>4.99
    });

my $item = WebGUI::Shop::CartItem->create($session, "XXX", $product, 2);
isa_ok($item, "WebGUI::Shop::CartItem");
isa_ok($item->session, "WebGUI::Session", "did we get a session");

is(ref($item->get), "HASH", "Do we have a hash of properties?");
is($item->get("quantity"), 2, "Should have 2 of these in the cart.");
is($item->delete, undef, "actually deletes the item");


$product->purge;

#----------------------------------------------------------------------------
# Cleanup
END {

}
