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
use WebGUI::Storage::Image;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 7;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $node = WebGUI::Asset::Sku::Product->getProductImportNode($session);
isa_ok($node, 'WebGUI::Asset::Wobject::Folder', 'getProductImportNode returns a Folder');
is($node->getId, 'PBproductimportnode001', 'Product Import Node has the correct GUID');

my $product = $node->addChild({
    className => "WebGUI::Asset::Sku::Product",
    title     => "Rock Hammer",
});

is($product->getThumbnailUrl(), '', 'Product with no image1 property returns the empty string');

my $image = WebGUI::Storage::Image->create($session);
$image->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('lamp.jpg'));

my $imagedProduct = $node->addChild({
    className => "WebGUI::Asset::Sku::Product",
    title     => "Bible",
    image1    => $image->getId,
});

ok($imagedProduct->getThumbnailUrl(), 'getThumbnailUrl is not empty');
is($imagedProduct->getThumbnailUrl(), $image->getThumbnailUrl('lamp.jpg'), 'getThumbnailUrl returns the right path to the URL');

my $otherImage = WebGUI::Storage::Image->create($session);
$otherImage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('gooey.jpg'));

ok($imagedProduct->getThumbnailUrl($otherImage), 'getThumbnailUrl with an explicit storageId returns something');
is($imagedProduct->getThumbnailUrl($otherImage), $otherImage->getThumbnailUrl('gooey.jpg'), 'getThumbnailUrl with an explicit storageId returns the right path to the URL');

#----------------------------------------------------------------------------
# Cleanup
END {
    $product->purge;
    $imagedProduct->purge;
    $image->delete;
    $otherImage->delete;
}

1;
