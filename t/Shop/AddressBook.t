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
use WebGUI::Text;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 8;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::AddressBook');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::Tax', $tests unless $loaded;
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

eval { $book = WebGUI::Shop::AddressBook->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a addressBookId');
cmp_deeply(
    $e,
    methods(
        error => 'Need an addressBookId.',
    ),
    'new takes exception to not giving it a addressBook Id',
);

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


#######################################################################
#
# create
#
#######################################################################

eval { $book = WebGUI::Shop::AddressBook->create(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error    => 'Need a session.',
        expected => 'WebGUI::Session',
        got      => '',
    ),
    'create takes exception to not giving it a session object',
);

$session->user({userId => 1});

$book = WebGUI::Shop::AddressBook->create($session);

}

END: {
    $session->db->write('delete from addressBook');
    $session->db->write('delete from address');
}
