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
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Exception::Class;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Shop::Cart;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::TaxDriver::Generic;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({userId => 3});

#----------------------------------------------------------------------------
# Tests

my $addExceptions = getAddExceptions($session);

my $tests = 78 + 2*scalar(@{$addExceptions});
plan tests => $tests;

#----------------------------------------------------------------------------
# put your tests here


my ($taxableDonation, $taxFreeDonation);

#######################################################################
#
# new
#
#######################################################################

my $taxer = WebGUI::Shop::TaxDriver::Generic->new($session);

isa_ok($taxer, 'WebGUI::Shop::TaxDriver::Generic');

isa_ok($taxer->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $taxer->session->getId, 'session method returns OUR session object');

#######################################################################
#
# getItems
#
#######################################################################

my $taxIterator = $taxer->getItems;

isa_ok($taxIterator, 'WebGUI::SQL::ResultSet');

is($taxIterator->rows, 0, 'WebGUI ships with no predefined tax data');

#######################################################################
#
# add
#
#######################################################################

my $e;

eval{$taxer->add()};

$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'add: correct type of exception thrown for missing hashref');
is($e->error, 'Must pass in a hashref of params', 'add: correct message for a missing hashref');

foreach my $inputSet ( @{ $addExceptions } ){
    eval{$taxer->add($inputSet->{args})};
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'add: '.$inputSet->{comment});
    cmp_deeply(
        $e,
        methods(
            error => $inputSet->{error},
            param => $inputSet->{param},
        ),
        'add: '.$inputSet->{comment},
    );
}

my $taxData = {
    country => 'USA',
    state   => 'OR',
    taxRate => '0',
};

my $oregonTaxId = $taxer->add($taxData);

ok($session->id->valid($oregonTaxId), 'add method returns a valid GUID');

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 1, 'add added only 1 row to the tax table');

my $addedData = $taxIterator->hashRef;
$taxData->{taxId} = $oregonTaxId;
$taxData->{city} = undef;
$taxData->{code} = undef;

cmp_deeply($addedData, $taxData, 'add put the right data into the database for Oregon');

$taxData = {
    country => 'USA',
    state   => 'Wisconsin',
    city    => 'Madcity',
    code    => '53702',
    taxRate => '5',
};

my $wisconsinTaxId = $taxer->add($taxData);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 2, 'add added another row to the tax table');

$taxData = {
    country => 'USA',
    state   => 'Oregon',
    taxRate => '0.1',
};

my $dupId = $taxer->add($taxData);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 3, 'add permits adding duplicate information.');

##Madison zip codes:
##53701-53709
##city rate: 0.5%
##Wisconsin rate 5.0%

#######################################################################
#
# getAllItems
#
#######################################################################

my $expectedTaxData = [
        {
            country => 'USA',
            state   => 'OR',
            city    => undef,
            code    => undef,
            taxRate => 0,
        },
        {
            country => 'USA',
            state   => 'Wisconsin',
            city    => 'Madcity',
            code    => '53702',
            taxRate => 5,
        },
        {
            country => 'USA',
            state   => 'Oregon',
            city    => undef,
            code    => undef,
            taxRate => 0.1,
        },
];

cmp_bag(
    $taxer->getAllItems,
    $expectedTaxData,
    'getAllItems returns the whole set of tax data',
);

#######################################################################
#
# delete
#
#######################################################################

eval{$taxer->delete()};
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'delete: error handling for missing hashref');
is($e->error, 'Must pass in a hashref of params', 'delete: error message for missing hashref');

eval{$taxer->delete({})};
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'delete: error handling for missing key in hashref');
is($e->error, 'Hash ref must contain a taxId key with a defined value', 'delete: error message for missing key in hashref');

eval{$taxer->delete({ taxId => undef })};
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'delete: error handling for an undefined taxId value');
is($e->error, 'Hash ref must contain a taxId key with a defined value', 'delete: error message for an undefined taxId value');

$taxer->delete({ taxId => $dupId });
$taxIterator = $taxer->getItems;
is($taxIterator->rows, 2, 'One row was deleted from the tax table, even though another row has duplicate information');

$taxer->delete({ taxId => $oregonTaxId });
$taxIterator = $taxer->getItems;
is($taxIterator->rows, 1, 'Another row was deleted from the tax table');

$taxer->delete({ taxId => $session->id->generate });

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 1, 'No rows were deleted from the table since the requested id does not exist');
is($taxIterator->hashRef->{taxId}, $wisconsinTaxId, 'The correct tax information was deleted');

########################################################################
##
## exportTaxData
##
########################################################################

