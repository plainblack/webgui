#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;

use WebGUI::Asset;
use Test::More tests => 9; # increment this value for each test you create
use Test::Deep;

# Test the methods in WebGUI::AssetLineage

my $session = WebGUI::Test->session;

my $asset = WebGUI::Asset->getImportNode($session);

is($asset->formatRank(76), "000076", "formatRank()");
is($asset->getLineageLength(), (length($asset->get("lineage")) / 6), "getLineageLength()");

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"AssetLineage Test"});

my $root = WebGUI::Asset->getRoot($session);
my $folder = $root->addChild({
    url   => 'testFolder',
    title => 'folder',
    menuTitle => 'folderMenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
    isPackage => 1,
});

my @snippets = ();
foreach my $snipNum (0..6) {
    push @snippets,
        $folder->addChild( {
            className   => "WebGUI::Asset::Snippet",
            groupIdView => 7,
            groupIdEdit => 3,
            title       => "Snippet $snipNum",
            menuTitle   => $snipNum,
        });
}
$versionTag->commit;

my @snipIds = map { $_->getId } @snippets;
my $lineageIds = $folder->getLineage(['descendants']);

cmp_bag(\@snipIds, $lineageIds, 'default order returned by getLineage is lineage order');

####################################################
#
# getFirstChild
#
####################################################

is($snippets[0]->getId, $folder->getFirstChild->getId, 'getFirstChild');

####################################################
#
# getLastChild
#
####################################################

is($snippets[-1]->getId, $folder->getLastChild->getId, 'getLastChild');

####################################################
#
# getChildCount
#
####################################################

is(scalar @snippets, $folder->getChildCount, 'getChildCount');

####################################################
#
# hasChildren
#
####################################################

ok($folder->hasChildren,      'test folder has children');
ok($root->hasChildren,        'root node has children');
ok(!$snippets[0]->hasChildren, 'test snippet has no children');

END {
	$versionTag->rollback;
}
