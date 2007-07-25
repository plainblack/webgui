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
use WebGUI::User;

use WebGUI::Asset;
use Test::More tests => 76; # increment this value for each test you create
use Test::Deep;

# Test the methods in WebGUI::AssetLineage

my $session = WebGUI::Test->session;

my $asset = WebGUI::Asset->getImportNode($session);

is($asset->formatRank(76), "000076", "formatRank()");
is($asset->getLineageLength(), (length($asset->get("lineage")) / 6), "getLineageLength()");

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"AssetLineage Test"});

my $root = WebGUI::Asset->getRoot($session);
my $topFolder = $root->addChild({
    url   => 'TopFolder',
    title => 'TopFolder',
    menuTitle   => 'topFolderMenuTitle',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});

my $folder = $topFolder->addChild({
    url   => 'testFolder',
    title => 'folder',
    menuTitle   => 'folderMenuTitle',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});

my $folder2 = $topFolder->addChild({
    url   => 'testFolder2',
    title => 'folder2',
    menuTitle => 'folder2MenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
});

my $editor = WebGUI::User->new($session, 'new');
$editor->addToGroups([4]);

my @snippets = ();
foreach my $snipNum (0..6) {
    push @snippets,
        $folder->addChild( {
            className   => "WebGUI::Asset::Snippet",
            groupIdView => 7,
            groupIdEdit => 3,
            title       => "Snippet $snipNum",
            menuTitle   => $snipNum,
            url         => 'snippet'.$snipNum,
        });
}

my $snippet2 = $folder2->addChild( {
            className   => "WebGUI::Asset::Snippet",
            groupIdView => 7,
            ownerUserId => $editor->userId, #For coverage on addChild properties
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
is($snippets[0]->getId, $folder->getFirstChild->getId, 'getFirstChild: cached lookup');

####################################################
#
# getLastChild
#
####################################################

is($snippets[-1]->getId, $folder->getLastChild->getId, 'getLastChild');
is($snippets[-1]->getId, $folder->getLastChild->getId, 'getLastChild: cached lookup');

####################################################
#
# getChildCount
#
####################################################

is(scalar @snippets, $folder->getChildCount,  'getChildCount on folder with several children');
is(1,                $folder2->getChildCount, 'getChildCount on folder with 1 child');

####################################################
#
# getDescendantCount
#
####################################################

is(10, $topFolder->getDescendantCount,             'getDescendantCount on top folder');
is(scalar @snippets, $folder->getDescendantCount,  'getDescendantCount on folder with several children');
is(1,                $folder2->getDescendantCount, 'getDescendantCount on folder with 1 child');

####################################################
#
# getParent
#
####################################################

is($snippets[0]->getParent->getId, $folder->getId, 'getParent');
is($root->getParent->getId,        $root->getId,   "getParent: root's parent is itself");

####################################################
#
# getParentLineage
#
####################################################

is($snippets[0]->getParentLineage, $folder->get('lineage'), 'getParentLineage: self');
is($root->getParentLineage,        '000001',                'getParentLineage: root');
is(
    $root->getParentLineage('000001000002'),
    '000001',
    'getParentLineage: arbitrary lineage'
);

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
$session->user({userId => $editor->userId});
ok(!$snippet2->setParent(),          'setParent: new parent must be passed in');
ok(!$snippet2->setParent($snippet2), 'setParent: cannot be your own parent');
ok(!$snippet2->setParent($folder2),  'setParent: will not move self to current parent');
ok(!$snippet2->setParent($folder),   'setParent: user cannot edit parent');

$session->user({userId => 3});
ok(!$folder2->setParent($snippet2),  'setParent: will not move self to my child');
ok($snippet2->setParent($folder),    'setParent: successfully set');

is($snippet2->getParent->getId, $folder->getId, 'setParent successfully set parent');
is($folder->getChildCount,      8,              'setParent: folder now has 8 children');

##Return snippet2 to folder2
ok($snippet2->setParent($folder2),   'setParent: return snippet to original folder');
is($folder2->getChildCount,     1,   'setParent: folder2 now haw 1 child');
is($folder->getChildCount,      7,   'setParent: folder again has 7 children');

####################################################
#
# getRank
#
####################################################

is($root->getRank,           '1',      "getRank: root's rank");
is($snippets[0]->getRank,    '1',      "getRank: snippet[0]");
is($snippets[1]->getRank,    '2',      "getRank: snippet[1]");
is($root->getRank('100001'), '100001', "getRank: arbitrary lineage");

####################################################
#
# getNextChildRank
#
####################################################

is($folder->getNextChildRank,  '000008',  "getNextChildRank: folder with 8 snippets");
is($folder2->getNextChildRank, '000002',  "getNextChildRank: empty folder");

####################################################
#
# swapRank
#
####################################################

is($snippets[0]->swapRank($snippets[1]->get('lineage')),  1, 'swapRank: self and adjacent');

@snipIds[0,1] = @snipIds[1,0];
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $lineageIds,
    'swapRank: swapped first and second snippets'
);

@snippets[0..1] = map { WebGUI::Asset->newByUrl($session, "snippet$_") } 0..1;

is(
    $snippets[1]->swapRank($snippets[0]->get('lineage'), $snippets[1]->get('lineage'), ), 
    1, 
    'swapRank: remote, two different snippets to restore original order'
);

@snippets[0..1] = map { WebGUI::Asset->newByUrl($session, "snippet$_") } 0..1;
@snipIds[0,1] = @snipIds[1,0];
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $lineageIds,
    'swapRank: swapped first and second snippets'
);


