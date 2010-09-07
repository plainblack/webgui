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
use WebGUI::Workflow::Activity::TrashExpiredEvents;
use WebGUI::Asset;

use Test::More;
use Test::Deep;

plan tests => 5; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});

my $bday     = WebGUI::DateTime->new($session, WebGUI::Test->webguiBirthday)->cloneToUserTimeZone;
my $now      = WebGUI::DateTime->new($session, time())->cloneToUserTimeZone;
my $tz       = $session->datetime->getTimeZone();

my $root = WebGUI::Asset->getRoot($session);
my $calendar = $root->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Test Calendar',
});
my $wgBday = $calendar->addChild({
    className => 'WebGUI::Asset::Event',
    title     => 'WebGUI Birthday',
    startDate   => $bday->toDatabaseDate,
    endDate     => $bday->toDatabaseDate,
    timeZone    => $tz,
}, undef, undef, {skipAutoCommitWorkflows => 1});

my $wrongBday = $calendar->addChild({
    className => 'WebGUI::Asset::Event',
    title     => 'Wrong Birthday',
    startDate   => $bday->toDatabaseDate,
    endDate     => $bday->toDatabaseDate,
    timeZone    => $tz,
}, undef, time()-5, {skipAutoCommitWorkflows => 1});

$wrongBday->addRevision({
    startDate   => $now->toDatabaseDate,
    endDate     => $now->toDatabaseDate,
}, undef, undef, {skipAutoCommitWorkflows => 1});

my $nowEvent = $calendar->addChild({
    className => 'WebGUI::Asset::Event',
    title     => 'WebGUI Birthday',
    startDate   => $now->toDatabaseDate,
    endDate     => $now->toDatabaseDate,
    timeZone    => $tz,
}, undef, undef, {skipAutoCommitWorkflows => 1});

my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag);

my $workflow  = WebGUI::Workflow->create($session,
    {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    },
);
WebGUI::Test->addToCleanup($workflow);
my $eventNuker = $workflow->addActivity('WebGUI::Workflow::Activity::TrashExpiredEvents');
$eventNuker->set('trashAfter', 3600);

my $instance1 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

my $retVal;

$retVal = $instance1->run();
is($retVal, 'complete', 'cleanup: activity complete');
$retVal = $instance1->run();
is($retVal, 'done', 'cleanup: activity is done');
$instance1->delete('skipNotify');

my $wgBdayCopy    = $wgBday->cloneFromDb;
my $nowEventCopy  = $nowEvent->cloneFromDb;
my $wrongBdayCopy = $wrongBday->cloneFromDb;

is $wgBdayCopy->get('state'), 'trash', 'old event was trashed';
is $nowEventCopy->get('state'), 'published', 'recent event was left alone';
is $wrongBdayCopy->get('state'), 'published', 'revisioned event was left alone';
