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
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset::Wobject::Shelf;
use WebGUI::AssetHelper::Product::ImportCSV;
use Test::MockObject::Extends;
use WebGUI::Fork;
use File::Temp;
use File::Copy;


#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $root  = WebGUI::Test->asset;
my $class = 'WebGUI::Asset::Wobject::Shelf';
my $shelf = $root->addChild({className => $class});

#######################################################################
#
# import
#
#######################################################################

my $helper  = WebGUI::AssetHelper::Product::ImportCSV->new( 
    id => 'importProducts',
    session => $session,
    asset => $shelf,
);
my $importProducts  = \&WebGUI::AssetHelper::Product::ImportCSV::importProducts;
my $process = Test::MockObject::Extends->new( WebGUI::Fork->create( $session ) );
WebGUI::Test->addToCleanup( sub { $process->delete } );

eval { $importProducts->( $process, { assetId => $helper->asset->getId } ); };
my $e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'importProducts: error handling for an undefined path to file');
is($e->error, 'Must provide the path to a file', 'importProducts: error handling for an undefined path to file');

eval { $importProducts->( $process, { assetId => $helper->asset->getId, filePath => '/path/to/nowhere' } ); };
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

    my (undef, $productsTempFile) = File::Temp::tempfile('productTableXXXX', OPEN => 0, TMPDIR => 1, SUFFIX => '.csv');
    File::Copy::copy($productsFile, $productsTempFile);

    chmod oct(0000), $productsTempFile;

    eval { $shelf->importProducts($process, { assetId => $helper->asset->getId, filePath => $productsTempFile } ); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidFile', 'importProducts: error handling for file that cannot be read') || skip 'invalid error thrown', 2;
    is($e->error, 'File is not readable', 'importProducts: error handling for file that that cannot be read');
    cmp_deeply(
        $e,
        methods(
            brokenFile => $productsTempFile,
        ),
        'importProducts: error handling for file that that cannot be read',
    );
    unlink $productsTempFile;
}

