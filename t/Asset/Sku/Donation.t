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
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Donation;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root = WebGUI::Asset->getRoot($session);
my $sku = $root->addChild({
        className=>"WebGUI::Asset::Sku::Donation",
        title=>"Test Donation",
        defaultPrice => 50.00,
        });
WebGUI::Test->addToCleanup($sku);
isa_ok($sku, "WebGUI::Asset::Sku::Donation");

is($sku->getPrice, 50.00, "Price should be 50.00");

$sku->applyOptions({
        price   => 200.00
        });
is($sku->getPrice, 200.00, "Price should be 200.00");

is($sku->getConfiguredTitle, "Test Donation (200)", "getConfiguredTitle()");

$sku->purge;

1;
