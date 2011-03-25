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
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::AssetHelper::Delete;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $output;
my $import = WebGUI::Asset->getImportNode($session);
my $helper = WebGUI::AssetHelper::Delete->new( id => 'Delete', session => $session, asset => $import );

$session->user({userId => 1});
$output = $helper->process;
cmp_deeply(
    $output, 
    {
        error => re('You do not have sufficient privileges'),
    },
    'AssetHelper/Delete checks for editing privileges'
);

$session->user({userId => 3});
$output = $helper->process;
cmp_deeply(
    $output, 
    {
        error => re('vital component'),
    },
    'AssetHelper/Delete checks for system pages'
);

my $safe_page = $import->getFirstChild;
my $helper = WebGUI::AssetHelper::Delete->new( id => 'Delete', session => $session, asset => $safe_page );
$output = $helper->process;
cmp_deeply(
    $output, 
    {
        forkId => re(qr/[a-zA-Z0-9_-]{22}/),
    },
    'AssetHelper/Delete forks a process'
);

WebGUI::Test->waitForAllForks;

$session->cache->clear;
$safe_page  = WebGUI::Asset->newById( $session, $safe_page->assetId );
is $safe_page->state, 'trash', '... and the asset was really Deleted';

$safe_page->restore;

done_testing();

#vim:ft=perl