my $storage = $taxer->exportTaxData();
WebGUI::Test->addToCleanup($storage);
isa_ok($storage, 'WebGUI::Storage', 'exportTaxData returns a WebGUI::Storage object');
is(substr($storage->getPathFrag, 0, 5), 'temp/', 'The storage object is in the temporary area');
ok(-e $storage->getPath('siteTaxData.csv'), 'siteTaxData.csv file exists in the storage object');
cmp_ok($storage->getFileSize('siteTaxData.csv'), '!=', 0, 'CSV file is not empty');
my @fileLines = split /\n+/, $storage->getFileContentsAsScalar('siteTaxData.csv');
#my @fileLines = ();
my @header = WebGUI::Text::splitCSV($fileLines[0]);
my @expectedHeader = qw/country state city code taxRate/;
cmp_deeply(\@header, \@expectedHeader, 'exportTaxData: header line is correct');
my @row1 = WebGUI::Text::splitCSV($fileLines[1]);
my $wiData = $taxer->getItems->hashRef;
##Need to ignore the taxId from the database
cmp_bag([ @{ $wiData }{ @expectedHeader } ], \@row1, 'exportTaxData: first line of data is correct');

my $newTaxId = $taxer->add({
    country => 'USA|U.S.A.',
    state   => 'washington|WA',
    taxRate => '7',
    code    => '',
    city    => '',
});
$taxer->delete({taxId => $wisconsinTaxId});
$storage = $taxer->exportTaxData();
@fileLines = split /\n+/, $storage->getFileContentsAsScalar('siteTaxData.csv');
my @row1 = WebGUI::Text::splitCSV($fileLines[1]);
my $wiData = $taxer->getItems->hashRef;
##Need to ignore the taxId from the database
cmp_bag([ @{ $wiData }{ @expectedHeader } ], \@row1, 'exportTaxData: first line of data is correct');

$taxer->delete({taxId => $newTaxId});

#######################################################################
#
# import
#
#######################################################################

eval { $taxer->importTaxData(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'importTaxData: error handling for an undefined taxId value');
is($e->error, 'Must provide the path to a file', 'importTaxData: error handling for an undefined taxId value');

eval { $taxer->importTaxData('/path/to/nowhere'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidFile', 'importTaxData: error handling for file that does not exist in the filesystem');
is($e->error, 'File could not be found', 'importTaxData: error handling for file that does not exist in the filesystem');
cmp_deeply(
    $e,
    methods(
        brokenFile => '/path/to/nowhere',
    ),
    'importTaxData: error handling for file that does not exist in the filesystem',
);

my $taxFile = WebGUI::Test->getTestCollateralPath('taxTables/goodTaxTable.csv');

SKIP: {
    skip 'Root will cause this test to fail since it does not obey file permissions', 3
        if $< == 0;

    my $originalChmod = (stat $taxFile)[2];
    chmod oct(0000), $taxFile;

    eval { $taxer->importTaxData($taxFile); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidFile', 'importTaxData: error handling for file that cannot be read');
    is($e->error, 'File is not readable', 'importTaxData: error handling for file that that cannot be read');
    cmp_deeply(
        $e,
        methods(
            brokenFile => $taxFile,
        ),
        'importTaxData: error handling for file that that cannot be read',
    );

    chmod $originalChmod, $taxFile;

}

my $expectedTaxData = [
        {
            country => 'USA',
            state   => '',
            city    => '',
            code    => '',
            taxRate => 0,
        },
        {
            country => 'USA',
            state   => 'Wisconsin',
            city    => '',
            code    => '',
            taxRate => 5,
        },
        {
            country => 'USA',
            state   => 'Wisconsin',
            city    => 'Madison',
            code    => '53701',
            taxRate => 0.5,
        },
];

ok(
    $taxer->importTaxData(
        $taxFile
    ),
    'Good tax data inserted',
);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 3, 'import: Old data deleted, new data imported');
cmp_bag(
    $taxer->getAllItems,
    $expectedTaxData,
    'Correct data inserted.',
);

ok(
    $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/orderedTaxTable.csv')
    ),
    'Reordered tax data inserted',
);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 3, 'import: Old data deleted, new data imported again');
cmp_bag(
    $taxer->getAllItems,
    $expectedTaxData,
    'Correct data inserted, with CSV in different columnar order.',
);

ok(
    $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/commentedTaxTable.csv')
    ),
    'Commented tax data inserted',
);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 3, 'import: Old data deleted, new data imported the third time');
cmp_bag(
    $taxer->getAllItems,
    $expectedTaxData,
    'Correct data inserted, with comments in the CSV file',
);

