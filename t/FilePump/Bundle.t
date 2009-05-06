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
use Data::Dumper;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my  $tests =  8;          # Increment this number for each test you create
plan tests => 1 + $tests; # 1 for the use_ok

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::FilePump::Bundle');

SKIP: {

skip 'Unable to load module WebGUI::FilePump::Bundle', $tests unless $loaded;

my $bundle = WebGUI::FilePump::Bundle->create($session);
isa_ok($bundle, 'WebGUI::FilePump::Bundle');
isa_ok($bundle, 'WebGUI::Crud');

###################################################################
#
# addFile
#
###################################################################

cmp_deeply(
    [ $bundle->addFile() ],
    [ 0, 'Illegal type' ],
    'addFile, checking error for no type'
);

cmp_deeply(
    [ $bundle->addFile('BAD_TYPE', ) ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type of file to add'
);

cmp_deeply(
    [ $bundle->addFile('JS', ) ],
    [ 0, 'No URI' ],
    '... checking error for no uri'
);

$bundle->setCollateral(
    'jsFiles',
    'fileId',
    'new',
    {
        uri => 'mysite',
        lastUpdated => 0,
    }
);

is(
    $bundle->addFile('JS', 'http://mysite.com/script.js'),
    1,
    '... adding a JS file'
);

is(
    $bundle->addFile('CSS', 'http://mysite.com/script.js'),
    1,
    '... okay to add a duplicate to another type'
);

cmp_deeply(
    [ $bundle->addFile('JS', 'http://mysite.com/script.js') ],
    [ 0, 'Duplicate URI' ],
    '... checking error message for duplicate URI'
);

$bundle->delete;

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from filePumpBundle');
}
#vim:ft=perl
