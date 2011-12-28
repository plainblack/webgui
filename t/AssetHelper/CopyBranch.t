# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::AssetHelper::CopyBranch;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $output;
my $node = WebGUI::Asset->getImportNode($session);
my $root = WebGUI::Asset->getRoot( $session );
my $tag = WebGUI::VersionTag->getWorking( $session );
my $top = $node->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
    title           => 'Top',
} );
my $child   = $top->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
    title           => 'Child',
});
my $grand   = $child->addChild({
    className       => 'WebGUI::Asset::Snippet',
    title           => 'Grand',
});
$tag->commit;
WebGUI::Test->addToCleanup( $tag );

foreach my $asset ($top, $child, $grand) {
    $asset = $asset->cloneFromDb;
}

{ 
    my $helper = WebGUI::AssetHelper::CopyBranch->new( id => 'copy_branch', session => $session, asset => $top );
    $output = $helper->process;
    cmp_deeply(
        $output, 
        {
            openDialog  => all(
                            re('helperId=copy_branch'),
                            re('method=getWith'),
                            re('assetId=' . $top->getId ),
                        ),
        },
        'AssetHelper/CopyBranch opens a dialog for the copy method'
    );
}

my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/?op=assetHelper;helperId=copy_branch;method=copy;with=children;assetId=' . $top->getId );
WebGUI::Test->waitForAllForks(10);

my $clippies = $root->getLineage(["descendants"], {statesToInclude => [qw{clipboard clipboard-limbo}], returnObjects => 1,});
is @{ $clippies }, 2, '... copied 2 asset to the clipboard';
for my $asset ( @$clippies ) {
    $asset->purge;
}

$mech->get_ok( '/?op=assetHelper;helperId=copy_branch;method=copy;with=descendants;assetId=' . $top->getId );
WebGUI::Test->waitForAllForks(10);
my $clippies = $root->getLineage(["descendants"], {statesToInclude => [qw{clipboard clipboard-limbo}], returnObjects => 1,});
is @{ $clippies }, 3, '... copied 3 asset to the clipboard';
WebGUI::Test->addToCleanup( @$clippies );

#vim:ft=perl
