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

use strict;

use Test::More;
use Test::Deep;
use Data::Dumper;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Product;
use WebGUI::Storage;
use WebGUI::Test::Mechanize;
use JSON;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 49;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $node = WebGUI::Asset->getRoot($session);

my $product = WebGUI::Test->asset(
    className => "WebGUI::Asset::Sku::Product",
    title     => "Rock Hammer",
    groupIdEdit => 3,
);

is($product->getThumbnailUrl(), '', 'Product with no image1 property returns the empty string');

note "Checking automatically generated deleteFileUrl links";
foreach my $file_property (qw/image1 image2 image3 brochure manual warranty/) {
    my $form_properties = $product->getFormProperties($file_property);
    like $form_properties->{deleteFileUrl}, qr/file=$file_property/, '...' . $file_property;
}

my $image = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($image);
$image->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('lamp.jpg'));
$image->generateThumbnail('lamp.jpg');

my $imagedProduct = WebGUI::Test->asset(
    className          => "WebGUI::Asset::Sku::Product",
    title              => "Bible",
    image1             => $image->getId,
    isShippingRequired => 1,
);

ok($imagedProduct->getThumbnailUrl(), 'getThumbnailUrl is not empty');
is($imagedProduct->getThumbnailUrl(), $image->getThumbnailUrl('lamp.jpg'), 'getThumbnailUrl returns the right path to the URL');

my $otherImage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($otherImage);
$otherImage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('gooey.jpg'));
$otherImage->generateThumbnail('gooey.jpg');

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

my $otherVarId = $imagedProduct->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Elbonian',
        varSku    => 'Elbonian-bible',
        price     => 11,
        weight    => 7,
        quantity  => 0,
    }
);

$imagedProduct->applyOptions($imagedProduct->getCollateral('variantsJSON', 'variantId', $englishVarId));

is($imagedProduct->getConfiguredTitle, 'Bible - English', 'getConfiguredTitle is overridden and concatenates the Product Title and the variant shortdesc');

my $addToCartForm = $imagedProduct->getAddToCartForm();
my @forms = HTML::Form->parse($addToCartForm, 'http://www.webgui.org');
is(scalar @forms, 1, 'getAddToCartForm: returns only 1 form');
my $form_variants = $forms[0]->find_input('vid');
cmp_deeply(
    [ $englishVarId ],
    [ $form_variants->possible_values ],
    '... form only has 1 variant, since the other one has 0 quantity'
);

####################################################
#
# addRevision
#
####################################################

my $newImagedProduct = $imagedProduct->addRevision({title => 'Bible and hammer'},time+2);

like($newImagedProduct->get('image1'), $session->id->getValidator, 'addRevision: new product rev got an image1 storage location');
isnt($newImagedProduct->get('image1'), $imagedProduct->get('image1'), '... and it is not the same as the old one');

####################################################
#
# view, template variables
#
####################################################

my $jsonTemplate = WebGUI::Test->asset(
    className => 'WebGUI::Asset::Template',
    title     => 'JSON template for Product testing',
    template  => q|
{
    "brochure_icon":"<tmpl_var brochure_icon>",
    "brochure_url" :"<tmpl_var brochure_url>",
    "warranty_icon":"<tmpl_var warranty_icon>",
    "warranty_url" :"<tmpl_var warranty_url>",
    "manual_icon"  :"<tmpl_var manual_icon>",
    "manual_url"   :"<tmpl_var manual_url>"
}
|,
);

my @storages = map { WebGUI::Storage->create($session) } 0..2;

my $viewProduct = WebGUI::Test->asset(
    className  => 'WebGUI::Asset::Sku::Product',
    title      => 'View Product for template variable tests',
    templateId => $jsonTemplate->getId,
    brochure   => $storages[0]->getId,
    warranty   => $storages[1]->getId,
    manual     => $storages[2]->getId,
);

$viewProduct->prepareView();
my $json = $viewProduct->view();

my $vars = JSON::from_json($json);
cmp_deeply(
    $vars,
    {
        brochure_icon => '',
        brochure_url  => '',
        warranty_icon => '',
        warranty_url  => '',
        manual_icon   => '',
        manual_url    => '',
    },
    'brochure, warranty and manual vars are blank since their storages are empty'
);

