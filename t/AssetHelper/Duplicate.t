# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Duplicateright 2001-2009 Plain Black Corporation.
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
use WebGUI::AssetHelper::Duplicate;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 2;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $output;
$session->setting->set( "versionTagMode" => "autoCommit" );
my $helper = WebGUI::AssetHelper::Duplicate->new( id => 'duplicate', session => $session );
my $root = WebGUI::Test->asset;
my $test = $root->addChild( { className => 'WebGUI::Asset::Snippet' } );

{ 

    $output = $helper->process($test);
    cmp_deeply(
        $output, 
        {
            forkId  => re('[a-zA-Z0-9_-]{22}'),
        },
        'AssetHelper/Duplicate forks a process'
    );
}

WebGUI::Test->waitForAllForks;
$session->cache->clear;
my $children = $root->getLineage(["children"]);
is @{ $children }, 2, '... created a new asset';

#vim:ft=perl
