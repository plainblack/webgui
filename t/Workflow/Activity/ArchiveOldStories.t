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
use WebGUI::Asset;
use WebGUI::Asset::Story;
use WebGUI::Asset::Wobject::StoryArchive;
use WebGUI::Workflow::Activity::ArchiveOldStories;

use Data::Dumper;
use Test::More;
use Test::Deep;

plan tests => 6; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});

my $home = WebGUI::Asset->getDefault($session);
my $wgBday = WebGUI::Test->webguiBirthday;

my $creationDateSth = $session->db->prepare('update asset set creationDate=? where assetId=?');

my $archive1 = $home->addChild({
    className => 'WebGUI::Asset::Wobject::StoryArchive',
    title     => '2001 Stories',
    archiveAfter => 50*365*24*3600, ##50 years ago
});

my $birthdayFolder = $archive1->getFolder($wgBday);
$creationDateSth->execute([$wgBday, $birthdayFolder->getId]);

my @oldStories = ();
push @oldStories, $birthdayFolder->addChild({ className => 'WebGUI::Asset::Story',});
push @oldStories, $birthdayFolder->addChild({ className => 'WebGUI::Asset::Story',});
foreach my $story (@oldStories) {
    $creationDateSth->execute([$wgBday, $story->getId]);
}

my $archive2 = $home->addChild({
    className => 'WebGUI::Asset::Wobject::StoryArchive',
    title     => 'Stories from last week',
    archiveAfter => 10*24*3600, #10 days ago
});

my $weekAgo = time() - (7*24*3600);
my $weekFolder = $archive2->getFolder($weekAgo);
my $weekStory  = $weekFolder->addChild({className => 'WebGUI::Asset::Story',});
$creationDateSth->execute([$weekAgo, $weekFolder->getId]);
$creationDateSth->execute([$weekAgo, $weekStory->getId]);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->commit;
WebGUI::Test->addToCleanup($versionTag);
foreach my $asset ($archive1, $archive2) {
    $asset = $asset->cloneFromDb;
}

my $workflow  = WebGUI::Workflow->create($session,
    {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    },
);
WebGUI::Test->addToCleanup($workflow);

my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::ArchiveOldStories');

my $instance1 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

my $retVal;

$retVal = $instance1->run();
is($retVal, 'complete', 'First workflow was run');
$retVal = $instance1->run();
is($retVal, 'done', 'Workflow is done');

my $archivedAssets = $home->getLineage(
    ['descendants'],
    {
        includeOnlyClasses => ['WebGUI::Asset::Story', 'WebGUI::Asset::Wobject::Folder', 'WebGUI::Asset::Wobject::StoryArchive'],
        statusToInclude    => ['archived'],
    },
);

cmp_bag( $archivedAssets, [ ], 'Nothing archived.');

$archive2 = $archive2->cloneFromDb;
$archive2->update({ archiveAfter => 5*24*3600, });

my $instance2 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);
$retVal = $instance2->run();
is($retVal, 'complete', 'Second workflow was run');
$retVal = $instance2->run();
is($retVal, 'done', 'Workflow is done');

$archivedAssets = $home->getLineage(
    ['descendants'],
    {
        includeOnlyClasses => ['WebGUI::Asset::Story', 'WebGUI::Asset::Wobject::Folder', 'WebGUI::Asset::Wobject::StoryArchive'],
        statusToInclude    => ['archived'],
    },
);

cmp_bag( $archivedAssets, [ $weekStory->getId, $weekFolder->getId ], 'archived two folders');
$creationDateSth->finish;
