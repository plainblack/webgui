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
#

use strict;
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
# put your tests here

my $storage;
my $e;
my $address;

#######################################################################
#
# new
#
#######################################################################

eval { $address = WebGUI::Shop::Address->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'new takes exception to not giving it an address book');
cmp_deeply(
    $e,
    methods(
        error    => 'Need an address book.',
        expected => 'WebGUI::Shop::AddressBook',
        got      => '',
        param    => undef,
    ),
    '... parameter check',
);

eval { $address = WebGUI::Shop::Address->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'new takes exception to giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error    => 'Need an address book.',
        expected => 'WebGUI::Shop::AddressBook',
        got      => 'WebGUI::Session',
        param    => $session,
    ),
    '... parameter check',
);

$session->user({userId => 3});

my $book  = WebGUI::Shop::AddressBook->new($session);
my $book2 = WebGUI::Shop::AddressBook->new($session);
WebGUI::Test->addToCleanup($book, $book2);

$address = WebGUI::Shop::Address->new($book, {});
isa_ok($address, 'WebGUI::Shop::Address', 'new returns an Address object with an empty hashref');

#######################################################################
#
# addressBook
#
#######################################################################

cmp_deeply(
    $address->addressBook,
    $book,
    'The address has a reference back to the book used to create it'
);

#######################################################################
#
# getId
#
#######################################################################

ok( $session->id->valid($address->getId), 'Address has a valid GUID');

#######################################################################
#
# get
#
#######################################################################

ok( $session->id->valid($address->getId), 'Address has a valid GUID');
is($address->getId, $address->get('addressId'), 'getId is an alias for get addressId');
cmp_deeply(
    $address->get,
    {
        label        => '',
        firstName    => '',
        lastName     => '',
        address1     => '',
        address2     => '',
        address3     => '',
        city         => '',
        state        => '',
        country      => '',
        code         => '',
        phoneNumber  => '',
        email        => '',
        organization => '',
        addressId    => ignore(), #checked elsewhere
        addressBookId  => $book->getId,
        addressBook  => $book,
        isProfile   => bool(0),
    },
    'get the whole thing and check a new, blank object'
);

my $addressGuts = $address->get();
$addressGuts->{'label'} = 'hacked';
is($address->get('label'), '', 'get returns a safe copy of the hash');

#######################################################################
#
# update
#
#######################################################################

$address->update({ label => 'home'});
is($address->get('label'), 'home', 'update: updates the object properties cache');
$address->update({ address1 => 'Shawshank Prison', 'state' => 'Maine'});
is($address->get('address1'), 'Shawshank Prison', '... updates the object properties cache for more than one key');
is($address->get('state'), 'Maine', '... updates the object properties cache for more than one key');

$address->update({ addressBookId => $book2->getId });
is($address->get('addressBookId'), $book2->getId, '... addressBookId can be updated');
##Restore it back to normal for downstream tests;
$address->update({ addressBookId => $book->getId });

#######################################################################
#
# new
#
#######################################################################

eval { $address = WebGUI::Shop::Address->new($book, 'neverAnId'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'new takes exception to not giving it a bad address instanciate');
cmp_deeply(
    $e,
    methods(
        error    => 'Address not found.',
        id    => 'neverAnId',
    ),
    'new takes exception to giving it a bad address to instanciate',
);

TODO: {
    local $TODO = 'More tests for new';
    ok(0, 'Make a second address book, add an address to it, then try to call a valid address from the wrong book');
}

my $addressCopy = WebGUI::Shop::Address->new($book, $address->getId);
cmp_deeply(
    $address,
    $addressCopy,
    'new: gets an exact copy of the object from the db.  Also checks that update writes to the db correctly.'
);

#######################################################################
#
# delete
#
#######################################################################

$address->delete;
my $check = $session->db->quickScalar('select count(*) from address where addressId=?',[$address->getId]);
is( $check, 0, 'delete worked');

done_testing;
