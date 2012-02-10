# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
#
# This tests WebGUI::Asset::Sku::Ad

use strict;

use Test::More;
use Test::Deep;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Ad;
use WebGUI::AdSpace;
use WebGUI::Storage;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 8;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $discounts = <<'EOT';
5@500
10@1000
EOT

my $discountsWithJunk = <<'EOT';
comment
5@500 nuthr cmnt

10@1000heresatuf1
last coment
EOT

# print $discounts, $discountsWithJunk;

cmp_deeply([WebGUI::Asset::Sku::Ad::parseDiscountText($discounts)],
      [ [ 5,500 ],[10,1000] ],
        'parseDiscounttext parses correctly');

cmp_deeply([WebGUI::Asset::Sku::Ad::parseDiscountText($discountsWithJunk)],
      [ [ 5,500 ],[10,1000] ],
        'parseDiscounttext ignores comments and blank space');

is( WebGUI::Asset::Sku::Ad::getDiscountText('Discount at %s',$discounts),
              'Discount at 500,1000',
       'getDiscountText formats the text correctly');

is( WebGUI::Asset::Sku::Ad::getDiscountAmount($discounts,100),0,'no discount');
is( WebGUI::Asset::Sku::Ad::getDiscountAmount($discounts,550),5,'5% discount');
is( WebGUI::Asset::Sku::Ad::getDiscountAmount($discounts,1050),10,'10% discount');

# make an AdSku object

my $root = WebGUI::Asset->getRoot($session);


my $sku = $root->addChild({
    className => "WebGUI::Asset::Sku::Ad",
    title     => "Ad Space For Sale",
    adSpace   => 'qwert',
    priority  => 1,
    pricePerClick => 0.01,
    pricePerImpression => 0.0001,
    clickDiscounts => <<'EOCD',
5@500
10@50000
EOCD
    impressionDiscounts => <<'EOID',
5@10000
15@500000
EOID
});
WebGUI::Test->addToCleanup($sku);

$sku->applyOptions({
      adtitle => 'Sold!',
      link => 'http://localhost/',
      clicks => 1000,
      impressions => 100000,
      image => 'asdfgh',   # don't need this unless I test onCompletePurchse...
});

is($sku->getConfiguredTitle, 'Ad Space For Sale (Sold!)', 'configured title');
is($sku->getPrice, '19.00', 'get Price');
# $sku->onCompletePurchase($item);  --> not really sure how to test the rest...
# $sku->onRefund

#vim:ft=perl