ok(
    ! $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/emptyTaxTable.csv')
    ),
    'Empty tax data not inserted',
);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 3, 'import: Old data still exists and was not deleted');

my $failure;
eval {
    $failure = $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/badTaxTable.csv')
    );
};
ok (!$failure, 'Tax data not imported');
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidFile', 'importTaxData: a file with an error on 1 line');
cmp_deeply(
    $e,
    methods(
        error      => 'Error found in the CSV file',
        brokenFile => WebGUI::Test->getTestCollateralPath('taxTables/badTaxTable.csv'),
        brokenLine => 1,
    ),
    'importTaxData: error handling for file with errors in the CSV data',
);

eval {
    $failure = $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/missingHeaders.csv')
    );
};
ok (!$failure, 'Tax data not imported when headers are missing');
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidFile', 'importTaxData: a file with a missing header column');
cmp_deeply(
    $e,
    methods(
        error      => 'Bad header found in the CSV file',
        brokenFile => WebGUI::Test->getTestCollateralPath('taxTables/missingHeaders.csv'),
    ),
    'importTaxData: error handling for a file with a missing header',
);

eval {
    $failure = $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/badHeaders.csv')
    );
};
ok (!$failure, 'Tax data not imported when headers are wrong');
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidFile', 'importTaxData: a file with a bad header column');
cmp_deeply(
    $e,
    methods(
        error      => 'Bad header found in the CSV file',
        brokenFile => WebGUI::Test->getTestCollateralPath('taxTables/badHeaders.csv'),
    ),
    'importTaxData: error handling for a file with a bad header',
);

ok(
    $taxer->importTaxData(
        WebGUI::Test->getTestCollateralPath('taxTables/alternations.csv')
    ),
    'Tax data with alternations inserted',
);

my $altData = $taxer->getItems->hashRef;  ##Just 1 row
cmp_deeply(
    $altData,
    {
        taxId => ignore,
        country => q{U.S.A.,USA},
        state   => q{WI,Wisconsin},
        city    => q{Madison},
        code    => 53701,
        taxRate => 0.5,
    },
    'import: Data correctly loaded with alternations'
);

#######################################################################
#
# getTaxRates
#
#######################################################################

##Set up the tax information
$taxer->importTaxData(
    WebGUI::Test->getTestCollateralPath('taxTables/largeTaxTable.csv')
),
my $book = WebGUI::Shop::AddressBook->create($session);
WebGUI::Test->addToCleanup($book);
my $taxingAddress = $book->addAddress({
    label => 'taxing',
    city  => 'Madison',
    state => 'WI',
    code  => '53701',
    country => 'USA',
});
my $taxFreeAddress = $book->addAddress({
    label => 'no tax',
    city  => 'Portland',
    state => 'OR',
    code  => '97123',
    country => 'USA',
});
my $alternateAddress = $book->addAddress({
    label => 'using alternations',
    city  => 'Los Angeles',
    state => 'CalifornIA',
    code  => '92801',
    country => 'USA',
});

