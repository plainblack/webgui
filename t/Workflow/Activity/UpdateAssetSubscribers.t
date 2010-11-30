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
use lib "$FindBin::Bin/../../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Workflow::Activity::UpdateAssetSubscribers;
use WebGUI::Asset;

use Test::More;
use Test::Deep;

plan tests => 4; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});

my $subscriberGroup = WebGUI::Group->new($session, "new");  ##Group to hold subscribers
my $oldGroup        = WebGUI::Group->new($session, "new");  ##Pretend group, old groupIdView
my $betterGroup     = WebGUI::Group->new($session, "new");  ##New group for groupIdView
my $oldUser         = WebGUI::User->create($session);       ##User who should be unsubscribed
my $betterUser      = WebGUI::User->create($session);       ##User who should remain subscribed
my $otherUser       = WebGUI::User->create($session);       ##Just a user, we should never see him
my $root = WebGUI::Asset->getRoot($session);
my $cs = $root->addChild({
    className           => 'WebGUI::Asset::Wobject::Collaboration',
    title               => 'Test Calendar',
    subscriptionGroupId => $subscriberGroup->getId,
    groupIdView         => $betterGroup->getId,
});
my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag, $subscriberGroup, $betterGroup, $oldUser, $betterUser, $otherUser);

$subscriberGroup->addUsers([$oldUser->getId, $betterUser->getId, ]);
$betterGroup->addUsers([$betterUser->getId, ]);

##Plan, since spectre isn't running, we manually simulate an update event and run the
##workflow activity by hand.

cmp_bag(
    $subscriberGroup->getUsers,
    [$oldUser->getId, $betterUser->getId],
    'Initial subscribers are correct'
);

##This workflowId needs to exist, since it's hardcoded in the CS asset
my $workflow  = WebGUI::Workflow->new($session, 'xR-_GRRbjBojgLsFx3dEMA');

my $instance1 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
        className  => 'WebGUI::Asset',
        methodName => 'newByDynamicClass',
        parameters => $cs->getId,
    }
);
WebGUI::Test->addToCleanup($instance1);

my $retVal;

$retVal = $instance1->run();
is($retVal, 'complete', 'cleanup: activity complete');
$retVal = $instance1->run();
is($retVal, 'done', 'cleanup: activity is done');
$instance1->delete('skipNotify');

$subscriberGroup->clearCaches;

cmp_bag(
    $subscriberGroup->getUsers,
    [$betterUser->getId],
    'Corrent user removed'
);