#----------------------------------------------------------------------------
# addAccessory
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });
$mech->get_ok( $product->getUrl( 'func=addAccessory' ) );

$mech->submit_form_ok({
    fields => {
        accessoryAccessId => $imagedProduct->getId,
        proceed => 1,
    },
}, 'add imagedProduct as an accessory and add another');

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'accessoryJSON' ),
    [ { accessoryAssetId => $imagedProduct->getId } ],
);

$mech->submit_form_ok({
    fields  => {
        accessoryAccessId => $viewProduct->getId,
        proceed => 0,
    },
}, 'add viewProduct and go back' );

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'accessoryJSON' ),
    [ { accessoryAssetId => $imagedProduct->getId }, { accessoryAssetId => $viewProduct->getId } ],
);

#----------------------------------------------------------------------------
# addRelated
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });
$mech->get_ok( $product->getUrl( 'func=addRelated' ) );

$mech->submit_form_ok({
    fields => {
        relatedAssetId => $imagedProduct->getId,
        proceed => 1,
    },
}, 'add imagedProduct as a related and add another');

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'relatedJSON' ),
    [ { relatedAssetId => $imagedProduct->getId } ],
);

$mech->submit_form_ok({
    fields  => {
        relatedAssetId => $viewProduct->getId,
        proceed => 0,
    },
}, 'add viewProduct and go back' );

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'relatedJSON' ),
    [ { relatedAssetId => $imagedProduct->getId }, { relatedAssetId => $viewProduct->getId } ],
);

#----------------------------------------------------------------------------
# editBenefit
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });
$mech->get_ok( $product->getUrl( 'func=editBenefit' ) );

$mech->submit_form_ok({
    fields => {
        benefit => 'One new benefit',
        proceed => 1,
    },
}, 'add one new benefit');

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'benefitJSON' ),
    [ { benefit => 'One new benefit', benefitId => ignore() } ],
);

$mech->submit_form_ok({
    fields  => {
        benefit => 'Two new benefit',
        proceed => 0,
    },
}, 'add one more new benefit' );

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'benefitJSON' ),
    [
        { benefit => 'One new benefit', benefitId => ignore() }, 
        { benefit => 'Two new benefit', benefitId => ignore() },
    ],
);

my $benefit = $product->getAllCollateral( 'benefitJSON' )->[0];
$mech->get_ok( $product->getUrl( 'func=editBenefit;bid=' . $benefit->{benefitId} ) );

$mech->submit_form_ok( {
    fields => {
        benefit => 'One edited benefit',
    },
}, 'edit an existing benefit' );
$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'benefitJSON' ),
    [
        { benefit => 'One edited benefit', benefitId => ignore() }, 
        { benefit => 'Two new benefit', benefitId => ignore() },
    ],
);


#----------------------------------------------------------------------------
# editFeature
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });
$mech->get_ok( $product->getUrl( 'func=editFeature' ) );

$mech->submit_form_ok({
    fields => {
        feature => 'One new feature',
        proceed => 1,
    },
}, 'add one new feature');

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'featureJSON' ),
    [ { feature => 'One new feature', featureId => ignore() } ],
);

$mech->submit_form_ok({
    fields  => {
        feature => 'Two new feature',
        proceed => 0,
    },
}, 'add one more new feature' );

$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'featureJSON' ),
    [
        { feature => 'One new feature', featureId => ignore() }, 
        { feature => 'Two new feature', featureId => ignore() },
    ],
);

my $feature = $product->getAllCollateral( 'featureJSON' )->[0];
$mech->get_ok( $product->getUrl( 'func=editFeature;fid=' . $feature->{featureId} ) );

$mech->submit_form_ok( {
    fields => {
        feature => 'One edited feature',
    },
}, 'edit an existing feature' );
$product = $product->cloneFromDb;
cmp_deeply(
    $product->getAllCollateral( 'featureJSON' ),
    [
        { feature => 'One edited feature', featureId => ignore() }, 
        { feature => 'Two new feature', featureId => ignore() },
    ],
);