eval { $taxer->getTaxRates(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'calculate: error handling for not sending a cart');
cmp_deeply(
    $e,
    methods(
        error => 'Need an address.',
        got   => '',
        expected => 'WebGUI::Shop::Address',
    ),
    'importTaxData: error handling for file that does not exist in the filesystem',
);

cmp_deeply(
    $taxer->getTaxRates($taxingAddress),
    [0, 5, 0.5],
    'getTaxRates: return correct data for a state with tax data'
);

cmp_deeply(
    $taxer->getTaxRates($taxFreeAddress),
    [0,0],
    'getTaxRates: return correct data for a state with no tax data'
);

cmp_deeply(
    $taxer->getTaxRates($alternateAddress),
    [0.0, 8.25], #Hits USA and Los Angeles, California using the alternate spelling of the state
    'getTaxRates: return correct data for a state when the address has alternations'
);

#######################################################################
#
# calculate
#
#######################################################################

eval { $taxer->getTaxRate(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'getTaxRate: error handling for not sending a sku');
is($e->error, 'Must pass in a WebGUI::Asset::Sku object', 'getTaxRate: error handling for not sending a sku');

##Build a cart, add some Donation SKUs to it.  Set one to be taxable.

my $cart = WebGUI::Shop::Cart->newBySession($session);
WebGUI::Test->addToCleanup($cart);

#    is($taxer->calculate($cart), 0, 'calculate returns 0 if there is no shippingAddressId in the cart');

#    $cart->update({ shippingAddressId => $taxingAddress->getId});

##Set up the tax information
$taxer->importTaxData(
    WebGUI::Test->getTestCollateralPath('taxTables/largeTaxTable.csv')
),

$taxableDonation = WebGUI::Asset->getRoot($session)->addChild({
    className => 'WebGUI::Asset::Sku::Donation',
    title     => 'Taxable donation',
    defaultPrice => 100.00,
});
WebGUI::Test->addToCleanup($taxableDonation);

is($taxer->getTaxRate($taxableDonation), 0, 'calculate returns 0 if there is no shippingAddressId in the cart');


#    $cart->addItem($taxableDonation);

#   foreach my $item (@{ $cart->getItems }) {
#        $item->setQuantity(1);
#    }

my $tax = $taxer->getTaxRate( $taxableDonation, $taxingAddress );
is($tax, 5.5, 'calculate: simple tax calculation on 1 item in the cart');

$cart->update({ shippingAddressId => $taxFreeAddress->getId});
is($taxer->getTaxRate( $taxableDonation, $taxFreeAddress ), 0, 'calculate: simple tax calculation on 1 item in the cart, tax free location');

#    foreach my $item (@{ $cart->getItems }) {
#        $item->setQuantity(2);
#    }
#
#    $cart->update({ shippingAddressId => $taxingAddress->getId});
#    is($taxer->calculate($cart), 11, 'calculate: simple tax calculation on 1 item in the cart, qty 2');

$taxFreeDonation = WebGUI::Asset->getRoot($session)->addChild({
    className => 'WebGUI::Asset::Sku::Donation',
    title     => 'Tax Free Donation',
    defaultPrice => 100.00,
});
WebGUI::Test->addToCleanup($taxFreeDonation);
$taxFreeDonation->setTaxConfiguration( 'WebGUI::Shop::TaxDriver::Generic', {
    overrideTaxRate => 1,
    taxRateOverride => 0,
});

#    $cart->addItem($taxFreeDonation);

#    foreach my $item (@{ $cart->getItems }) {
#        $item->setQuantity(1);
#    }
is($taxer->getTaxRate( $taxFreeDonation, $taxingAddress), 0, 'getTaxRate: tax rate override should override tax derived from address');

#    my $remoteItem = $cart->addItem($taxableDonation);
#    $remoteItem->update({shippingAddressId => $taxFreeAddress->getId});
#
#    foreach my $item (@{ $cart->getItems }) {
#        $item->setQuantity(1);
#    }
#    is($taxer->calculate($cart), 5.5, 'calculate: simple tax calculation on 2 items in the cart, 1 without taxes, 1 shipped to a location with no taxes');

#######################################################################
#
# www_getTaxesAsJson
#
#######################################################################

$session->user({userId=>3});
my $json = $taxer->www_getTaxesAsJson();
ok($json, 'www_getTaxesAsJson returned something');
is($session->http->getMimeType, 'application/json', 'MIME type set to application/json');
my $jsonTax = JSON::from_json($json);
cmp_deeply(
    $jsonTax,
    {
        sort            => undef,
        startIndex      => 0,
        totalRecords    => 1778,
        recordsReturned => 25,
        dir             => 'asc',
        records         => array_each({
            taxId=>ignore,
            country => 'USA',
            state=>ignore,
            city=>ignore,
            code=>ignore,
            taxRate=>re('^\d+(\.\d+)?$')
        }),
    },
    'Check major elements of tax JSON',
);

TODO: {
    local $TODO = 'More getTaxesAsJson tests';
    ok(0, 'test group privileges to this method');
    ok(0, 'test startIndex variable');
    ok(0, 'test results form variable');
    ok(0, 'test keywords');
}

sub getAddExceptions {
    my $session = shift;
    my $inputValidion = [
        {
            args  => {},
            error => q{Missing required information.},
            param => q{country},
            comment => q{missing country},
        },
        {
            args  => {country => undef},
            error => q{Missing required information.},
            param => q{country},
            comment => q{undef country},
        },
        {
            args  => {country => ''},
            error => q{Missing required information.},
            param => q{country},
            comment => q{empty country},
        },
        {
            args  => {country => 'USA'},
            error => q{Missing required information.},
            param => q{taxRate},
            comment => q{missing taxRate},
        },
        {
            args  => {country => 'USA', taxRate => undef},
            error => q{Missing required information.},
            param => q{taxRate},
            comment => q{empty taxRate},
        },
    ];
}

#----------------------------------------------------------------------------
# Cleanup
END {
$session->db->write('delete from tax_generic_rates');
$storage->delete;


}
