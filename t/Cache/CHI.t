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

# Test the CHI cache driver
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

use_ok( 'WebGUI::Cache::CHI' );
WebGUI::Test->originalConfig('cacheType');
WebGUI::Test->originalConfig('cache');
$session->config->set('cacheType', 'WebGUI::Cache::CHI');
$session->config->set('cache', { driver => 'FastMmap', });

my $cache = WebGUI::Cache::CHI->new($session, "this", "that");
my $testValue = "a rock that has no earthly business in that field";

$cache->set($testValue);
is($cache->get, $testValue, "set/get works");
$cache->delete;
is($cache->get, undef, "delete works");

#vim:ft=perl