ok($folder->swapRank($folder2->get('lineage')), 'swap folder and folder2');

is(scalar @snippets, $folder->getChildCount,  'changing lineage does not change relationship in folder');
is(1               , $folder2->getChildCount, 'changing lineage does not change relationship in folder2');

##Reinstance the asset object due to db manipulation
$folder  = WebGUI::Asset->newByUrl($session, $folder->get('url'));
$folder2 = WebGUI::Asset->newByUrl($session, $folder2->get('url'));
@snippets = map { WebGUI::Asset->newByUrl($session, "snippet$_") } 0..6;
$snippet2 = WebGUI::Asset->newByUrl($session, $snippet2->get('url'));

####################################################
#
# demote
#
####################################################

ok(!$snippets[6]->demote(), 'demote: last snippet in the set will not swap');
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $lineageIds,
    'demote: no change'
);

ok($snippets[5]->demote(), 'demote: demote 5 to 6');
@snipIds[5,6] = @snipIds[6,5];
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $lineageIds,
    'demote: 5 was swapped with 6'
);

####################################################
#
# promote
#
####################################################


ok(!$snippets[0]->promote(), 'promote: first snippet in the set will not swap');
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $lineageIds,
    'promote: no change'
);

ok($snippets[4]->promote(), 'promote: promote 4 to 3');
@snipIds[4,3] = @snipIds[3,4];
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $lineageIds,
    'promote: 4 was swapped with 3'
);

####################################################
#
# setRank
#
####################################################
ok($snippet2->setRank($snippet2->getRank), 'setRank: returns true if the rank is set to itself');
##Note, setRank ALWAYS returns 1, whether the setRank worked or not
ok($snippet2->setRank('000002'), 'setRank: try to change rank on snippet2 to 2');
is($folder2->getNextChildRank, '000002', 'setRank: will not change rank on an Asset with no siblings');

$snippets[6]->setRank('100000');
is($snippets[6]->getRank(), '7', 'setRank: will not set an arbitrary rank');

$snippets[6]->setRank('000005');
is($snippets[6]->getRank(), '5', 'setRank was able to set an arbitrary rank(lower) on an Asset with siblings');

@snipIds = map { $_->getId } @snippets[0..3,6,4..5];
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(\@snipIds, $lineageIds, 'setRank reordered the other siblings appropiately');

$snippets[6]->setRank('000007');
is($snippets[6]->getRank(), '7', 'setRank: move the Asset back (higher rank)');

@snipIds = map { $_->getId } @snippets;
$lineageIds = $folder->getLineage(['descendants']);
cmp_bag(\@snipIds, $lineageIds, 'setRank: put them back in order');

