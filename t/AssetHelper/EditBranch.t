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
use WebGUI::AssetHelper::EditBranch;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $output;
my $node = WebGUI::Asset->getImportNode($session);
my $root = WebGUI::Asset->getRoot( $session );
my $top = $node->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
    title           => 'Top',
    ownerUserId     => '1',
} );
my $child   = $top->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
    title           => 'Child',
    ownerUserId     => '3',
});
my $grand   = $child->addChild({
    className       => 'WebGUI::Asset::Snippet',
    title           => 'Grand',
    ownerUserId     => '4',
});
my $tag = WebGUI::VersionTag->getWorking( $session );
$tag->commit;
addToCleanup( $tag );

{ 

    $output = WebGUI::AssetHelper::EditBranch->process($top);
    cmp_deeply(
        $output, 
        {
            openDialog  => all(
                            re('method=editBranch'),
                            re('assetId=' . $top->getId ),
                        ),
        },
        'AssetHelper/EditBranch opens a dialog for the copy method'
    );
}

my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get('/');
$mech->session->user({ userId => 3 });
$mech->get_ok( '/?op=assetHelper;className=WebGUI::AssetHelper::EditBranch;method=editBranch;assetId=' . $top->getId );
$mech->submit_form_ok({
    fields  => {
        ownerUserId         => '3',
        change_ownerUserId  => '1',
    },
});

$top = WebGUI::Asset->newPending( $session, $top->getId );
$child = WebGUI::Asset->newPending( $session, $child->getId );
$grand  = WebGUI::Asset->newPending( $session, $grand->getId );

is( $top->ownerUserId, '3' );
is( $child->ownerUserId, '3' );
is( $grand->ownerUserId, '3' );

done_testing();

#vim:ft=perl
