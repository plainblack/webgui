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
use Exception::Class;
use Data::Dumper;
use JSON;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Asset::Sku::Product;
use WebGUI::VersionTag;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 6;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::Shelf';
my $loaded = use_ok($class);

my ($e, $failure);

SKIP: {

    skip "Unable to load module $class", $tests unless $loaded;

    my $root    = WebGUI::Test->asset;

    #######################################################################
    #
    # Template variables
    #
    #######################################################################

    my $tommy  = WebGUI::User->create($session);
    my $warden = WebGUI::User->create($session);
    WebGUI::Test->addToCleanup($tommy, $warden);
    my $inGroup = WebGUI::Group->new($session, 'new');
    WebGUI::Test->addToCleanup($inGroup);
    $inGroup->addUsers([$tommy->getId]);

    my $testTemplate = $root->addChild({
        className => 'WebGUI::Asset::Template',
        parser    => 'WebGUI::Asset::Template::HTMLTemplate',
        template  => q|{ "noViewableSkus":"<tmpl_var noViewableSkus>","emptyShelf":"<tmpl_var emptyShelf>"}|,
    });
    my $testShelf = $root->addChild({
        className  => $class,
        templateId => $testTemplate->getId,
    });
    $session->user({userId => 1});
    $testShelf->prepareView;
    my $json = $testShelf->view;
    my $vars = eval { from_json($json) };
    ok(  $vars->{emptyShelf},     'empty shelf: yes');
    ok(  $vars->{noViewableSkus}, 'viewable skus: none');

    my $privateSku = $testShelf->addChild({
        className   => 'WebGUI::Asset::Sku::Product',
        groupIdView => $inGroup->getId,
        title       => 'Private Product',
    });
    $session->user({user => $tommy});
    $testShelf->prepareView;
    $json = $testShelf->view;
    $vars = eval { from_json($json) };
    ok( !$vars->{emptyShelf},     'empty shelf, no');
    ok( !$vars->{noViewableSkus}, 'viewable skus: yes for user in group');

    $session->user({user => $warden});
    $testShelf->prepareView;
    $json = $testShelf->view;
    $vars = eval { from_json($json) };

    ok( !$vars->{emptyShelf},     'empty shelf, no');
    ok(  $vars->{noViewableSkus}, 'viewable skus: none for user not in viewable group');

}
