#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use HTML::TokeParser;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 4;

$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::CartItemCount';
my $loaded = use_ok($macro);

my $cart = WebGUI::Shop::Cart->newBySession($session);
WebGUI::Test->addToCleanup($cart);
my $donation = WebGUI::Asset->getRoot($session)->addChild({
    className => 'WebGUI::Asset::Sku::Donation',
    title     => 'Charitable donation',
    defaultPrice => 10.00,
});
WebGUI::Test->addToCleanup($donation);

my $output;

$output = WebGUI::Macro::CartItemCount::process($session);
is ($output, '0', 'Empty cart returns 0 items');

my $item1 = $cart->addItem($donation);
$output = WebGUI::Macro::CartItemCount::process($session);
is ($output, '1', 'Cart contains 1 item');

my $item2 = $cart->addItem($donation);
$output = WebGUI::Macro::CartItemCount::process($session);
is ($output, '2', 'Cart contains 2 items, 1 each');

$item2->setQuantity(10);
$output = WebGUI::Macro::CartItemCount::process($session);
is ($output, '11', 'Cart contains 11 items, 1 and 10');

#vim:ft=perl
