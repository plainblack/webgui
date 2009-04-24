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
use WebGUI::Storage;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 8;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $node = WebGUI::Asset->getRoot($session);

my $product = $node->addChild({
    className => "WebGUI::Asset::Sku::Product",
    title     => "Rock Hammer",
});

is($product->getThumbnailUrl(), '', 'Product with no image1 property returns the empty string');

my $image = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($image);
$image->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('lamp.jpg'));

my $imagedProduct = $node->addChild({
    className          => "WebGUI::Asset::Sku::Product",
    title              => "Bible",
    image1             => $image->getId,
    isShippingRequired => 1,
});

ok($imagedProduct->getThumbnailUrl(), 'getThumbnailUrl is not empty');
is($imagedProduct->getThumbnailUrl(), $image->getThumbnailUrl('lamp.jpg'), 'getThumbnailUrl returns the right path to the URL');

my $otherImage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($otherImage);
$otherImage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('gooey.jpg'));

ok($imagedProduct->getThumbnailUrl($otherImage), 'getThumbnailUrl with an explicit storageId returns something');
is($imagedProduct->getThumbnailUrl($otherImage), $otherImage->getThumbnailUrl('gooey.jpg'), 'getThumbnailUrl with an explicit storageId returns the right path to the URL');

is($imagedProduct->get('isShippingRequired'), 1, 'isShippingRequired set to 1 in db');
is($imagedProduct->isShippingRequired,        1, 'isShippingRequired accessor works');

my $englishVarId = $imagedProduct->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'English',
        varSku    => 'english-bible',
        price     => 10,
        weight    => 5,
        quantity  => 1000,
    }
);

use Data::Dumper;
$imagedProduct->applyOptions($imagedProduct->getCollateral('variantsJSON', 'variantId', $englishVarId));

is($imagedProduct->getConfiguredTitle, 'Bible - English', 'getConfiguredTitle is overridden and concatenates the Product Title and the variant shortdesc');

#----------------------------------------------------------------------------
# Cleanup
END {
    $product->purge;
    $imagedProduct->purge;
}

1;
