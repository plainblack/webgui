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
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 51;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Vendor');

my ($vendor);
my ($fence, $fenceCopy);
my $fenceUser = WebGUI::User->new($session, 'new');
$fenceUser->username('fence');
my $guardUser = WebGUI::User->new($session, 'new');
$guardUser->username('guard');
WebGUI::Test->addToCleanup($fenceUser, $guardUser);

#######################################################################
#
# new
#
#######################################################################

my $e;

eval { $vendor = WebGUI::Shop::Vendor->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'new takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a session.',
        got      => '',
        expected => 'WebGUI::Session',
    ),
    'new: requires a session variable',
);

eval { $vendor = WebGUI::Shop::Vendor->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes an exception to not giving it a vendor id to instanciate');
cmp_deeply(
    $e,
    methods(
        error => 'Need a vendorId.',
    ),
    'new: requires a vendorId',
);

eval { $vendor = WebGUI::Shop::Vendor->new($session, 'notAVendorId'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'new takes an exception to not giving it a vendor id that is not in the db');
cmp_deeply(
    $e,
    methods(
        error => 'Vendor not found.',
        id    => 'notAVendorId',
    ),
    'new: requires a valid vendorId',
);

eval { $vendor = WebGUI::Shop::Vendor->new($session, 'defaultvendor000000000'); };
$e = Exception::Class->caught();
ok(!$e, 'No exception thrown');
isa_ok($vendor, 'WebGUI::Shop::Vendor', 'new returns correct type of object');

isa_ok($vendor->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $vendor->session->getId, 'session method returns OUR session object');

is($vendor->getId, 'defaultvendor000000000', 'new returned the correct vendor');

#######################################################################
#
# create
#
#######################################################################

eval { $fence = WebGUI::Shop::Vendor->create(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'new takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a session.',
        got      => '',
        expected => 'WebGUI::Session',
    ),
    'create: requires a session variable',
);

my $now = WebGUI::DateTime->new($session, time);

eval { $fence = WebGUI::Shop::Vendor->create($session, { userId => $fenceUser->userId, }); };
$e = Exception::Class->caught();
ok(!$e, 'No exception thrown by create') ||
    diag $@;
isa_ok($vendor, 'WebGUI::Shop::Vendor', 'create returns correct type of object');
WebGUI::Test->addToCleanup($fence);
is $fence->userId, $fenceUser->userId, 'object made with create has properties initialized correctly';

$fence->write;
ok($fence->get('dateCreated'), 'dateCreated is not null');
my $dateCreated = WebGUI::DateTime->new($session, $fence->get('dateCreated'));
my $deltaDC = $dateCreated - $now;
cmp_ok( $deltaDC->in_units('seconds'), '<=', 2, 'dateCreated is set properly');

#######################################################################
#
# get, update
#
#######################################################################

ok($session->id->valid($fence->get('vendorId')),   'get: vendorId is a valid guid');
is($fence->getId,         $fence->get('vendorId'), 'get: getId is an alias for get vendorId');
is($fence->get('userId'), $fenceUser->userId,      'get: userId');
is($fence->get('name'),   '',                      'get: by default, no name is set');

$fence->update({name =>  'Bogs Diamond'});
is($fence->get('name'),  'Bogs Diamond',           'get: get name');
is($fence->get('userId'), $fenceUser->userId,      'get: updating name did not affect userId');

my $fence_fresh = WebGUI::Shop::Vendor->new($session, $fence->vendorId);
is($fence->name,  'Bogs Diamond',           'update wrote to the db');

my $newProps = {
    name => 'Warden Norton',
    url  => 'http://www.shawshank.com',
};

$fence->update($newProps);
is($fence->get('name'), 'Warden Norton',            'get: get name');
is($fence->get('url'),  'http://www.shawshank.com', 'get: updating name did not affect userId');

$newProps->{name} = 'Officer Hadley';
is($fence->get('name'), 'Warden Norton',            'get: No leakage in passing hashref to get');

my $currentProps = $fence->get();

cmp_deeply(
    $currentProps,
    {
        paymentInformation   => ignore(),
        vendorId             => ignore(),
        preferredPaymentType => ignore(),
        dateCreated          => ignore(),
        url                  => 'http://www.shawshank.com',
        userId               => $fenceUser->userId,
        name                 => 'Warden Norton',
    },
    'get: returns all properties'
);

$currentProps->{name} = 'Jake the Raven';
is($fence->get('name'), 'Warden Norton', 'get: No leakage returned hashref');
$fence->update({name => 'Bogs Diamond', });

#######################################################################
#
# newByUserId
#
#######################################################################

eval { $fenceCopy = WebGUI::Shop::Vendor->newByUserId(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'newByUserId takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a session.',
        got      => '',
        expected => 'WebGUI::Session',
    ),
    'create: requires a session variable',
);

eval { $fenceCopy = WebGUI::Shop::Vendor->newByUserId($session, 'neverAUserId'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'newByUserId->new takes an exception to not giving it a bad user id that is in the db');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a vendorId.',
    ),
    'create: requires a session variable',
);

eval { $fenceCopy = WebGUI::Shop::Vendor->newByUserId($session, '1'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'newByUserId->new takes an exception to not giving it a valid user id that is in the db');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a vendorId.',
    ),
    'create: requires a session variable',
);

