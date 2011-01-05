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
use File::Spec;
use File::Temp;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::AssetHelper::ExportHtml;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({ userId => 3 });

my $output;
my $node = WebGUI::Asset->getImportNode($session);
my $root = WebGUI::Asset->getRoot( $session );
my $top = $node->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
    title           => 'Top',
    description     => 'This is the top',
    groupIdView     => '7',
    url             => 'top',
} );
my $child   = $top->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
    title           => 'Child',
    description     => 'This is the child',
    groupIdView     => '7',
});
my $grand   = $child->addChild({
    className       => 'WebGUI::Asset::Wobject::Article',
    title           => 'Grand',
    description     => 'This is some content',
    groupIdView     => '7',
});
my $tag = WebGUI::VersionTag->getWorking( $session );
$tag->commit;
addToCleanup( $tag );

my $dir     = File::Temp->newdir;
WebGUI::Test->originalConfig( "exportPath" );
WebGUI::Test->config->set( "exportPath" => $dir->dirname );

#----------------------------------------------------------------------------
# Tests

{ 

    $output = WebGUI::AssetHelper::ExportHtml->process($top);
    cmp_deeply(
        $output, 
        {
            openDialog  => all(
                            re('method=export'),
                            re('assetId=' . $top->getId ),
                        ),
        },
        'AssetHelper/ExportHtml opens a dialog'
    );
}

my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get('/');
$mech->session->user({ userId => 3 });
$mech->get_ok( '/?op=assetHelper;className=WebGUI::AssetHelper::ExportHtml;method=export;assetId=' . $top->getId );
$mech->submit_form_ok({
    fields  => {
    },
});
WebGUI::Test->waitForAllForks;

ok( -e File::Spec->catfile( $dir->dirname, 'top', 'index.html' ), 'top export exists' );
ok( -e File::Spec->catfile( $dir->dirname, 'top', 'child', 'index.html' ), 'child export exists' );
ok( -e File::Spec->catfile( $dir->dirname, 'top', 'child', 'grand', 'index.html' ), 'grand export exists' );

done_testing();

#vim:ft=perl
