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

# This tests the AssetReport asset
# 
#

use Test::MockTime qw/:all/;
use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use JSON;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Cache;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );

#----------------------------------------------------------------------------
# Tests

plan tests => 6;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Asset Report creation
my $asset  = $node->addChild( {
    className     => 'WebGUI::Asset::Wobject::StockData',
    source        => 'usa',
    defaultStocks => "GWR",
    cacheTimeout  => 2000,
} );
WebGUI::Test->addToCleanup($asset);

my $now = time();
set_relative_time(-1000);

my $stocks = $asset->_getStocks(["GWR"]);
is $stocks->{qw/GWR symbol/}, 'GWR', 'stock fetch successful';
cmp_ok $stocks->{qw/GWR last_fetch/}, '<', $now-500, 'last_fetch set in the past';
my $last_fetch = $stocks->{qw/GWR last_fetch/};

my $cache = WebGUI::Cache->new($session, [$asset->getId, 'usa', 'GWR']);
is $cache->get()->{qw/GWR symbol/}, 'GWR', 'cache loaded with valid data';

restore_time();

my $stocks2 = $asset->_getStocks([qw/GWR UNP/]);
is $stocks2->{qw/UNP symbol/}, 'UNP', 'stock fetch successful, new stock';
is $stocks2->{qw/GWR symbol/}, 'GWR', '... cached stock';
is $stocks2->{qw/GWR last_fetch/}, $last_fetch, 'GWR stock lookup was cached';

#vim:ft=perl
