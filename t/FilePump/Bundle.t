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
use URI;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

my $startTime = time();

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my  $tests =  28;         # Increment this number for each test you create
plan tests => 1 + $tests; # 1 for the use_ok

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::FilePump::Bundle');

SKIP: {

skip 'Unable to load module WebGUI::FilePump::Bundle', $tests unless $loaded;

my $bundle = WebGUI::FilePump::Bundle->create($session);
isa_ok($bundle, 'WebGUI::FilePump::Bundle');
isa_ok($bundle, 'WebGUI::Crud');

is($bundle->get('lastModified'), 0, 'by default, lastModified is 0');

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

is(
    $bundle->addFile('JS', 'http://mysite.com/script.js'),
    1,
    '... adding a JS file'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

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

$bundle->addFile('JS', 'http://mysite.com/helloworld.js');
$bundle->addFile('JS', 'file:/data/domains/mysite.com/www/uploads/XX/YY/XXYYZZ/graviticEnergyDrive.js');

my @fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/script.js
        http://mysite.com/helloworld.js
        file:/data/domains/mysite.com/www/uploads/XX/YY/XXYYZZ/graviticEnergyDrive.js
    }],
    '... checking actual jsFiles data structure contents'
);

###################################################################
#
# moveFile{Up,Down}
#
###################################################################

cmp_deeply(
    [ $bundle->moveFileUp() ],
    [ 0, 'Illegal type' ],
    'moveFileUp: checking error for no type'
);

cmp_deeply(
    [ $bundle->moveFileUp('BEER') ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type'
);

cmp_deeply(
    [ $bundle->moveFileUp('JS', ) ],
    [ 0, 'No fileId' ],
    '... checking error for no fileId'
);

cmp_deeply(
    [ $bundle->moveFileDown() ],
    [ 0, 'Illegal type' ],
    'moveFileDown: checking error for no type'
);

cmp_deeply(
    [ $bundle->moveFileDown('BEER') ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type'
);

cmp_deeply(
    [ $bundle->moveFileDown('JS', ) ],
    [ 0, 'No fileId' ],
    '... checking error for no fileId'
);

my @fileIds = map { $_->{fileId} } @{ $bundle->get('jsFiles') };

$bundle->update({lastModified => 0});
ok($bundle->moveFileDown('JS', $fileIds[0]), 'moveFileDown returns 1 for a successful move');
@fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/helloworld.js
        http://mysite.com/script.js
        file:/data/domains/mysite.com/www/uploads/XX/YY/XXYYZZ/graviticEnergyDrive.js
    }],
    '... checking the actual order of js files'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

$bundle->update({lastModified => 0});
ok($bundle->moveFileUp('JS', $fileIds[2]), 'moveFileUp returns 1 for a successful move');
@fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/helloworld.js
        file:/data/domains/mysite.com/www/uploads/XX/YY/XXYYZZ/graviticEnergyDrive.js
        http://mysite.com/script.js
    }],
    '... checking the actual order of js files'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

###################################################################
#
# deleteFile
#
###################################################################

cmp_deeply(
    [ $bundle->deleteFile() ],
    [ 0, 'Illegal type' ],
    'deleteFile: checking error for no type'
);

cmp_deeply(
    [ $bundle->deleteFile('BEER') ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type'
);

cmp_deeply(
    [ $bundle->deleteFile('JS', ) ],
    [ 0, 'No fileId' ],
    '... checking error for no fileId'
);

@fileIds = map { $_->{fileId} } @{ $bundle->get('jsFiles') };
$bundle->update({lastModified => 0});
$bundle->deleteFile('JS', $fileIds[1]);
@fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/helloworld.js
        http://mysite.com/script.js
    }],
    '... checking the actual deletion of js files'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

###################################################################
#
# fetchAsset
#
###################################################################

###################################################################
#
# delete
#
###################################################################

$bundle->delete;

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from filePumpBundle');
}
#vim:ft=perl
