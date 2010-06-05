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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::AssetHelper::Lock;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# put your tests here

my $output;
my $home = WebGUI::Asset->getDefault($session);

my $editor = WebGUI::User->create($session);
$editor->addToGroups([4]);
addToCleanup($editor);

$session->user({userId => 3});
my $newPage = $home->addChild({
    className   => 'WebGUI::Asset::Wobject::Layout',
    title       => 'Test page',
    groupIdEdit => '4',
    ownerUserId => '3',
}, undef, WebGUI::Test->webguiBirthday, { skipAutoCommitWorkflows => 1, });
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->commit;
addToCleanup($versionTag);

$newPage = WebGUI::Asset->newById($session, $newPage->assetId);

$session->user({userId => 1});
$output = WebGUI::AssetHelper::Lock->process($newPage);
cmp_deeply(
    $output, 
    {
        error => re('You do not have sufficient privileges'),
    },
    'AssetHelper/Lock checks for editing privileges'
);

$session->user({userId => 3});
$output = WebGUI::AssetHelper::Lock->process($newPage);
cmp_deeply(
    $output, 
    {
        message => 'Locked the asset Test page.',
    },
    '... locks the asset'
);

my $versionTag2 = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag2);

$newPage = WebGUI::Asset->newById($session, $newPage->assetId);
ok $newPage->isLocked, 'Asset is locked, and ready for next test';
is $newPage->getRevisionCount, 2, 'new revision added';

$session->user({userId => $editor->getId});
$output = WebGUI::AssetHelper::Lock->process($newPage);
cmp_deeply(
    $output, 
    {
        error => 'The asset Test page is already locked.',
    },
    '... returns an error message if the asset is already locked'
);

done_testing;
