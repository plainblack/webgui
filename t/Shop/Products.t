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
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 5;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Products');

my $storage;
my $e;

SKIP: {

    skip 'Unable to load module WebGUI::Shop::Products', $tests unless $loaded;
    
    #######################################################################
    #
    # import
    #
    #######################################################################
    
    eval { WebGUI::Shop::Products::importProducts($session); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'importProducts: error handling for an undefined path to file');
    is($e->error, 'Must provide the path to a file', 'importProducts: error handling for an undefined path to file');
    
    eval { WebGUI::Shop::Products::importProducts($session, '/path/to/nowhere'); };
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
    
}

#----------------------------------------------------------------------------
# Cleanup
END {
}
