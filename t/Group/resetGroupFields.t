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

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Group;

use Test::More;
use Test::Deep;

plan tests => 10;

my $session = WebGUI::Test->session;

my $assetGroup = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($assetGroup);

my $settingGroup = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($settingGroup);

my $activityGroup = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($activityGroup);

my $home = WebGUI::Asset->getDefault($session);

my $snippet1 = $home->addChild({
    className   => 'WebGUI::Asset::Snippet',
    groupIdEdit => $assetGroup->getId,
    groupIdView => 7,
    snippet     => 'one',
});

my $snippet2 = $home->addChild({
    className   => 'WebGUI::Asset::Snippet',
    groupIdEdit => 7,
    groupIdView => 7,
    snippet     => 'two',
});

my $snippet3 = $home->addChild({
    className   => 'WebGUI::Asset::Snippet',
    groupIdEdit => $assetGroup->getId,
    groupIdView => $assetGroup->getId,
    snippet     => 'three',
});

my $gallery1 = $home->addChild({
    className   => 'WebGUI::Asset::Wobject::Gallery',
    groupIdView => 7,
    groupIdEdit => $assetGroup->getId,
    groupIdAddComment => $assetGroup->getId,
});

cmp_deeply(
    $gallery1->get,
    superhashof({
        groupIdEdit => $assetGroup->getId,
        groupIdView => 7,
        groupIdAddComment => $assetGroup->getId,
    }),
    'gallery set up correctly'
);

cmp_deeply(
    $snippet1->get,
    superhashof({
        groupIdEdit => $assetGroup->getId,
        groupIdView => 7,
    }),
    'groupIdEdit updated on test snippet'
);

my $workflow  = WebGUI::Workflow->create($session,
    {
        enabled    => 1,
        objectType => 'User',
        mode       => 'realtime',
    },
);
WebGUI::Test->addToCleanup($workflow);

$session->config->addToArray('workflowActivities/User', 'WebGUI::Workflow::Activity::AddUserToGroup');

my $userActivity = $workflow->addActivity('WebGUI::Workflow::Activity::AddUserToGroup');
$userActivity->set('className', 'WebGUI::Workflow::Activity::AddUserToGroup');
$userActivity->set('groupId',   $activityGroup->getId);
is($userActivity->get('groupId'), $activityGroup->getId, 'group in Workflow Activity set to test group');

###################################################################
#
#  Asset tests
#
###################################################################

$assetGroup->delete;

my $newSnippet1 = WebGUI::Asset->newById($session, $snippet1->getId);

cmp_deeply(
    $newSnippet1->get,
    superhashof({
        groupIdEdit => 3,
        groupIdView => 7,
    }),
    'groupIdEdit updated on test snippet'
);

my $newSnippet2 = WebGUI::Asset->newById($session, $snippet2->getId);

cmp_deeply(
    $newSnippet2->get,
    superhashof({
        groupIdEdit => 7,
        groupIdView => 7,
    }),
    'other snippet not touched'
);

my $newSnippet3 = WebGUI::Asset->newById($session, $snippet3->getId);

cmp_deeply(
    $newSnippet3->get,
    superhashof({
        groupIdEdit => 3,
        groupIdView => 3,
    }),
    'multiple fields updated'
);

my $newGallery1 = WebGUI::Asset->newById($session, $gallery1->getId);

cmp_deeply(
    $newGallery1->get,
    superhashof({
        groupIdEdit => 3,
        groupIdView => 7,
        groupIdAddComment => 3,
    }),
    'multiple fields and tables updated'
);

###################################################################
#
#  Setting tests
#
###################################################################

$session->setting->set('groupIdAdminUser', $settingGroup->getId);

is($session->setting->get('groupIdAdminUser'), $settingGroup->getId, 'group in Setting set up');

$settingGroup->delete;

is($session->setting->get('groupIdAdminUser'), 3, 'group in Setting reset to Admin');

###################################################################
#
#  Workflow Activity tests
#
###################################################################

$activityGroup->delete;

my $userActivity2 = WebGUI::Workflow::Activity->new($session, $userActivity->getId);
is ($userActivity2->get('groupId'), 3, 'group in Workflow Activity set to Admin');

WebGUI::Test->addToCleanup(WebGUI::VersionTag->getWorking($session));
