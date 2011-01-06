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

##The goal of this test is to test the creation of a MatrixListing Asset.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 14; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::Matrix;
use WebGUI::Asset::MatrixListing;


my $session = WebGUI::Test->session;
$session->user({ userId => 3 });
my ($matrix, $matrixListing);
$matrix = WebGUI::Test->asset(
    className => 'WebGUI::Asset::Wobject::Matrix',
    categories => "One\nTwo\nThree",
    groupIdEdit => '3',
);

# Can't set attributeId here or new attributes won't get added
my $styleId = $matrix->editAttributeSave( {
    assetId         => $matrix->getId,
    category        => "One",
    name            => "Style",
    fieldType       => "textarea",
} );
my $colorId = $matrix->editAttributeSave( {
    assetId         => $matrix->getId,
    category        => "One",
    name            => "Color",
    fieldType       => "text",
} );
my $shapeId = $matrix->editAttributeSave( {
    assetId         => $matrix->getId,
    category        => "Two",
    name            => "Shape",
    fieldType       => "selectBox",
    options         => "square\ncircle\noval\ntriangle",
} );
my $sheepId = $matrix->editAttributeSave( {
    assetId         => $matrix->getId,
    category        => "Three",
    name            => "Sheep",
    fieldType       => "yesNo",
} );
$matrixListing = $matrix->addChild({className=>'WebGUI::Asset::MatrixListing'});

# Test for sane object types
isa_ok($matrix, 'WebGUI::Asset::Wobject::Matrix');
isa_ok($matrixListing, 'WebGUI::Asset::MatrixListing');

# Test for proper edit form
my $fb = $matrixListing->getEditForm;

my ( $fieldset, $field );
ok( $fieldset = $fb->getFieldset( "One" ), "getEditForm has fieldset for One category" );
ok( $field = $fieldset->getField( "attribute_$styleId" ), "fieldset has field for style" );
isa_ok( $field, 'WebGUI::Form::Textarea' );
ok( $field = $fieldset->getField( "attribute_$colorId" ), "fieldset has field for color" );
isa_ok( $field, 'WebGUI::Form::Text' );

ok( $fieldset = $fb->getFieldset( "Two" ), "getEditForm has fieldset for Two category" );
ok( $field = $fieldset->getField( "attribute_$shapeId" ), "fieldset has field for shape" );
isa_ok( $field, 'WebGUI::Form::SelectBox' );
is( $field->get('options'), join("\n", "square", "circle", "oval", "triangle" ), "correct select options" );

ok( $fieldset = $fb->getFieldset( "Three" ), "getEditForm has fieldset for Three category" );
ok( $field = $fieldset->getField( "attribute_$sheepId" ), 'fieldset has field for sheep' );
isa_ok( $field, 'WebGUI::Form::YesNo' );

# Try to add content under a MatrixListing asset
#my $article = $matrixListing->addChild({className=>'WebGUI::Asset::Wobject::Article'});
#is($article, undef, "Can't add an Article wobject as a child to a Matrix Listing.");

# See if the duplicate method works
#my $wikiPageCopy = $wikipage->duplicate();
#isa_ok($wikiPageCopy, 'WebGUI::Asset::WikiPage');
#my $thirdVersionTag = WebGUI::VersionTag->new($session,$wikiPageCopy->get("tagId"));


#TODO: {
#    local $TODO = "Tests to make later";
#    ok(0, 'Lots and lots to do');
#}
#vim:ft=perl
