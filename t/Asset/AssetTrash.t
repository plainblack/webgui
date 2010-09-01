#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::User;

use WebGUI::Asset;
use Test::More tests => 7; # increment this value for each test you create
use Test::Deep;

# Test the methods in WebGUI::AssetLineage

my $session = WebGUI::Test->session;

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"AssetLineage Test"});
WebGUI::Test->addToCleanup($versionTag);

my $root = WebGUI::Asset->getRoot($session);
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


####################################################
#
# trash
#
####################################################

is( $topFolder->trash, 1, 'trash: returns 1 if successful' );
is($topFolder->state,              'trash', '... state set to trash on the trashed asset object');
is($topFolder->cloneFromDb->state, 'trash', '... state set to trash in db on object');
is($folder1a->cloneFromDb->state, 'trash-limbo', '... state set to trash-limbo on child #1');
is($folder1b->cloneFromDb->state, 'trash-limbo', '... state set to trash-limbo on child #2');
is($folder1a2->cloneFromDb->state, 'trash-limbo', '... state set to trash-limbo on grandchild #1-1');

####################################################
#
# purge
#
####################################################

is($topFolder->purge, 1, 'purge returns 1 if asset can be purged');
