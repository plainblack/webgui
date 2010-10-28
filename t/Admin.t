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
use lib "$FindBin::Bin/lib";
use JSON;
use Test::More;
use Test::Deep;
use Monkey::Patch;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init

# Create a new admin plugin
package WebGUI::Admin::Plugin::Test;

use Moose;
use base 'WebGUI::Admin::Plugin';

has '+title' => ( default => "title" );
has '+icon' => ( default => "icon" );
has '+iconSmall' => ( default => "iconSmall" );
has 'test_config' => ( is => 'rw', default => 'default' );

sub canView { return 1; }
sub process { return { message => 'success' } }
sub www_view { return "view" }
sub www_test { return "test" }
sub www_config { return $_[0]->test_config }

package main;
BEGIN { $INC{'WebGUI/Admin/Plugin/Test.pm'} = __FILE__; }

my $session         = WebGUI::Test->session;
$session->user({ userId => 3 });

# Add a couple admin plugins to the config file
WebGUI::Test->originalConfig( "adminConsole" );
$session->config->addToHash('adminConsole', 'test', {
    className       => 'WebGUI::Admin::Plugin::Test',
} );
$session->config->addToHash('adminConsole', 'test2', {
    url             => '?op=admin;plugin=test;method=config',
} );

# Add some assets
my $snip = WebGUI::Asset->getImportNode( $session )->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    title           => 'test',
    groupIdEdit     => '3',
} );

# Commit the tag
my $tag  = WebGUI::VersionTag->getWorking( $session );
$tag->commit;
addToCleanup( $tag );

#----------------------------------------------------------------------------
# Tests

my $output;

# Test www_ methods
my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get('/'); # Start a session
$mech->session->user({ userId => '3' });

# www_processAssetHelper
$mech->get_ok( '/?op=admin;method=processAssetHelper;className=WebGUI::AssetHelper::Cut;assetId=' . $snip->getId );
cmp_deeply( 
    JSON->new->decode( $mech->content ), 
    WebGUI::AssetHelper::Cut->process( $snip ),
    'www_processAssetHelper',
);

# www_processPlugin
$mech->get_ok( '/?op=admin;method=processPlugin;id=test' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    WebGUI::Admin::Plugin::Test->process( $session ),
    'Test plugin process()',
) || diag( $output );

# www_findUser
$mech->get_ok( '/?op=admin;method=findUser;query=Adm' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    { results => superbagof( superhashof( {
        userId      => 3,
    } ) ) },
    'found the Admin user',
) || diag( $output );

done_testing;

#vim:ft=perl
