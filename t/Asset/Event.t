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

use Test::More; # increment this value for each test you create
plan tests => 30;

use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset::Event;

my $session = WebGUI::Test->session;

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Adding Calendar for Event Asset Test"});
WebGUI::Test->addToCleanup($versionTag);
my $defaultAsset = WebGUI::Asset->getDefault($session);
my $cal = $defaultAsset->addChild({className=>'WebGUI::Asset::Wobject::Calendar'});
$versionTag->commit;

my $properties = {
	#     '1234567890123456789012'
	id        => 'EventAssetTest00000001',
	title     => 'Birthday of WebGUI',
	className => 'WebGUI::Asset::Event',
	url       => 'event-asset-test1',
    startDate => '2000-08-16', ##Times and dates have to be entered in UTC
    startTime => '23:00:00',
    endDate   => '2000-08-17',
    endTime   => '03:00:00',
    timeZone  => 'America/Chicago',
    location  => 'Madison, Wisconsin',
};

my $event = $cal->addChild($properties, $properties->{id});

is($event->isAllDay, 0, 'isAllDay is zero since it has a start and end time');
cmp_ok($event->getDateTimeEnd, '>', $event->getDateTimeEndNI, 'getDateTimeEndNI is less than getDateTimeEnd');

my %templateVars = $event->getTemplateVars();
is($templateVars{isOneDay}, 1, 'getTemplateVars: isOneDay with start times');
is($templateVars{dateSpan}, 'Wednesday, August 16 6:00 PM &ndash;  10:00 PM', 'getTemplateVars: dateSpan bridges times on a single day');

$properties->{startDate} = '2000-08-16';
$properties->{endDate}   = '2000-08-16';
$properties->{startTime} = undef;
$properties->{endTime}   = undef;
$properties->{id}        = 'EventAssetTest00000002';
$properties->{url}       = 'event-asset-test2';

my $event2 = $cal->addChild($properties, $properties->{id});

is($event2->isAllDay, 1, 'isAllDay is zero since it has no start or end time');
cmp_ok($event2->getDateTimeEnd, '==', $event2->getDateTimeEndNI, 'getDateTimeEndNI is the same as getDateTimeEnd, due to no end time');

%templateVars = $event2->getTemplateVars();
is($templateVars{dateSpan}, 'Wednesday, August 16', 'getTemplateVars: dateSpan with no times');
is($templateVars{isOneDay}, 1, 'getTemplateVars: isOneDay with start times');

$properties->{startDate} = '2000-08-16';
$properties->{endDate}   = '2000-08-17';
$properties->{startTime} = undef;
$properties->{endTime}   = undef;
$properties->{id}        = 'EventAssetTest00000003';
$properties->{url}       = 'event-asset-test3';

my $event3 = $cal->addChild($properties, $properties->{id});

is($event3->isAllDay, 1, 'isAllDay is zero since it has no start or end time, even on different days');

%templateVars = $event3->getTemplateVars();
is($templateVars{dateSpan}, 'Wednesday, August 16 &bull; Thursday, August 17 ', 'getTemplateVars: dateSpan with no times, across two days');
is($templateVars{isOneDay}, 0, 'getTemplateVars: isOneDay with different start and end dates');

cmp_ok($event3->getDateTimeEnd, '==', $event3->getDateTimeEndNI, 'getDateTimeEndNI is the same as getDateTimeEnd');

$properties->{startDate} = '2000-08-30';
$properties->{endDate}   = '2000-08-31';
$properties->{startTime} = '00:00:00';
$properties->{endTime}   = '00:00:00';
$properties->{id}        = 'EventAssetTest00000004';
$properties->{url}       = 'event-asset-test4';

my $event4 = $cal->addChild($properties, $properties->{id});

cmp_ok($event4->getDateTimeEnd, '>', $event4->getDateTimeEndNI, 'getDateTimeEndNI is less than getDateTimeEnd');

is($event4->getIcalEnd, '20000831T000000Z', 'getIcalEnd, with defined time');

my $properties2 = {};
$properties2->{startDate} = '2000-08-31';
$properties2->{endDate}   = '2000-08-31';
$properties2->{id}        = 'EventAssetTest00000005';
$properties2->{url}       = 'event-asset-test5';
$properties2->{className} = 'WebGUI::Asset::Event';

my $event5 = $cal->addChild($properties2, $properties2->{id});