my $failure=0;
eval {
    $failure = $importProducts->( $process, {
        assetId     => $helper->asset->getId,
        filePath    => WebGUI::Test->getTestCollateralPath('productTables/missingHeaders.csv'),
    } );
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
    $failure = $importProducts->( $process, {
            assetId     => $helper->asset->getId,
            filePath    => WebGUI::Test->getTestCollateralPath('productTables/badHeaders.csv'),
        }
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
$pass = $importProducts->( $process, {
    assetId => $helper->asset->getId,
    filePath => WebGUI::Test->getTestCollateralPath('productTables/goodProductTable.csv'),
} );
ok($pass, 'Products imported');

my $count = $session->db->quickScalar('select count(*) from Product');
is($count, 2, 'two products were imported');

my $soda = WebGUI::Asset::Sku->newBySku($session, 'soda');
isa_ok($soda, 'WebGUI::Asset::Sku::Product');
is($soda->getTitle(), 'Sweet Soda-bottled in Oregon', 'Title set correctly for soda');
is($soda->get('url'), 'sweet-soda-bottled-in-oregon', 'URL for new product from the title');
is($soda->get('menuTitle'), $soda->getTitle, 'menuTitle is the same as title');
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
# import, part 2
#
#######################################################################

$pass=0;
$pass = $importProducts->( $process, {
    assetId => $helper->asset->getId,
    filePath => WebGUI::Test->getTestCollateralPath('productTables/secondProductTable.csv'),
});
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
$pass = $importProducts->( $process, {
    assetId => $helper->asset->getId,
    filePath => WebGUI::Test->getTestCollateralPath('productTables/thirdProductTable.csv'),
} );
ok($pass, 'Products imported for the third time');

$count = $session->db->quickScalar('select count(*) from Product');
is($count, 3, 'still have 3 products, nothing new added');

$soda = WebGUI::Asset::Sku->newBySku($session, 'soda');
is($soda->getTitle(),       'Sweet Soda-totally organic',   'Title updated correctly for soda');
is($soda->get('menuTitle'), 'Sweet Soda-totally organic',   'menuTitle updated correctly for soda');
is($soda->get('url'), 'sweet-soda-bottled-in-oregon', 'URL for updated product from the original title, not the updated title');
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

$shelf->purge;
undef $shelf;

$record = eval { WebGUI::Asset::Sku->newBySku($session, 'classical-records-1'); };
ok(Exception::Class->caught(), 'deleting a shelf deletes all products beneath it');

#######################################################################
#
# import, quoted headers and fields
#
#######################################################################

my $shelf2 = $root->addChild({className => $class});
$helper = WebGUI::AssetHelper::Product::ImportCSV->new( 
    session => $session,
    asset   => $shelf2,
    id      => 'importProducts',
);

$pass = 0;
eval {
    $pass = $importProducts->( $process, {
        assetId => $helper->asset->getId,
        filePath => WebGUI::Test->getTestCollateralPath('productTables/quotedTable.csv'),
    } );
};
ok($pass, 'Able to load a table with quoted fields');
$e = Exception::Class->caught();
is($e, '', 'No exception thrown on a file with quoted fields');
is($shelf2->getChildCount, 3, 'imported 3 children skus for shelf2 with quoted fields');

$shelf2->purge;
undef $shelf2;

#######################################################################
#
# import, windows line endings
#
#######################################################################

$shelf2 = WebGUI::Asset->getRoot($session)->addChild({className => $class});
$helper = WebGUI::AssetHelper::Product::ImportCSV->new( 
    session => $session,
    asset   => $shelf2,
    id      => 'importProducts',
);

$pass = 0;
eval {
    $pass = $importProducts->( $process, {
        assetId     => $helper->asset->getId,
        filePath => WebGUI::Test->getTestCollateralPath('productTables/windowsTable.csv'),
    } );
};
ok($pass, 'Able to load a table with windows style newlines');
$e = Exception::Class->caught();
is($e, '', 'No exception thrown on a file with quoted fields');
is($shelf2->getChildCount, 2, 'imported 2 children skus for shelf2 with windows line endings fields');

$shelf2->purge;
undef $shelf2;

#######################################################################
#
# import, old sku column header
#
#######################################################################

$shelf2 = WebGUI::Test->asset->addChild({className => $class});
$helper = WebGUI::AssetHelper::Product::ImportCSV->new( 
    session => $session,
    asset   => $shelf2,
    id      => 'importProducts',
);

$pass = 0;
eval {
    $pass = $importProducts->( $process, {
        assetId => $helper->asset->getId,
        filePath => WebGUI::Test->getTestCollateralPath('productTables/windowsTable.csv'),
    });
};
ok($pass, 'Able to load a table with old style, sku instead of varSku');
$e = Exception::Class->caught();
is($e, '', 'No exception thrown on a file old headers');
is($shelf2->getChildCount, 2, 'imported 2 children skus for shelf2 with old headers');

$shelf2->purge;
undef $shelf2;

#######################################################################
#
# import, funky data in the price column
#
#######################################################################

my $shelf3 = WebGUI::Test->asset->addChild({className => $class});
$helper = WebGUI::AssetHelper::Product::ImportCSV->new( 
    session => $session,
    asset   => $shelf3,
    id      => 'importProducts',
);

$pass = 0;
eval {
    $pass = $importProducts->( $process, {
        assetId => $helper->asset->getId,
        filePath => WebGUI::Test->getTestCollateralPath('productTables/dollarsigns.csv'),
    });
};
ok($pass, 'Able to load a table with odd characters in the price column');
$e = Exception::Class->caught();
is($e, '', '... no exception thrown');
is($shelf3->getChildCount, 1, '...imported 1 child sku for shelf3 with old headers');

my $sign = $shelf3->getFirstChild();
my $signCollateral = $sign->getAllCollateral('variantsJSON');
cmp_deeply(
    $signCollateral,
    [
        {
            varSku    => 'dollar signs',
            shortdesc => 'Silver Dollar Signs',
            price     => '5.00',
            weight    => '0.33',
            quantity  => '1000',
            variantId => ignore(),
        },
    ],
    'collateral set correctly for sign'
);

$shelf3->purge;
undef $shelf3;

done_testing();
#vim:ft=perl
