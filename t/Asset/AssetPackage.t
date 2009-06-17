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
use Test::MockObject;
plan tests => 10;

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $root = WebGUI::Asset->getRoot($session);

is(scalar @{ $root->getPackageList }, 0, 'WebGUI does not ship with packages');

my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($versionTag);
$versionTag->set({name=>"Asset Package test"});

my $folder = $root->addChild({
    url   => 'testFolder',
    title => 'folder',
    menuTitle => 'folderMenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
    isPackage => 1,
});

my $targetFolder = $root->addChild({
    url   => 'targetFolder',
    title => 'Target Folder',
    menuTitle => 'Target folderMenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
});

my $snippet = $folder->addChild({
    url => 'testSnippet',
    title => 'snippet',
    menuTitle => 'snippetMenuTitle',
    className => 'WebGUI::Asset::Snippet',
    snippet   => 'A snippet of text',
});

my $packageAssetId = $folder->getId;
$session->request->setup_body({ assetId => $packageAssetId });

my $targetFolderChildren;
$targetFolderChildren = $targetFolder->getLineage(["children"], {returnObjects => 1,});
is(scalar @{ $targetFolderChildren }, 0, 'target folder has no children');

$versionTag->commit;

sleep 2;

$targetFolder->www_deployPackage();

$targetFolderChildren = $targetFolder->getLineage(["children"], {returnObjects => 1,});
is(scalar @{ $targetFolderChildren }, 1, 'target folder now has 1 child');

my $deployedFolder = $targetFolderChildren->[0];

is($deployedFolder->get('title'), 'folder', 'deployed folder has correct title');
ok(! $deployedFolder->get('isPackage'), 'and is not a package');

my $deployedFolderChildren;
$deployedFolderChildren = $deployedFolder->getLineage(["children"], {returnObjects => 1,});
is(scalar @{ $deployedFolderChildren }, 1, 'deployed package folder still has 1 child');
isa_ok($deployedFolderChildren->[0] , 'WebGUI::Asset::Snippet', 'deployed child is a Snippet');

##Unset isPackage in this versionTag for the next tests
$folder->addRevision({isPackage => 0});

my $newVersionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($newVersionTag);
$newVersionTag->commit;

my $newFolder = WebGUI::Asset->new($session, $folder->getId);
ok(! $newFolder->get('isPackage'), 'Disabled isPackage in original folder asset');
is(scalar @{ $root->getPackageList }, 0, 'getPackageList does not pick up old versions of assets that used to be packages');

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'Check package deployment with 2-level package and look for new style templates propagating down the tree');
}

