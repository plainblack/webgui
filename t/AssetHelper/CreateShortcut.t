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
use WebGUI::AssetHelper::CreateShortcut;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $output;
my $helper = WebGUI::AssetHelper::CreateShortcut->new( id => 'shortcut', session => $session );
my $import = WebGUI::Asset->getImportNode($session);

my $priv_page = WebGUI::Test->asset( groupIdView => '3' );
$session->user({userId => 1});
$output = $helper->process($priv_page);
cmp_deeply(
    $output, 
    {
        error => re('You do not have sufficient privileges'),
    },
    'AssetHelper/CreateShortcut checks for editing privileges'
);

$session->setting->set( versionTagMode => 'autoCommit' );
$session->setting->set( skipCommitComments => '1' );
$session->user({userId => 3});
my $safe_page = WebGUI::Test->asset;
$output = $helper->process($safe_page);
cmp_deeply(
    $output, 
    {
        message  => re( '.' ), # message exists
    },
    'AssetHelper/CreateShortcut returns a message'
);

my $shortcutId = $session->db->quickScalar(
    'SELECT assetId FROM Shortcut WHERE shortcutToAssetId=?', 
    [ $safe_page->getId ],
);

ok( $shortcutId, 'shortcut exists' );
ok( my $shortcut = WebGUI::Asset->newById( $session, $shortcutId ), 'can be instanced' );
WebGUI::Test::addToCleanup( $shortcut );
is( $shortcut->state, 'clipboard', 'is on clipboard' );
is( $shortcut->status, 'approved', 'was auto-committed' );

done_testing();

#vim:ft=perl
