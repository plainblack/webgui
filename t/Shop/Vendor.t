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
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 30;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Vendor');

my $vendor;
my ($fence, $fenceCopy);
my $fenceUser = WebGUI::User->new($session, 'new');

SKIP: {

skip 'Unable to load module WebGUI::Shop::Vendor', $tests unless $loaded;

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
        param => undef,
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
ok(!$e, 'No exception thrown by create');
isa_ok($vendor, 'WebGUI::Shop::Vendor', 'create returns correct type of object');

ok($fence->get('dateCreated'), 'dateCreated is not null');
my $dateCreated = WebGUI::DateTime->new($session, $fence->get('dateCreated'));
my $deltaDC = $dateCreated - $now;
cmp_ok( $deltaDC->seconds, '<=', 2, 'dateCreated is set properly');

#######################################################################
#
# get, update
#
#######################################################################

ok($session->id->valid($fence->get('vendorId')),   'get: vendorId is a valid guid');
is($fence->getId,         $fence->get('vendorId'), 'get: getId is an alias for get vendorId');
is($fence->get('userId'), $fenceUser->userId,      'get: userId');
is($fence->get('name'),   undef,                   'get: by default, no name is set');

$fence->update({name =>  'Bogs Diamond'});
is($fence->get('name'),  'Bogs Diamond',           'get: get name');
is($fence->get('userId'), $fenceUser->userId,      'get: updating name did not affect userId');

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
        paymentAddressId     => ignore(),
        dateCreated          => ignore(),
        url                  => 'http://www.shawshank.com',
        userId               => $fenceUser->userId,
        name                 => 'Warden Norton',
    },
    'get: returns all properties'
);

$currentProps->{name} = 'Jake the Raven';
is($fence->get('name'), 'Warden Norton', 'get: No leakage returned hashref');

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

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $fence->delete;
    $fenceUser->delete;
}
