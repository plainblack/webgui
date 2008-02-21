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

plan tests => 8;        # Increment this number for each test you create

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

my %options = $sku->getOptions;
is($options{test1}, "YY", "Can set and get an option.");


is($sku->getMaxAllowedInCart, 99999999, "Got a valid default max in cart.");
is($sku->getPrice, 0.00, "Got a valid default price.");
is($sku->getTaxRate, undef, "Tax rate is not overridden.");
$sku->update({overrideTaxRate=>1, taxRateOverride=>5});
is($sku->getTaxRate, 5, "Tax rate is overridden.");
isnt($sku->processStyle, "", "Got some style information.");

my $loadSku = WebGUI::Asset::Sku->newBySku($session, $sku->get("sku"));
is($loadSku->getId, $sku->getId, "newBySku() works.");


#----------------------------------------------------------------------------
# Cleanup
END {

}
