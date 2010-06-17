#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Asset;
use WebGUI::VersionTag;

use Test::More; # increment this value for each test you create
plan tests => 12;

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $root = WebGUI::Asset->getRoot($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Clipboard test"});
WebGUI::Test->tagsToRollback($versionTag);

my $snippet = $root->addChild({
    url => 'testSnippet',
    title => 'snippet',
    menuTitle => 'snippetMenuTitle',
    className => 'WebGUI::Asset::Snippet',
    snippet   => 'A snippet of text',
});

my $snippetAssetId      = $snippet->getId;
my $snippetRevisionDate = $snippet->get("revisionDate");
my $topFolder = $root->addChild({
    url   => 'TopFolder',
    title => 'TopFolder',
    menuTitle   => 'topFolderMenuTitle',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});
my $folder1a = $topFolder->addChild({
    url   => 'folder_1a',
    title => 'folder1a',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});
my $folder1b = $topFolder->addChild({
    url   => 'folder_1b',
    title => 'folder1b',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});
my $folder1a2 = $folder1a->addChild({
    url   => 'folder_1a2',
    title => 'folder1a2',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});


$versionTag->commit;

sleep 2;

my $duplicatedSnippet = $snippet->duplicate;

is($duplicatedSnippet->get('title'), 'snippet',        'duplicated snippet has correct title');
isnt($duplicatedSnippet->getId,      $snippetAssetId,  'duplicated snippet does not have same assetId as original');
is( 
    $duplicatedSnippet->get("revisionDate"),
    $snippetRevisionDate,
    'duplicated snippet has the same revision date',
);
is($snippet->getId,                  $snippetAssetId,  'original snippet has correct id');

is($snippet->getParent->getId,           $root->getId, 'original snippet is a child of root');
is($duplicatedSnippet->getParent->getId, $root->getId, 'duplicated snippet is also a child of root');

my $newVersionTag = WebGUI::VersionTag->getWorking($session);
$newVersionTag->commit;
WebGUI::Test->tagsToRollback($newVersionTag);

####################################################
#
# cut
#
####################################################

is( $topFolder->cut, 1, 'cut: returns 1 if successful' );
is($topFolder->get('state'),              'clipboard', '... state set to trash on the trashed asset object');
is($topFolder->cloneFromDb->get('state'), 'clipboard', '... state set to trash in db on object');
is($folder1a->cloneFromDb->get('state'),  'clipboard-limbo', '... state set to clipboard-limbo on child #1');
is($folder1b->cloneFromDb->get('state'),  'clipboard-limbo', '... state set to clipboard-limbo on child #2');
is($folder1a2->cloneFromDb->get('state'), 'clipboard-limbo', '... state set to clipboard-limbo on grandchild #1-1');
