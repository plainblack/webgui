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

my $tests = 2;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Vendor');

my $vendor;

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
        error => 'Need a session.',
        got   => '',
        expected => 'WebGUI::Session',
    ),
    'new: requires a session variable',
);

}

#----------------------------------------------------------------------------
# Cleanup
END {
}
