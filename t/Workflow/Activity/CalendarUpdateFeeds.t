#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Workflow::Activity::CalendarUpdateFeeds;

use Test::More;
use Test::Deep;
use Test::LongString;
use WebGUI::Asset::Wobject::Calendar;

plan skip_all => 'set WEBGUI_LIVE to enable this test'
    unless $ENV{WEBGUI_LIVE};

plan tests => 27; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $home   = WebGUI::Asset->getDefault($session);
my $sender = $home->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Sending Calendar',
});
my $receiver = $home->addChild({
    className => 'WebGUI::Asset::Wobject::Calendar',
    title     => 'Receiving Calendar',
});

my $feedId = $receiver->addFeed({
    url      => $session->url->getSiteURL.$session->url->gateway($sender->getUrl('func=ical')),
    lastUpdated => 'never',
});

my $dt = WebGUI::DateTime->new($session, time());
$dt->add(days => 1);

my $party = $sender->addChild({
    className   => 'WebGUI::Asset::Event',
    title       => 'WebGUI 100th Anniversary',
    menuTitle   => 'Anniversary',
    description => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum', ##Set at longer than 72 characters to test for line wrapping, and character escaping
    url         => 'webgui_anniversary',
    startDate   => $dt->toDatabaseDate, ##Times and dates have to be entered in UTC
    endDate     => $dt->toDatabaseDate,
    timeZone    => 'America/Chicago',
    location    => 'Madison, Wisconsin',
    groupIdView => 7,
    groupIdEdit => 12,
    ownerUserId => 3,
}, undef, undef, {skipAutoCommitWorkflows => 1});

my $ical_feed = <<"EOICAL";
BEGIN:VCALENDAR
PRODID:-//Oregon State University//NONSGML Web Calendar//EN
VERSION:2.0
BEGIN:VEVENT
UID:20110426T010000Z-51795\@calendar.oregonstate.edu
CLASS:PUBLIC
SUMMARY:CPR/AED for the Professional Rescuer
DESCRIPTION:This class is designed for any individual who has a duty to res
 pond to emergencies.&nbsp; It combines lectures and video with hands-on sk
 ill training and it incorporates real-life rescue scenarios and lessons th
 at reinforce decision-making skills.&nbsp; This class covers Adult/Child A
 ED &amp; CPR and Infant CPR; two-person CPR; use of a bag-valve mask; a
 nd introduction to Emergency Medical Services and bloodbourne pathogens.**
 This course meets Level C CPR requirements.&nbsp; It is the pre-requisite 
 for most nursing and EMT programs. **&nbsp; Course continues Tuesday&nbsp\
 ;April 26, 6:00pm - 10:00pm Dixon Upper Classroom.
DTSTART:20110426T010000Z
DTEND:20110426T050000Z
LAST-MODIFIED:20110301T215024Z
CREATED:20110301T215024Z
DTSTAMP:20110301T215024Z
CONTACT:Recreation Services
END:VEVENT
END:VCALENDAR
EOICAL

my $snippet_feed = $home->addChild({
    className => 'WebGUI::Asset::Snippet',
    url       => 'icalFeed.ics',
    snippet   => $ical_feed,
    mimeType  => 'text/calendar',
});

my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag);

$snippet_feed = $snippet_feed->cloneFromDb;

my $workflow  = WebGUI::Workflow->create($session,
    {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    },
);
WebGUI::Test->addToCleanup($workflow);
my $icalFetch = $workflow->addActivity('WebGUI::Workflow::Activity::CalendarUpdateFeeds');

my $instance1 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

my $oldEvents = $receiver->getLineage(['children'], { returnObjects => 1, });
is(scalar @{ $oldEvents }, 0, 'receiving calendar has no events');

my $retVal;

$retVal = $instance1->run();
is($retVal, 'complete', 'cleanup: activity complete');
$retVal = $instance1->run();
is($retVal, 'done', 'cleanup: activity is done');
$instance1->delete;

my $newEvents = $receiver->getLineage(['children'], { returnObjects => 1, });

my $got_anniversary = is(scalar @{ $newEvents }, 1, 'ical import of 1 event');

SKIP: {
    skip "No event recieved", 15 unless $got_anniversary;
    my $anniversary = pop @{ $newEvents };

    is($anniversary->get('title'),         $party->get('title'),       'transferred title');
    is($anniversary->get('menuTitle'),     $party->get('menuTitle'),   '... menuTitle');
    is($anniversary->get('groupIdView'),   $party->get('groupIdView'), '... groupIdView');
    is($anniversary->get('groupIdEdit'),   $party->get('groupIdEdit'), '... groupIdEdit');
    is($anniversary->get('url'),           $party->get('url').'2',     '... url (accounting for duplicate)');
    is($anniversary->get('timeZone'),      $party->get('timeZone'),    '... timeZone');
    is($anniversary->get('startDate'),     $party->get('startDate'),   '... startDate');
    is($anniversary->get('startTime'),     $party->get('startTime'),   '... startTime');
    is($anniversary->get('endDate'),       $party->get('endDate'),     '... endDate');
    is($anniversary->get('endTime'),       $party->get('endTime'),     '... endTime');
    is_string($anniversary->get('description'),   $party->get('description'), '... description, checks for line wrapping');

    $party->update({description => "one line\nsecond line"});

    my $instance2 = WebGUI::Workflow::Instance->create($session,
        {
            workflowId              => $workflow->getId,
            skipSpectreNotification => 1,
        }
    );

    $retVal = $instance2->run();
    is($retVal, 'complete', 'cleanup: 2nd activity complete');
    $retVal = $instance2->run();
    is($retVal, 'done', 'cleanup: 2nd activity is done');

    $newEvents = $receiver->getLineage(['children'], { returnObjects => 1, });

    is(scalar @{ $newEvents }, 1, 'reimport does not create new children');
    $anniversary = pop @{ $newEvents };
    is($anniversary->get('description'),   $party->get('description'), '... description, checks for line unwrapping');
    $anniversary->purge;
}

##Add an ical feed to check time zone processing

$receiver->deleteFeed($feedId);
$feedId = $receiver->addFeed({
    url      => $session->url->getSiteURL.$snippet_feed->getUrl,
    lastUpdated => 'never',
});

$oldEvents = $receiver->getLineage(['children'], { returnObjects => 1, });
is(scalar @{ $oldEvents }, 0, 'receiving calendar has no events');

$instance1->delete('skipNotify');
$instance1 = WebGUI::Workflow::Instance->create($session,
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
$instance1->delete;

$newEvents = $receiver->getLineage(['children'], { returnObjects => 1, });

my $got_cpr = is(scalar @{ $newEvents }, 1, 'ical import of 1 event');

##Add a feed that will fail, to test that feeds are not modified
$receiver->deleteFeed($feedId);
my $feedUrl = $session->url->getSiteURL.'do_not_hack_my_url';
$feedId = $receiver->addFeed({
    url         => $feedUrl,
    lastUpdated => 'never',
});

$instance1->delete('skipNotify');
$instance1 = WebGUI::Workflow::Instance->create($session,
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
$instance1->delete;

$receiver = $receiver->cloneFromDb;
my $feed = $receiver->getFeed($feedId);

##Note, cannot use Test::Deep in here because Asset/Event.pm use Test::Deep::NoTest

is $feed->{lastResult}, 'Error parsing iCal feed', 'After fetching a bad feed it updated the lastResult';
is $feed->{url}, $feedUrl, '... nothing added to feed URL';

#vim:ft=perl