eval { $fenceCopy = WebGUI::Shop::Vendor->newByUserId($session, $fenceUser->userId); };
$e = Exception::Class->caught();
ok(!$e, 'newByUserId: No exception thrown with explicit, valid data');
isa_ok($fenceCopy, 'WebGUI::Shop::Vendor', 'newByUserId returns correct type of object');
is($fenceCopy->getId, $fence->getId, 'newByUserId returned the correct object');

$session->user({user => $fenceUser});

eval { $fenceCopy = WebGUI::Shop::Vendor->newByUserId($session); };
$e = Exception::Class->caught();
ok(!$e, 'newByUserId: No exception thrown with implicit user data');
isa_ok($fenceCopy, 'WebGUI::Shop::Vendor', 'newByUserId returns correct type of object using session user');
is($fenceCopy->getId, $fence->getId, 'newByUserId returned the correct object using session user');

my $defaultVendor = WebGUI::Shop::Vendor->newByUserId($session, 3);

#######################################################################
#
# getVendors
#
#######################################################################

my $guard = WebGUI::Shop::Vendor->create($session, { userId => $guardUser->userId, name => q|Warden Norton|});
$guard->write;
WebGUI::Test->addToCleanup($guard);
my $vendorsList = WebGUI::Shop::Vendor->getVendors($session);
cmp_bag(
    $vendorsList,
    [ $guard, $fence, $defaultVendor, ],
    'getVendors returns all 3 vendors as an array ref'
);

my $vendorsHash = WebGUI::Shop::Vendor->getVendors($session, { asHashRef => 1 });
cmp_deeply(
    $vendorsHash,
    {
        $guard->getId         => $guard->get('name'),
        $fence->getId         => $fence->get('name'),
        $defaultVendor->getId => $defaultVendor->get('name'),
    },
    'getVendors returns all 3 vendors as an hash ref, when requested'
);


#######################################################################
#
# delete
#
#######################################################################

$guard->delete();
$vendorsList = WebGUI::Shop::Vendor->getVendors($session);
cmp_deeply(
    $vendorsList,
    [ $fence, $defaultVendor, ],
    'delete removed the correct vendor'
);

#######################################################################
#
# isVendorInfoComplete
#
#######################################################################

my %completeProps = (
    name                    => 'Esquerita',
    userId                  => $fenceUser->userId,
    preferredPaymentType    => 'PayPal',
    paymentInformation      => 'esquerita@example.com',
);
$fence->update( { %completeProps } );
is( $fence->isVendorInfoComplete, 1, 'Vendor information is complete' );

foreach (keys %completeProps ) {
    $fence->update( { %completeProps, $_ => undef } );
    ok( !$fence->isVendorInfoComplete, "Vendor information is not complete without $_" );
}


undef $guard;

#vim:ft=perl
