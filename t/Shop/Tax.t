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
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 27;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Tax');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::Tax', $tests unless $loaded;

#######################################################################
#
# new
#
#######################################################################

my $taxer = WebGUI::Shop::Tax->new($session);

isa_ok($taxer, 'WebGUI::Shop::Tax');

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

eval{$taxer->add()};
like($@, qr{Must pass in a hashref},
    'add: error handling for missing hashref');

eval{$taxer->add({})};
like($@, qr{Hash ref must contain a field key with a defined value},
    'add: error handling for missing field hashref key');

my $taxData = {
    field   => undef,
};

eval{$taxer->add($taxData)};
like($@, qr{Hash ref must contain a field key with a defined value},
    'add: error handling for undefined field key');

$taxData->{field} = 'state';

eval{$taxer->add($taxData)};
like($@, qr{Hash ref must contain a value key with a defined value},
    'add: error handling for missing value key');

$taxData->{value} = undef;

eval{$taxer->add($taxData)};
like($@, qr{Hash ref must contain a value key with a defined value},
    'add: error handling for undefined value key');

$taxData->{value} = 'Oregon';

eval{$taxer->add($taxData)};
like($@, qr{Hash ref must contain a taxRate key with a defined value},
    'add: error handling for missing taxRate key');

$taxData->{taxRate} = undef;

eval{$taxer->add($taxData)};
like($@, qr{Hash ref must contain a taxRate key with a defined value},
    'add: error handling for undefined taxRate key');

my $taxData = {
    field   => 'state',
    value   => 'Oregon',
    taxRate => '0',
};

my $oregonTaxId = $taxer->add($taxData);

ok($session->id->valid($oregonTaxId), 'add method returns a valid GUID');

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 1, 'add added only 1 row to the tax table');

my $addedData = $taxIterator->hashRef;
$taxData->{taxId} = $oregonTaxId;

cmp_deeply($taxData, $addedData, 'add put the right data into the database for Oregon');

$taxData = {
    field   => 'state',
    value   => 'Wisconsin',
    taxRate => '5',
};

my $wisconsinTaxId = $taxer->add($taxData);

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 2, 'add added another row to the tax table');

$taxData = {
    field   => 'state',
    value   => 'Oregon',
    taxRate => '0.1',
};

eval {$taxer->add($taxData)};

ok($@, 'add threw an exception to having taxes in Oregon when they were defined as 0 initially');

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 2, 'add did not add another row since it would be a duplicate');

##Madison zip codes:
##53701-53709
##city rate: 0.5%
##Wisconsin rate 5.0%

#######################################################################
#
# delete
#
#######################################################################

eval{$taxer->delete()};
like($@, qr{Must pass in a hashref},
    'delete: error handling for missing hashref');

eval{$taxer->delete({})};
like($@, qr{Hash ref must contain a taxId key with a defined value},
    'delete: error handling for missing key in hashref');

eval{$taxer->delete({ taxId => undef })};
like($@, qr{Hash ref must contain a taxId key with a defined value},
    'delete: error handling for an undefined taxId value');

$taxer->delete({ taxId => $oregonTaxId });

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 1, 'One row was deleted from the tax table');

$taxer->delete({ taxId => $session->id->generate });

$taxIterator = $taxer->getItems;
is($taxIterator->rows, 1, 'No rows were deleted from the table since the requested id does not exist');
is($taxIterator->hashRef->{taxId}, $wisconsinTaxId, 'The correct tax information was deleted');

#######################################################################
#
# export
#
#######################################################################

$storage = $taxer->export();
isa_ok($storage, 'WebGUI::Storage', 'export returns a WebGUI::Storage object');
is($storage->{_part1}, 'temp', 'The storage object is in the temporary area');
ok(-e $storage->getPath('siteTaxData.csv'), 'siteTaxData.csv file exists in the storage object');

}


#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from tax');
    $storage->delete;
}
