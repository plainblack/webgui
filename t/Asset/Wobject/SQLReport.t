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
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset::Wobject::SQLReport;

################################################################
#
#  setup session, users and groups for this test
#
################################################################

my $session         = WebGUI::Test->session;

plan tests => 4;

#----------------------------------------------------------------------------
# put your tests here

my $defaultNode = WebGUI::Test->asset;

my $report = $defaultNode->addChild({
    className     => 'WebGUI::Asset::Wobject::SQLReport',
    title         => 'test report',
    cacheTimeout  => 50,
    dqQuery1      => 'select * from users',
});

isa_ok($report, 'WebGUI::Asset::Wobject::SQLReport');

is($report->get('cacheTimeout'), 50, 'cacheTimeout set correctly');
ok(abs($report->getContentLastModified - (time - 50)) < 2, 'getContentLastModified overridden correctly');

$report->update({cacheTimeout => 250});
ok(abs($report->getContentLastModified - (time - 250)) < 2, '... tracks cacheTimeout');
