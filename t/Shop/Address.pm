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
use Exception::Class;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::AddressBook;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 8;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Address');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::Address', $tests unless $loaded;
my $e;
my $address;

#######################################################################
#
# create
#
#######################################################################

eval { $address = WebGUI::Shop::Address->create(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'create takes exception to not giving it an address book');
cmp_deeply(
    $e,
    methods(
        error    => 'Need an address book.',
        expected => 'WebGUI::Shop::AddressBook',
        got      => '',
        param    => undef,
    ),
    'create takes exception to not giving it address book',
);

eval { $address = WebGUI::Shop::Address->create($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'create takes exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error    => 'Need an address book.',
        expected => 'WebGUI::Shop::AddressBook',
        got      => 'WebGUI::Session',
        param    => $session,
    ),
    'create takes exception to giving it a session variable',
);

my $book = WebGUI::Shop::AddressBook->create($session);

eval { $address = WebGUI::Shop::Address->create($book); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it address data');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a hash reference.',
        param    => undef,
    ),
    'create takes exception to giving it address data',
);

$address = WebGUI::Shop::Address->create($book, {});
isa_ok($address, 'WebGUI::Shop::Address', 'create returns an Address object with an empty hashref');

cmp_deeply(
    $address->addressBook,
    $book,
    'The address has a reference back to the book used to create it'
);

#######################################################################
#
# new
#
#######################################################################

}

END: {
    $session->db->write('delete from addressBook');
    $session->db->write('delete from address');
}
