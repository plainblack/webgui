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
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Exception::Class;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Asset::Sku::Product;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 45;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::Shelf';
my $loaded = use_ok($class);

my $storage;
my ($e, $failure);
my $shelf;

SKIP: {

    skip "Unable to load module $class", $tests unless $loaded;

    $shelf = WebGUI::Asset->getRoot($session)->addChild({className => $class});

    #######################################################################
    #
    # import
    #
    #######################################################################

    eval { $shelf->importProducts(); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'importProducts: error handling for an undefined path to file');
    is($e->error, 'Must provide the path to a file', 'importProducts: error handling for an undefined path to file');

    eval { $shelf->importProducts('/path/to/nowhere'); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidFile', 'importProducts: error handling for file that does not exist in the filesystem');
    is($e->error, 'File could not be found', 'importProducts: error handling for file that does not exist in the filesystem');
    cmp_deeply(
        $e,
        methods(
            brokenFile => '/path/to/nowhere',
        ),
        'importTaxData: error handling for file that does not exist in the filesystem',
    );

    my $productsFile = WebGUI::Test->getTestCollateralPath('productTables/goodProductTable.csv');

    SKIP: {
        skip 'Root will cause this test to fail since it does not obey file permissions', 3
            if $< == 0;

        my $originalChmod = (stat $productsFile)[2];
        chmod oct(0000), $productsFile;

        eval { $shelf->importProducts($productsFile); };
        $e = Exception::Class->caught();
        isa_ok($e, 'WebGUI::Error::InvalidFile', 'importProducts: error handling for file that cannot be read');
        is($e->error, 'File is not readable', 'importProducts: error handling for file that that cannot be read');
        cmp_deeply(
            $e,
            methods(
                brokenFile => $productsFile,
            ),
            'importProducts: error handling for file that that cannot be read',
        );

        chmod $originalChmod, $productsFile;

    }

    $failure=0;
    eval {
        $failure = $shelf->importProducts(
            WebGUI::Test->getTestCollateralPath('productTables/missingHeaders.csv'),
        );
    };
    ok (!$failure, 'Product data is not imported when headers are missing');
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidFile', 'importProducts: a file with a missing header column');
    cmp_deeply(
        $e,
        methods(
            error      => 'Bad header found in the CSV file',
            brokenFile => WebGUI::Test->getTestCollateralPath('productTables/missingHeaders.csv'),
        ),
        'importProducts: error handling for a file with a missing header',
    );

    $failure=0;
    eval {
        $failure = $shelf->importProducts(
            WebGUI::Test->getTestCollateralPath('productTables/badHeaders.csv'),
        );
    };
    ok (!$failure, 'Product data is not imported when the headers are wrong');
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidFile', 'importProducts: a file with bad headers');
    cmp_deeply(
        $e,
        methods(
            error      => 'Bad header found in the CSV file',
            brokenFile => WebGUI::Test->getTestCollateralPath('productTables/badHeaders.csv'),
        ),
        'importProducts: error handling for a file with a missing header',
    );

    my $pass=0;
    $pass = $shelf->importProducts(
        WebGUI::Test->getTestCollateralPath('productTables/goodProductTable.csv'),
    );
    ok($pass, 'Products imported');

    my $count = $session->db->quickScalar('select count(*) from Product');
    is($count, 2, 'two products were imported');

    my $soda = WebGUI::Asset::Sku->newBySku($session, 'soda');
    isa_ok($soda, 'WebGUI::Asset::Sku::Product');
    is($soda->getTitle(), 'Sweet Soda-bottled in Oregon', 'Title set correctly for soda');
    my $sodaCollateral = $soda->getAllCollateral('variantsJSON');
    cmp_deeply(
        $sodaCollateral,
        [
            {
                varSku    => 'soda-sweet',
                shortdesc => 'Sweet Soda',
                price     => 0.95,
                weight    => 0.95,
                quantity  => 500,
                variantId => ignore(),
            },
        ],
        'collateral set correctly for soda'
    );

    my $shirt = WebGUI::Asset::Sku->newBySku($session, 't-shirt');
    isa_ok($shirt, 'WebGUI::Asset::Sku::Product');
    is($shirt->getTitle(), 'Colored T-Shirts', 'Title set correctly for t-shirt');
    my $shirtCollateral = $shirt->getAllCollateral('variantsJSON');
    cmp_deeply(
        $shirtCollateral,
        [
            {
                varSku    => 'red-t-shirt',
                shortdesc => 'Red T-Shirt',
                price     => '5.00',
                weight    => '1.33',
                quantity  => '1000',
                variantId => ignore(),
            },
            {
                varSku    => 'blue-t-shirt',
                shortdesc => 'Blue T-Shirt',
                price     => '5.25',
                weight    => '1.33',
                quantity  => '2000',
                variantId => ignore(),
            },
        ],
        'collateral set correctly for shirt'
    );

    #######################################################################
    #
    # export
    #
    #######################################################################

    my $productsOut = $shelf->exportProducts();
    isa_ok($productsOut, 'WebGUI::Storage', 'exportProducts returns a Storage object');
    is(scalar @{ $productsOut->getFiles }, 1, 'The storage contains just 1 file...');
    is(scalar $productsOut->getFiles->[0], 'siteProductData.csv', '...with the correct filename');
    my $productData = $productsOut->getFileContentsAsScalar($productsOut->getFiles->[0]);
    my @productData = split /\n/, $productData;
    is(scalar @productData, 4, 'productData should have 4 entries, 1 header + 3 data');
    is($productData[0], 'mastersku,title,varSku,shortdescription,price,weight,quantity', 'header line is okay');
    @productData = map { [ WebGUI::Text::splitCSV($_) ] } @productData[1..3];
    my ($sodas, $shirts) = ([], []);
    foreach my $productData (@productData) {
        if ($productData->[0] eq 'soda') {
            push @{ $sodas }, $productData;
        }
        elsif ($productData->[0] eq 't-shirt') {
            push @{ $shirts }, $productData;
        }
    }
    is(scalar @{ $sodas },  1, 'just 1 soda');
    is(scalar @{ $shirts }, 2, '2 shirts');

    cmp_deeply(
        $sodas,
        [ ['soda', 'Sweet Soda-bottled in Oregon',
           'soda-sweet', 'Sweet Soda', 0.95, 0.95, 500] ],
        'soda data is okay'
    );

    #######################################################################
    #
    # import, part 2
    #
    #######################################################################

    $pass=0;
    $pass = $shelf->importProducts(
        WebGUI::Test->getTestCollateralPath('productTables/secondProductTable.csv'),
    );
    ok($pass, 'Products imported for the second time');

    $count = $session->db->quickScalar('select count(*) from Product');
    is($count, 3, 'three products were imported');

    $soda = WebGUI::Asset::Sku->newBySku($session, 'soda');
    $sodaCollateral = $soda->getAllCollateral('variantsJSON');
    cmp_deeply(
        $sodaCollateral,
        [
            {
                varSku    => 'soda-sweet',
                shortdesc => 'Sweet Soda',
                price     => '1.00',
                weight    => 0.85,
                quantity  => 500,
                variantId => ignore(),
            },
        ],
        'collateral updated correctly for soda'
    );

    $shirt = WebGUI::Asset::Sku->newBySku($session, 't-shirt');
    $shirtCollateral = $shirt->getAllCollateral('variantsJSON');
    cmp_deeply(
        $shirtCollateral,
        [
            {
                varSku    => 'red-t-shirt',
                shortdesc => 'Red T-Shirt',
                price     => '5.00',
                weight    => '1.33',
                quantity  => '500',
                variantId => ignore(),
            },
            {
                varSku    => 'blue-t-shirt',
                shortdesc => 'Blue T-Shirt',
                price     => '5.25',
                weight    => '1.33',
                quantity  => '2000',
                variantId => ignore(),
            },
        ],
        'collateral updated correctly for shirt'
    );

    my $record = WebGUI::Asset::Sku->newBySku($session, 'classical-records-1');
    isa_ok($record, 'WebGUI::Asset::Sku::Product');
    my $recordCollateral = $record->getAllCollateral('variantsJSON');
    cmp_deeply(
        $recordCollateral,
        [
            {
                varSku    => 'track-16',
                shortdesc => 'Track 16',
                price     => '3.25',
                weight    => '0.00',
                quantity  => 50,
                variantId => ignore(),
            },
        ],
        'collateral set correctly for classical record'
    );

    #######################################################################
    #
    # import, part 3
    #
    #######################################################################

    $pass=0;
    $pass = $shelf->importProducts(
        WebGUI::Test->getTestCollateralPath('productTables/thirdProductTable.csv'),
    );
    ok($pass, 'Products imported for the third time');

    $count = $session->db->quickScalar('select count(*) from Product');
    is($count, 3, 'still have 3 products, nothing new added');

    $soda = WebGUI::Asset::Sku->newBySku($session, 'soda');
    is($soda->getTitle(), 'Sweet Soda-totally organic', 'Title updated correctly for soda');
    $shirt = WebGUI::Asset::Sku->newBySku($session, 't-shirt');
    $shirtCollateral = $shirt->getAllCollateral('variantsJSON');
    cmp_deeply(
        $shirtCollateral,
        [
            {
                varSku    => 'red-t-shirt',
                shortdesc => 'Red T-Shirt',
                price     => '5.00',
                weight    => '1.33',
                quantity  => '500',
                variantId => ignore(),
            },
            {
                varSku    => 'blue-t-shirt',
                shortdesc => 'Blue T-Shirt',
                price     => '5.25',
                weight    => '1.33',
                quantity  => '2000',
                variantId => ignore(),
            },
        ],
        'collateral updated correctly for shirt'
    );

    $record = WebGUI::Asset::Sku->newBySku($session, 'classical-records-1');
    $recordCollateral = $record->getAllCollateral('variantsJSON');
    cmp_deeply(
        $recordCollateral,
        [
            {
                varSku    => 'track-16',
                shortdesc => 'Track 16',
                price     => '3.25',
                weight    => '0.00',
                quantity  => 50,
                variantId => ignore(),
            },
            {
                varSku    => 'track-9',
                shortdesc => 'Track 9',
                price     => '3.25',
                weight    => '0.00',
                quantity  => 55,
                variantId => ignore(),
            },
        ],
        'collateral added correctly for classical record'
    );

}

#----------------------------------------------------------------------------
# Cleanup
END {
    if (defined $shelf and ref $shelf eq $class) {
        $shelf->purge;
    }
}