is($event5->getIcalStart, '20000831', 'getIcalStart, with no start time');
is($event5->getIcalEnd,   '20000901', 'getIcalEnd, with no end time, day incremented');

my $properties3 = {};
$properties3->{startDate} = '2000-08-31';
$properties3->{endDate}   = '2000-08-31';
$properties3->{id}        = 'EventAssetTestStorage6';
$properties3->{url}       = 'event-asset-test6';
$properties3->{className} = 'WebGUI::Asset::Event';

my $eventStorage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($eventStorage);
$properties3->{storageId} = $eventStorage->getId;

my $event6 = $cal->addChild($properties3, $properties3->{id}, time()-5);

my $event6a = $event6->addRevision({ title => 'Event with storage', }, undef, { skipAutoCommitWorkflows => 1, });
ok($session->id->valid($event6a->get('storageId')), 'addRevision gives the new revision a valid storageId');
isnt($event6a->get('storageId'), $event6->get('storageId'), '... and it is different from the previous revision');
my $versionTag2 = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag2);

my $event7 = $cal->addChild({
    className => 'WebGUI::Asset::Event',
    startDate => '2000-08-31',
    startTime => '24:00:00',
    endDate   => '2000-09-01',
    endTime   => '24:00:00',
});

is ($event7->get('startTime'), '00:00:00',   'startTime set to 00:00:00 if the hour is more than 23');
is ($event7->get('startDate'), '2000-09-01', 'startDate bumped by 1 day');

is ($event7->get('endTime'), '00:00:00',   'endTime set to 00:00:00 if the hour is more than 23');
is ($event7->get('endDate'), '2000-09-02', 'endDate bumped by 1 day');

#############################################################################
# Valid dates
$session->request->setup_body({ startDate => '0000-00-01', endDate => '1000-00-01' });
my $event = $cal->addChild({ className => 'WebGUI::Asset::Event' }, undef, time()+10);
my $output = $event->processPropertiesFromFormPost;
is( ref $output, 'ARRAY', 'ppffp returns error array' );
is( scalar @$output, 2, 'has two errors' );

#######################################
#
# setRelatedLinks, getRelatedLinks
#
#######################################
$event6->setRelatedLinks([
{
    new_event => 1,
    sequenceNumber => 1,
    linkurl => 'http://www.nowhere.com',
    linktext => 'Great link',
    groupIdView => '7',
    eventlinkId => '27',
},
{
    new_event => 1,
    sequenceNumber => 2,
    linkurl => 'http://www.somewhere.com',
    linktext => 'Another great link',
    groupIdView => '7',
    eventlinkId => '28',
},
]);
cmp_deeply(
    $event6->getRelatedLinks(),
    [{
        sequenceNumber => 1,
        linkURL        => 'http://www.nowhere.com',
        linktext       => 'Great link',
        groupIdView    => '7',
        eventlinkId    => '27',
        assetId        => $event6->getId,
    },
    {
        sequenceNumber => 2,
        linkURL        => 'http://www.somewhere.com',
        linktext       => 'Another great link',
        groupIdView    => '7',
        eventlinkId    => '28',
        assetId        => $event6->getId,
    }],
    'related links stored in the database correctly'
);

#######################################
#
# duplicate
#
#######################################

my $event6b = $event6->duplicate();
ok($session->id->valid($event6b->get('storageId')), 'duplicated event got a valid storageId');
isnt($event6b->get('storageId'), $event6->get('storageId'), 'duplicating an asset creates a new storage location');
cmp_deeply(
    $event6b->getRelatedLinks(),
    [{
        sequenceNumber => 1,
        linkURL        => 'http://www.nowhere.com',
        linktext       => 'Great link',
        groupIdView    => '7',
        eventlinkId    => ignore(),
        assetId        => $event6b->getId,
    },
    {
        sequenceNumber => 2,
        linkURL        => 'http://www.somewhere.com',
        linktext       => 'Another great link',
        groupIdView    => '7',
        eventlinkId    => ignore(),
        assetId        => $event6b->getId,
    }],
    'duplicated event has relatedLinks'
);

#######################################
#
# purge
#
#######################################
{
    my $storage   = $event6b->getStorageLocation;
    my $assetId   = $event6b->getId;
    $event6b->purge;
    my $count = $session->db->quickScalar('select count(*) from Event_relatedlink where assetId=?',[$assetId]);
    is $count, 0, 'purge: related links cleaned up in the database';
    ok ! -d $storage->getPath(), '... storage location removed, too';
}
