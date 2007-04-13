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
use Test::More tests => 17; # increment this value for each test you create
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
});

my $folder2 = $root->addChild({
    url   => 'testFolder2',
    title => 'folder2',
    menuTitle => 'folder2MenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
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

my $snippet2 = $folder2->addChild( {
            className   => "WebGUI::Asset::Snippet",
            groupIdView => 7,
            groupIdEdit => 3,
            title       => "Snippet2 0",
            menuTitle   => 0,
});

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

####################################################
#
# cascadeLineage
#
####################################################

#diag $snippets[0]->get('lineage');
#diag $snippet2->get('lineage');
##Uncomment me to crash the test
#$snippet2->cascadeLineage($snippets[0]->get('lineage'));
#diag $snippets[0]->get('lineage');
#diag $snippet2->get('lineage');

####################################################
#
# setParent
#
####################################################

ok(!$snippet2->setParent($folder),   'setParent: user must be in group 4 to do this');
$session->user({userId => 3});
ok(!$snippet2->setParent(),          'setParent: new parent must be passed in');
ok(!$snippet2->setParent($snippet2), 'setParent: cannot be your own parent');
ok(!$snippet2->setParent($folder2),  'setParent: will not move self to current parent');
ok(!$folder2->setParent($snippet2),  'setParent: will not move self to my child');

ok($snippet2->setParent($folder),    'setParent: successfully set');

is($snippet2->getParent->getId, $folder->getId, 'setParent successfully set parent');
is($folder->getChildCount,      8,              'setParent: folder now has 8 children');

END {
	$versionTag->rollback;
}
