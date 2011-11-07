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

use strict;
use Test::More;
use Test::Deep;
use Data::Dumper;
use Exception::Class;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Shop::AddressBook;
use JSON;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
#Create a temporary admin user
my $tempAdmin = WebGUI::User->create($session);
$tempAdmin->addToGroups(['3']);
WebGUI::Test->addToCleanup($tempAdmin);
$session->user({ userId => $tempAdmin->getId} );

#----------------------------------------------------------------------------
# put your tests here

my $storage;
my $e;
my $book;

#######################################################################
#
# new
#
#######################################################################

eval { $book = WebGUI::Shop::AddressBook->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a session.',
        expected => 'WebGUI::Session',
        got      => '',
    ),
    'new takes exception to not giving it a session object',
);

$session->user({userId => 3});
eval { $book = WebGUI::Shop::AddressBook->new($session, 'neverAGUID'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'new takes exception to not giving it an existing addressBookId');
cmp_deeply(
    $e,
    methods(
        error => 'No such address book.',
        id    => 'neverAGUID',
    ),
    'new takes exception to not giving it a addressBook Id',
);
$session->user({userId => 1});


eval { $book = WebGUI::Shop::AddressBook->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to making an address book for Visitor');
cmp_deeply(
    $e,
    methods(
        error    => 'Visitor cannot have an address book.',
    ),
    '... correct error message',
);

$session->user({userId => $tempAdmin->getId});
$book = WebGUI::Shop::AddressBook->new($session);
isa_ok($book, 'WebGUI::Shop::AddressBook', 'new returns the right kind of object');

isa_ok($book->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $book->session->getId, 'session method returns OUR session object');

ok($session->id->valid($book->getId), 'new makes a valid GUID style addressBookId');

is($book->get('userId'), $tempAdmin->getId, 'create uses $session->user to get the userid for this book');
is($book->userId, $tempAdmin->getId, '... testing direct accessor');

my $bookCount = $session->db->quickScalar('select count(*) from addressBook where addressBookId=?',[$book->getId]);
is($bookCount, 1, 'only 1 address book was created');

my $alreadyHaveBook = WebGUI::Shop::AddressBook->new($session);
isnt($book->getId, $alreadyHaveBook->getId, 'creating an addressbook, even when you already have one, always returns a new one');

#######################################################################
#
# getId
#
#######################################################################

is($book->getId, $book->get('addressBookId'), 'getId is a shortcut for ->get');

#######################################################################
#
# addAddress
#
#######################################################################

my $address1 = $book->addAddress({ label => q{Red's cell} });
isa_ok($address1, 'WebGUI::Shop::Address', 'addAddress returns an object');

my $address2 = $book->addAddress({ label => q{Norton's office} });

#######################################################################
#
# getAddresses
#
#######################################################################

my @addresses = @{ $book->getAddresses() };

cmp_bag(
    [ map { $_->getId } @addresses ],
    [$address1->getId, $address2->getId],
    'getAddresses returns all address objects for this book'
);

#######################################################################
#
# update
#
#######################################################################

$book->update({ lastShipId => $address1->getId, lastPayId => $address2->getId});

cmp_deeply(
    $book->get(),
    {
        userId           => ignore(),
        addressBookId    => ignore(),
        defaultAddressId => ignore(),
    },
    'update does not add new properties to the object'
);

my $bookClone = WebGUI::Shop::AddressBook->new($session, $book->getId);

delete $book->{_addressCache};
cmp_deeply(
    $bookClone,
    $book,
    'update updates the db, too'
);

#######################################################################
#
# getProfileAddress
#
#######################################################################

eval { $book->getProfileAddress };

$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'getProfileAddress takes exception to a profile address not being set');
cmp_deeply(
    $e,
    methods(
        error    => 'No profile address.',
    ),
    '... correct error message',
);

$address1->update({ isProfile => 1 });

my $profile_address = eval{ $book->getProfileAddress() };

is($profile_address->getId,$address1->getId,"getProfileAddress returns addresses tied to profiles");

#######################################################################
#
# www_editAddressSave
#
#######################################################################

my $address_info = {
    label           => 'Profile Label',
    addressId       => $address1->getId,
    firstName       => 'Andy',
    lastName        => 'Dufresne',
    address1        => '123 Shank Ave',
    address2        => 'Cell Block E',
    address3        => 'Cell 12',
    city            => 'Shawshank',
    state           => 'PA',
    code            => '11223',
    country         => 'US',
    phoneNumber     => '111-111-1111',
    email           => 'andy@shawshank.com',
    organization    => 'Shawshank'
};

$session->request->setup_body({
    %$address_info,
    callback        => q|{'url':''}|
});

$book->www_editAddressSave;

$address1 = $book->getAddress($address1->getId);

cmp_bag(
    [ map { $address1->get($_) } keys %$address_info ],
    [ values %$address_info ],
    'Address fields were saved'
);

my $u = WebGUI::User->new($session,$book->get("userId"));

cmp_bag(
    [ map { $u->get($_) } keys %{ $book->getProfileAddressMappings } ],
    [ map { $address1->get($_) } values %{ $book->getProfileAddressMappings } ],
    'Profile address was updated and matches address fields'
);

$address_info = {
    label           => 'Non Profile Label',
    addressId       => $address2->getId,
    firstName       => 'Ellis',
    lastName        => 'Redding',
    address1        => '123 Shank Ave',
    address2        => 'Cell Block E',
    address3        => 'Cell 15',
    city            => 'Shawshank',
    state           => 'PA',
    code            => '11223',
    country         => 'US',
    phoneNumber     => '111-111-1111',
    email           => 'red@shawshank.com',
    organization    => 'Shawshank'
};


$session->request->setup_body({
    %$address_info,
    callback        => q|{'url':''}|
});

$book->www_editAddressSave;

$address1 = $book->getAddress($address1->getId);
$address2 = $book->getAddress($address2->getId);

cmp_bag(
    [ map { $address2->get($_) } keys %$address_info ],
    [ values %$address_info ],
    'Non Profile Address fields were saved'
);

cmp_bag(
    [ map { $u->get($_) } keys %{ $book->getProfileAddressMappings } ],
    [ map { $address1->get($_) } values %{ $book->getProfileAddressMappings } ],
    'Profile address was not updated when non profile fields were saved'
);

#######################################################################
#
# www_deleteAddress
#
#######################################################################

$session->request->setup_body({
    'addressId' => $address2->getId,
    'callback'  => q|{'url':''}|
});
$book->www_deleteAddress;

@addresses = @{ $book->getAddresses() };

cmp_bag(
    [ map { $_->getId } @addresses ],
    [$address1->getId],
    'Address was deleted properly'
);


$session->request->setup_body({
    'addressId' => $address1->getId,
    'callback'  => q|{'url':''}|
});
$book->www_deleteAddress;

@addresses = @{ $book->getAddresses() };

cmp_bag(
    [ map { $_->getId } @addresses ],
    [$address1->getId],
    'Profile Address was not deleted'
);


#######################################################################
#
# delete
#
#######################################################################

my $addressBookId = $alreadyHaveBook->getId;
my $firstCount    = $session->db->quickScalar('select count(*) from addressBook where addressBookId=?',[$addressBookId]);
$alreadyHaveBook->delete();
my $afterCount    = $session->db->quickScalar('select count(*) from addressBook where addressBookId=?',[$addressBookId]);
my $addrCount     = $session->db->quickScalar('select count(*) from address where addressBookId=?',[$addressBookId]);

ok(($firstCount == 1 && $afterCount == 0), 'delete: one book deleted');

$addressBookId    = $bookClone->getId;
$bookClone->delete();
$bookCount = $session->db->quickScalar('select count(*) from addressBook where addressBookId=?',[$addressBookId]);
$addrCount = $session->db->quickScalar('select count(*) from address where addressBookId=?',[$addressBookId]);

is($bookCount, 0, '... book deleted');
is($addrCount, 0, '... also deletes addresses in the book');

#######################################################################
#
# newByUserId
#
#######################################################################

my $otherSession = WebGUI::Test->newSession;
my $mergeUser    = WebGUI::User->create($otherSession);
WebGUI::Test->addToCleanup($mergeUser);
$otherSession->user({user => $mergeUser});
my $adminBook   = WebGUI::Shop::AddressBook->new($otherSession);
WebGUI::Test->addToCleanup($adminBook);
my $goodAddress = $adminBook->addAddress({label => 'first'});

my $session2 = WebGUI::Test->newSession;
$session2->user({user => $mergeUser});
my $bookAdmin = WebGUI::Shop::AddressBook->newByUserId($session2);
WebGUI::Test->addToCleanup($bookAdmin);

cmp_bag(
    [ map { $_->getId } @{ $bookAdmin->getAddresses } ],
    [ $goodAddress->getId, ],
    'newByUserId works'
);

#######################################################################
#
# www_ajaxSearch
#
#######################################################################

#Create some data to search for
my $andySession = WebGUI::Test->newSession;
my $andy = WebGUI::User->create($andySession);
$andy->username('andy');
WebGUI::Test->addToCleanup($andy);
$andySession->user({ userId => $andy->getId });
my $andyBook   = WebGUI::Shop::AddressBook->create($andySession);
WebGUI::Test->addToCleanup($andyBook);

my $andyAddr1 = $andyBook->addAddress({
    label           => 'Andy1',
    firstName       => 'Andy',
    lastName        => 'Dufresne',
    address1        => '123 Shank Ave',
    address2        => 'Cell Block E',
    address3        => 'Cell 12',
    city            => 'Shawshank',
    state           => 'PA',
    code            => '11223',
    country         => 'US',
    phoneNumber     => '111-111-1111',
    email           => 'andy@shawshank.com',
    organization    => 'Shawshank'
});

my $andyAddr2 = $andyBook->addAddress({
    label           => 'Andy2',
    firstName       => 'Andy',
    lastName        => 'Dufresne',
    address1        => '123 Seaside Ave',
    address2        => '',
    address3        => '',
    city            => 'Zihuatanejo',
    state           => '',
    code            => '40880',
    country         => 'MX',
    phoneNumber     => '222-222-2222',
    email           => 'andy@freeman.com',
    organization    => 'Unaffiliated'
});


my $redSession = WebGUI::Test->newSession;
my $red = WebGUI::User->create($redSession);
$red->username('red');
WebGUI::Test->addToCleanup($red);
$redSession->user({userId => $red->getId});
my $redBook   = WebGUI::Shop::AddressBook->create($redSession);
WebGUI::Test->addToCleanup($redBook);

my $redAddr = $redBook->addAddress({
    label           => 'Red1',
    firstName       => 'Ellis',
    lastName        => 'Redding',
    address1        => '123 Shank Ave',
    address2        => 'Cell Block E',
    address3        => 'Cell 15',
    city            => 'Shawshank',
    state           => 'PA',
    code            => '11223',
    country         => 'US',
    phoneNumber     => '111-111-1111',
    email           => 'red@shawshank.com',
    organization    => 'Shawshank',
    isProfile       => 0,
});


my $brooksSession = WebGUI::Test->newSession;
my $brooks = WebGUI::User->create($brooksSession);
$brooks->username('brooks');
WebGUI::Test->addToCleanup($brooks);
$brooksSession->user({userId => $brooks->getId});
my $brooksBook   = WebGUI::Shop::AddressBook->create($brooksSession);
WebGUI::Test->addToCleanup($brooksBook);

my $brooksAddr = $brooksBook->addAddress({
    label           => 'Brooks1',
    firstName       => 'Brooks',
    lastName        => 'Hatlen',
    address1        => '123 Shank Ave',
    address2        => 'Cell Block E',
    address3        => 'Cell 22',
    city            => 'Shawshank',
    state           => 'PA',
    code            => '11223',
    country         => 'US',
    phoneNumber     => '111-111-1111',
    email           => 'brooks@shawshank.com',
    organization    => 'Shawshank',
    isProfile       => 0,
});

#Test search as admin
$session->request->setup_body({
    'name' => 'Andy Du'
});

my $results = JSON->new->decode($book->www_ajaxSearch);

my $andyAddr1_get  = $andyAddr1->get;
my $andyAddr2_get  = $andyAddr2->get;
my $redAddr_get    = $redAddr->get;
my $brooksAddr_get = $brooksAddr->get;

foreach my $addr ($andyAddr1_get, $andyAddr2_get, $redAddr_get, $brooksAddr_get) {
    delete $addr->{addressBook};
}

cmp_bag(
    $results,
    [
        { %{$andyAddr1_get}, username => $andy->username, },
        { %{$andyAddr2_get}, username => $andy->username, },
    ],
    'Ajax Address Search matches name correctly for admins'
);

#Test search for multiple fields
$session->request->setup_body({
    'name'         => 'Andy Du',
    'organization' => 'Shaw',
    'address1'     => '123',
    'address2'     => 'Cell',
    'address3'     => 'Cell',
    'city'         => 'Shaw',
    'state'        => 'P',
    'zipcode'      => '11',
    'country'      => 'U',
    'email'        => 'andy',
    'phone'        => '111',
});

$results = JSON->new->decode($book->www_ajaxSearch);

cmp_bag(
    $results,
    [{ %{$andyAddr1_get}, username => $andy->username }],
    'Ajax Address Search matches multiple fields correctly'
);

#Test limiting
$session->request->setup_body({
    'name'         => 'Andy Du',
    'organization' => 'Shaw',
    'address1'     => '123',
    'address2'     => 'Cell',
    'address3'     => 'Cell',
    'city'         => 'Shaw',
    'state'        => 'Q',              #This should cause no results to come back
    'zipcode'      => '11',
    'country'      => 'U',
    'email'        => 'andy',
    'phone'        => '111',
});

$results = JSON->new->decode($book->www_ajaxSearch);

cmp_bag(
    $results,
    [],
    'Ajax Address Search limits results correctly'
);

#Test searching across users
#Test as admin
$session->request->setup_body({
    'organization' => 'Shawshank'
});

$results = JSON->new->decode($book->www_ajaxSearch);

cmp_bag(
    $results,
    [
        { %{$andyAddr1_get},  username => $andy->username },
        { %{$redAddr_get},    username => $red->username },
        { %{$brooksAddr_get}, username => $brooks->username },
    ],
    'Ajax Address Search returns cross user results for admins'
);

#Test as shop admin
$andy->addToGroups([ $andySession->setting->get('groupIdAdminCommerce') ]);
$andySession->request->setup_body({
    'organization' => 'Shawshank'
});
$results = JSON->new->decode($andyBook->www_ajaxSearch);

cmp_bag(
    $results,
    [
        { %{$andyAddr1_get}, username => $andy->username },
        { %{$redAddr_get}, username => $red->username },
        { %{$brooksAddr_get}, username => $brooks->username },
    ],
    'Ajax Address Search returns cross user results for shop admins'
);

#Test search as shop cashier
$red->addToGroups([ $redSession->setting->get('groupIdCashier') ]);
$redSession->request->setup_body({
    'organization' => 'Shawshank'
});
$results = JSON->new->decode($redBook->www_ajaxSearch);

cmp_bag(
    $results,
    [
        { %{$andyAddr1_get}, username => $andy->username },
        { %{$redAddr_get}, username => $red->username },
        { %{$brooksAddr_get}, username => $brooks->username },
    ],
    'Ajax Address Search returns cross user results for shop cashiers'
);

#Test search as non privileged
$brooksSession->request->setup_body({
    'organization' => 'Shawshank'
});
$results = JSON->new->decode($brooksBook->www_ajaxSearch);

cmp_bag(
    $results,
    [{ %{$brooksAddr_get}, username => $brooks->username }],
    'Ajax Address Search returns only current user results for non privileged users'
);

undef $book;

done_testing;
