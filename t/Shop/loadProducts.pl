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
use Test::More qw(no_plan);

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Tax;
use WebGUI::Asset::Wobject::Product;
use WebGUI::VersionTag;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# put your tests here

##Create products by hand

my $tag = WebGUI::VersionTag->getWorking($session);

my $properties1 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'one',
    price         => 10.00,
    productNumber => '#1',
    title         => 'product 1',
    description   => 'First product',
};

my $root = WebGUI::Asset->getRoot($session);
my $product1 = $root->addChild($properties1);

diag ref $product1;

my $properties2 = {
    className     => 'WebGUI::Asset::Wobject::Product',
    url           => 'two',
    price         => 20.00,
    productNumber => '#2',
    title         => 'product 2',
    description   => 'Second product',
};

my $product2 = $root->addChild($properties2);

diag ref $product2;

$tag->commit;
sleep 2;

$tag = WebGUI::VersionTag->getWorking($session);

my $product1a = $product1->addRevision({price => 11.11});

$tag->commit;

diag "Done.";