####################################################
#
# hasChildren
#
####################################################

##Functional tests
ok($root->hasChildren,        'root node has children');
ok(!$snippets[0]->hasChildren, 'test snippet has no children');

##Coverage tests will require reaching inside the object
##to reset the caching
delete $folder->{_hasChildren};
ok($folder->hasChildren,      'test folder has children, manually built');

delete $folder->{_hasChildren};
$folder->getLastChild();
ok($folder->hasChildren, 'hasChildren: cached from getLastChild');

delete $folder->{_hasChildren};
$folder->getFirstChild();
ok($folder->hasChildren, 'hasChildren: cached from getFirstChild');

####################################################
#
# newByLineage
#
####################################################

##Clear the stowed assetLineage hash
$session->stow->delete('assetLineage');
my $snippet4 = WebGUI::Asset->newByLineage($session, $snippets[4]->get('lineage'));
is ($snippet4->getId, $snippets[4]->getId, 'newByLineage returns correct Asset');

$snippet4 = WebGUI::Asset->newByLineage($session, $snippets[4]->get('lineage'));
is ($snippet4->getId, $snippets[4]->getId, 'newByLineage: cached lookup');

my $cachedLineage = $session->stow->get('assetLineage');
delete $cachedLineage->{$snippet4->get('lineage')}->{id};
my $snippet4 = WebGUI::Asset->newByLineage($session, $snippets[4]->get('lineage'));
is ($snippet4->getId, $snippets[4]->getId, 'newByLineage: failing id cache forces lookup');

delete $cachedLineage->{$snippet4->get('lineage')}->{class};
my $snippet4 = WebGUI::Asset->newByLineage($session, $snippets[4]->get('lineage'));
is ($snippet4->getId, $snippets[4]->getId, 'newByLineage: failing class cache forces lookup');

####################################################
#
# getLineage
#
####################################################

@snipIds = map { $_->getId } @snippets;
my $ids = $folder->getLineage(['descendants']);
cmp_bag(
    \@snipIds,
    $ids,
    'getLineage: get descendants of folder'
);

$ids = $folder->getLineage(['self','descendants']);
unshift @snipIds, $folder->getId;
cmp_bag(
    \@snipIds,
    $ids,
    'getLineage: get descendants of folder and self'
);

$ids = $folder->getLineage(['self','children']);
cmp_bag(
    \@snipIds,
    $ids,
    'getLineage: descendants == children if there are no grandchildren'
);

$ids = $topFolder->getLineage(['self','children']);
cmp_bag(
    [$topFolder->getId, $folder->getId, $folder2->getId, ],
    $ids,
    'getLineage: children (no descendants) of topFolder',
);

$ids = $topFolder->getLineage(['self','descendants']);
cmp_bag(
    [$topFolder->getId, @snipIds, $folder2->getId, $snippet2->getId],
    $ids,
    'getLineage: descendants of topFolder',
);

####################################################
#
# addChild
#
####################################################

my $vTag2 = WebGUI::VersionTag->getWorking($session);
$vTag2->set({name=>"deep addChild test"});

my @deepAsset = ($root);

for (1..42) {
    $deepAsset[$_] = $deepAsset[$_-1]->addChild( {
            className   => "WebGUI::Asset::Snippet",
            groupIdView => 7,
            ownerUserId => 3, #For coverage on addChild properties
            title       => "Deep Snippet $_",
            menuTitle   => "Deep Snip $_",
    });
}

$vTag2->commit;

is($deepAsset[41]->getParent->getId, $deepAsset[40]->getId, 'addChild will not create an asset with a lineage deeper than 42 levels');
like($WebGUI::Test::logger_warns, qr/Adding it as a sibling instead/, 'addChild logged a warning about deep assets');

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'addChild');
    ok(0, 'getLineage tests');
}


END {
    foreach my $tag ($versionTag, $vTag2) {
        $tag->rollback;
    }
    foreach my $account ($editor) {
        (defined $account  and ref $account  eq 'WebGUI::User') and $account->delete;
    }
}
