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

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Test::MockAsset;
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Group;
use JSON;
use Data::Dumper;
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $registrar = WebGUI::User->create($session);
my $attender  = WebGUI::User->create($session);
my $crasher   = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($registrar, $attender, $crasher);
my $registrars = WebGUI::Group->new($session, 'new');
my $attendees  = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($registrars, $attendees);
$registrars->addUsers([$registrar->getId]);
$attendees->addUsers([$attender->getId]);

# Do our work in the import node
my $node = WebGUI::Test->asset;

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"EventManagementSystem Test"});

# Add an EMS asset
my $ems = $node->addChild({
    className                =>'WebGUI::Asset::Wobject::EventManagementSystem', 
    title                    => 'Test EMS', 
    description              => 'This is a test ems', 
    url                      => 'test-ems',
    workflowIdCommit         => 'pbworkflow000000000003', # Commit Content Immediately
    registrationStaffGroupId => $registrars->getId,
    groupIdView              => $attendees->getId,
});
$versionTag->commit;
WebGUI::Test->addToCleanup($versionTag);
$ems = $ems->cloneFromDb;

# Test for a sane object type
isa_ok($ems, 'WebGUI::Asset::Wobject::EventManagementSystem');

# Test to see if we can set new values
my $newEMSSettings = {
    timezone => 'America/New_York',
};

# update the new values for this instance
$ems->update($newEMSSettings);

# Let's check our updated values
foreach my $newSetting (keys %{$newEMSSettings}) {
    is ($ems->get($newSetting), $newEMSSettings->{$newSetting}, "updated $newSetting is ".$newEMSSettings->{$newSetting});
}

my $preparedView = $ems->prepareView();
ok($preparedView, 'prepareView returns something');

my $view = $ems->view();
ok($view, 'View returns something');

$session->user({ userId => 1 });
ok($ems->isRegistrationStaff == 0, 'Visitor is not part of registration staff');

# Become admin for testing
$session->user({ userId => $registrar->getId });
ok($ems->isRegistrationStaff == 1, 'User is part of registration staff');

$session->user({ userId => 3 });
# Add two badges, using addChild instead of Mech
my @badges;
push(@badges, $ems->addChild({
    className=>'WebGUI::Asset::Sku::EMSBadge',
    title => 'title',
    description => 'desc',
}));

push(@badges, $ems->addChild({
    className=>'WebGUI::Asset::Sku::EMSBadge',
    title => 'title',
    description => 'desc',
}));

foreach my $badge(@badges) {
    ok(ref($badge) eq 'WebGUI::Asset::Sku::EMSBadge', 'Badge added');
}

# Check that both badges exists
my $badges = $ems->getBadges;
ok(scalar(@$badges) == 2, 'Two Badges exist');

# Add tickets
my @tickets;
push(@tickets, $ems->addChild({
    className      => 'WebGUI::Asset::Sku::EMSTicket',
    title          => 'Test Ticket 1',
    url            => 'test-ems/ticket-1',
    startDate      => '2009-01-01 14:00:00',
    eventNumber    => 1,
    location       => 'qq',
    seatsAvailable => 5,
    price          => 5,
    duration       => 1,
}));
push(@tickets, $ems->addChild({
    className      => 'WebGUI::Asset::Sku::EMSTicket',
    title          => 'Test Ticket 2',
    url            => 'test-ems/ticket-2',
    startDate      => '2009-01-01 14:00:00',
    eventNumber    => 2,
    location       => 'qq',
    seatsAvailable => 3,
    price          => 10,
    duration       => 2,
}));

foreach my $ticket(@tickets) {
    ok(ref($ticket) eq 'WebGUI::Asset::Sku::EMSTicket', 'Ticket added');
}

ok($ems->can('getTickets'), 'Can get tickets');
my $tickets = $ems->getTickets;
ok(scalar(@$tickets) == 2, 'Two tickets exist');

# Add ribbons
my @ribbons;
push(@ribbons, $ems->addChild({className=>'WebGUI::Asset::Sku::EMSRibbon'}));
push(@ribbons, $ems->addChild({className=>'WebGUI::Asset::Sku::EMSRibbon'}));

foreach my $ribbon(@ribbons) {
    ok(ref($ribbon) eq 'WebGUI::Asset::Sku::EMSRibbon', 'Ribbon added');
}

ok($ems->can('getRibbons'), 'Can get ribbons');
my $ribbons = $ems->getRibbons;
ok(scalar(@$ribbons) == 2, 'Two ribbons exist');

ok( $ems->can('www_getScheduleDataJSON'), 'Can call get Schedule data' );
ok( $ems->can('www_viewSchedule'), 'Can call view Schedule' );
ok( $ems->can('www_printRemainingTickets'), 'Can call print remaining tickets' );


#Test that the default template is correct
my $printRemainingTicketsTemplateId = $ems->get('printRemainingTicketsTemplateId');
is($printRemainingTicketsTemplateId, "hreA_bgxiTX-EzWCSZCZJw", 'Default print remaining tickets template id ok');

#Make sure printRemainingTickets template returns the right data
{
    my $templateMock = WebGUI::Test::MockAsset->new('WebGUI::Asset::Template');
    $templateMock->mock_id($printRemainingTicketsTemplateId);
    my $templateVars;
    $templateMock->mock('process', sub { $templateVars = $_[1]; } );

    $ems->www_printRemainingTickets();

    my $ticket1 = {
        'seatsRemaining'        => '5',
        'ticketTitle'           => 'Test Ticket 1',
        'newWindow'             => ignore(),
        'extraHeadTagsPacked'   => ignore(),
        'synopsis'              => ignore(),
        'extraHeadTags'         => ignore(),
        'ownerUserId'           => ignore(),
        'url'                   => 'test-ems/ticket-1',
        'assetId'               => ignore(),
        'isPrototype'           => ignore(),
        'isHidden'              => ignore(),
        'groupIdEdit'           => ignore(),
        'inheritUrlFromParent'  => ignore(),
        'ticketEventNumber'     => '1',
        'lastModified'          => ignore(),
        'price'                 => '5',
        'title'                 => 'Test Ticket 1',
        'groupIdView'           => ignore(),
        'ticketLocation'        => 'qq',
        'skipNotification'      => ignore(),
        'status'                => ignore(),
        'menuTitle'             => 'Test Ticket 1',
        'assetSize'             => ignore(),
        'ticketDuration'        => '1',
        'relatedRibbons'        => ignore(),
        'revisionDate'          => ignore(),
        'relatedBadgeGroups'    => ignore(),
        'isPackage'             => ignore(),
        'usePackedHeadTags'     => ignore(),
        'encryptPage'           => ignore(),
        'eventMetaData'         => ignore(),
        'tagId'                 => ignore(),
        'seatsAvailable'        => '5',
        'revisedBy'             => ignore(),
        'isExportable'          => ignore(),
        'creationDate'          => ignore(),
        'ticketStart'           => '2009-01-01 09:00',
        'ticketStart_epoch'     => '1230818400',
    };

    my $ticket2 = {
        'seatsRemaining'        => '3',
        'ticketTitle'           => 'Test Ticket 2',
        'newWindow'             => ignore(),
        'extraHeadTagsPacked'   => ignore(),
        'synopsis'              => ignore(),
        'extraHeadTags'         => ignore(),
        'ownerUserId'           => ignore(),
        'url'                   => 'test-ems/ticket-2',
        'assetId'               => ignore(),
        'isPrototype'           => ignore(),
        'isHidden'              => ignore(),
        'groupIdEdit'           => ignore(),
        'inheritUrlFromParent'  => ignore(),
        'ticketEventNumber'     => '2',
        'lastModified'          => ignore(),
        'price'                 => '10',
        'title'                 => 'Test Ticket 2',
        'groupIdView'           => ignore(),
        'ticketLocation'        => 'qq',
        'skipNotification'      => ignore(),
        'status'                => ignore(),
        'menuTitle'             => 'Test Ticket 2',
        'assetSize'             => ignore(),
        'ticketDuration'        => '2',
        'relatedRibbons'        => ignore(),
        'revisionDate'          => ignore(),
        'relatedBadgeGroups'    => ignore(),
        'isPackage'             => ignore(),
        'usePackedHeadTags'     => ignore(),
        'encryptPage'           => ignore(),
        'tagId'                 => ignore(),
        'eventMetaData'         => ignore(),
        'seatsAvailable'        => '3',
        'revisedBy'             => ignore(),
        'isExportable'          => ignore(),
        'creationDate'          => ignore(),
        'ticketStart'           => '2009-01-01 09:00',
        'ticketStart_epoch'     => '1230818400',
    };
    
    my @ticketArray = ();
    for(1..3) {
        push(@ticketArray,$ticket2);
    }
    for(1..5) {
        push(@ticketArray,$ticket1);
    }

    cmp_deeply(
        $templateVars,
        {
            'badgeInstructions'                 => ignore(),
            'displayTitle'                      => ignore(),
            'createdBy'                         => ignore(),
            'lastExportedAs'                    => ignore(),
            'printRemainingTicketsTemplateId'   => ignore(),
            'state'                             => ignore(),
            'printTicketTemplateId'             => ignore(),
            'newWindow'                         => ignore(),
            'scheduleColumnsPerPage'            => ignore(),
            'synopsis'                          => ignore(),
            'extraHeadTagsPacked'               => ignore(),
            'ownerUserId'                       => ignore(),
            'extraHeadTags'                     => ignore(),
            'assetId'                           => ignore(),
            'assetIdHex'                        => ignore(),
            'url'                               => 'test-ems',
            'isHidden'                          => ignore(),
            'isPrototype'                       => ignore(),
            'groupIdEdit'                       => ignore(),
            'timezone'                          => ignore(),
            'styleTemplateId'                   => ignore(),
            'inheritUrlFromParent'              => ignore(),
            'description'                       => 'This is a test ems',
            'stateChangedBy'                    => ignore(),
            'lineage'                           => ignore(),
            'className'                         => 'WebGUI::Asset::Wobject::EventManagementSystem',
            'lastModified'                      => ignore(),
            'title'                             => 'Test EMS',
            'groupIdView'                       => ignore(),
            'mobileStyleTemplateId'             => ignore(),
            'skipNotification'                  => ignore(),
            'scheduleTemplateId'                => ignore(),
            'status'                            => ignore(),
            'menuTitle'                         => 'Test EMS',
            'assetSize'                         => ignore(),
            'lookupRegistrantTemplateId'        => ignore(),
            'isLockedBy'                        => ignore(),
            'stateChanged'                      => ignore(),
            'revisionDate'                      => ignore(),
            'ribbonInstructions'                => ignore(),
            'isPackage'                         => ignore(),
            'usePackedHeadTags'                 => ignore(),
            'templateId'                        => ignore(),
            'badgeBuilderTemplateId'            => ignore(),
            'printBadgeTemplateId'              => ignore(),
            'encryptPage'                       => ignore(),
            'tagId'                             => ignore(),
            'isSystem'                          => ignore(),
            'revisedBy'                         => ignore(),
            'isExportable'                      => ignore(),
            'creationDate'                      => ignore(),
            'registrationStaffGroupId'          => ignore(),
            'parentId'                          => ignore(),
            'tokenInstructions'                 => ignore(),
            'printableStyleTemplateId'          => ignore(),
            'ticketInstructions'                => ignore(),
            'eventSubmissionGroups'             => ignore(),
            'eventSubmissionMainTemplateId'     => ignore(),
            'eventSubmissionQueueTemplateId'    => ignore(),
            'eventSubmissionTemplateId'         => ignore(),
            'submittedLocationsList'            => ignore(),
            'keywords'                          => ignore(),
            'uiLevel'                           => ignore(),
            'tickets_loop'                      => \@ticketArray,
            controls                            => ignore(),
            keywords                            => ignore(),
         },
        "www_printRemainingTickets: template variables valid"
    );
}

#Make sure permissions work on pages
my $data;
$session->user({userId => $crasher->getId});
$session->response->status(201);
$data = $ems->www_viewSchedule();
is($session->response->status, 401, 'www_viewSchedule: visitor may not see the schedule');
$data = $ems->www_printRemainingTickets();
is($session->response->status, 401, 'www_printRemainingTickets: visitor may not print the remaining tickets');

$session->response->status(201);
$session->user({userId => $attender->getId});
$data = $ems->www_viewSchedule();
is($session->response->status, 201, '... attender user can see the schedule');
$data = $ems->www_printRemainingTickets();
is($session->response->status, 401, 'www_printRemainingTickets: attender may not print the remaining tickets');

$session->response->status(201);
$session->user({userId => $registrar->getId});
$data = $ems->www_printRemainingTickets();
is($session->response->status, 201, 'www_printRemainingTickets: registration staff may print the remaining tickets');


$session->response->status(201);
$session->user({userId => $crasher->getId});
my ($json, $records);
$json    = $ems->www_getScheduleDataJSON();
$records = eval { JSON::from_json($json)->{records} };
cmp_deeply($records, [], 'www_getScheduleDataJSON: visitor may not see the schedule JSON');

$session->user({userId => $attender->getId});
$json    = $ems->www_getScheduleDataJSON();
$records = eval { JSON::from_json($json)->{records} };
cmp_deeply($records, [ignore(), ignore(), ignore()], '... attender can see the schedule JSON');

foreach my $ticket (@tickets) {
    $ticket->purge;
}

my $html = $ems->www_viewSchedule();
ok( $html !~ /REPLACE/, 'tags were successfully replaced');
# print 'html={', $html, "}\n";
$data = $ems->www_getScheduleDataJSON();
cmp_deeply( JSON::from_json($data),
      {
          records => [],
          pageSize => 0,
          dir => 'asc',
          recordsReturned => 0,
          totalRecords => 0,
          totalLocationPages => 0,
          currentLocationPage => 0,
          totalDatePages => 0,
          currentDatePage => 0,
          dateRecords => [ ],
          sort => undef,
          startIndex => 0,
        },
     'empty set: schedule data looks good' );

my @tickets= (
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 1 room a 10 am',
    eventNumber => 1,
    startDate => '2009-01-01 10:00:00',
    location => 'a',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 2 room b 10 am',
    eventNumber => 2,
    startDate => '2009-01-01 10:00:00',
    location => 'b',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 3 room c 10 am',
    eventNumber => 3,
    startDate => '2009-01-01 10:00:00',
    location => 'c',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 4 room a 11 am',
    eventNumber => 4,
    startDate => '2009-01-01 11:00:00',
    location => 'a',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 5 room b 11 am',
    eventNumber => 5,
    startDate => '2009-01-01 11:00:00',
    location => 'b',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 6 room c 11 am',
    eventNumber => 6,
    startDate => '2009-01-01 11:00:00',
    location => 'c',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 7 room d 12 am',
    eventNumber => 7,
    startDate => '2009-01-01 12:00:00',
    location => 'd',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 8 room a 1 pm',
    eventNumber => 8,
    startDate => '2009-01-01 13:00:00',
    location => 'a',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 9 room b 1 pm',
    eventNumber => 9,
    startDate => '2009-01-01 13:00:00',
    location => 'b',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 10 room c 1 pm',
    eventNumber => 10,
    startDate => '2009-01-01 13:00:00',
    location => 'c',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 11 room e 2 pm',
    eventNumber => 11,
    startDate => '2009-01-01 14:00:00',
    location => 'e',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 12 room f 2 pm',
    eventNumber => 12,
    startDate => '2009-01-01 14:00:00',
    location => 'f',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 13 blank location 2 pm',
    eventNumber => 13,
    startDate => '2009-01-01 14:00:00',
    location => '',
    }),
    $ems->addChild({
    className => "WebGUI::Asset::Sku::EMSTicket",
    title => 'lecture 14 blank location 2 pm',
    eventNumber => 14,
    startDate => '2009-01-01 14:00:00',
    location => '',
    }),
);
is( scalar(@tickets), 14, 'created tickets for ems');
my $tickets = $ems->getTickets;
is(scalar(@{ $tickets }), 14, 'Fourteen tickets exist');
my $locations = [ $ems->getLocations ];
cmp_deeply($locations, [ 'a','b','c','d','e','f','' ], 'get locations returns all expected locations');
# print 'locations=[', join( ',', @$locations ),"]\n";

$data = $ems->www_getScheduleDataJSON();
# print 'json:',$data, "\n";
sub ticketInfo { my $tk = shift; return {
    type => 'ticket',
    title => $tk->get('title'),
    assetId => $tk->get('assetId'),
    description => $tk->get('description'),
    location => $tk->get('location') || '&nbsp;',
    startDate => $tk->get('startDate'),
}; }
cmp_deeply( JSON::from_json($data), { 
         records => [
       { colDate => '',
         col1 => { type => 'label', title => 'a' },
         col2 => { type => 'label', title => 'b' },
         col3 => { type => 'label', title => 'c' },
         col4 => { type => 'label', title => 'd' },
         col5 => { type => 'label', title => 'e' },
       },
       { colDate => $tickets[0]->get('startDate'),
         col1 => ticketInfo( $tickets[0] ),
         col2 => ticketInfo( $tickets[1] ),
         col3 => ticketInfo( $tickets[2] ),
         col4 => { type => 'empty' },
         col5 => { type => 'empty' },
       },
       { colDate => $tickets[3]->get('startDate'),
         col1 => ticketInfo( $tickets[3] ),
         col2 => ticketInfo( $tickets[4] ),
         col3 => ticketInfo( $tickets[5] ),
         col4 => { type => 'empty' },
         col5 => { type => 'empty' },
       },
       { colDate => $tickets[6]->get('startDate'),
         col1 => { type => 'empty' },
         col2 => { type => 'empty' },
         col3 => { type => 'empty' },
         col4 => ticketInfo( $tickets[6] ),
         col5 => { type => 'empty' },
       },
       { colDate => $tickets[7]->get('startDate'),
         col1 => ticketInfo( $tickets[7] ),
         col2 => ticketInfo( $tickets[8] ),
         col3 => ticketInfo( $tickets[9] ),
         col4 => { type => 'empty' },
         col5 => { type => 'empty' },
       },
       { colDate => $tickets[10]->get('startDate'),
         col1 => { type => 'empty' },
         col2 => { type => 'empty' },
         col3 => { type => 'empty' },
         col4 => { type => 'empty' },
         col5 => ticketInfo( $tickets[10] ),
       },
     ],
     totalRecords => 6,
         recordsReturned => 6,
         startIndex => 0,
         sort => undef,
         dir => 'asc',
         totalLocationPages => 2,
         currentLocationPage => 1,
         totalDatePages => 1,
         currentDatePage => 1,
         dateRecords => [ '2009-01-01' ],
         pageSize => 10,
         rowsPerPage => 6,
       },
     'Fourteen tickets: schedule data looks good'
);
$session->request->setup_body({ locationPage => 2 } );
$data = $ems->www_getScheduleDataJSON();
cmp_deeply( JSON::from_json($data), { 
         records => [
       { colDate => '',
         col1 => { type => 'label', title => 'f' },
         col2 => { type => 'label', title => '&nbsp;' },
         col3 => { type => 'label', title => '' },
         col4 => { type => 'label', title => '' },
         col5 => { type => 'label', title => '' },
       },
       { colDate => $tickets[11]->get('startDate'),
         col1 => ticketInfo( $tickets[11] ),
         col2 => ticketInfo( $tickets[13] ),
         col3 => { type => 'empty' },
         col4 => { type => 'empty' },
         col5 => { type => 'empty' },
       },
       { colDate => $tickets[13]->get('startDate'),
         col1 => { type => 'empty' },
         col2 => ticketInfo( $tickets[12] ),
         col3 => { type => 'empty' },
         col4 => { type => 'empty' },
         col5 => { type => 'empty' },
       },
     ],
     totalRecords => 3,
         recordsReturned => 3,
         startIndex => 0,
         sort => undef,
         dir => 'asc',
         totalLocationPages => 2,
         currentLocationPage => 2,
         totalDatePages => 1,
         currentDatePage => 1,
         dateRecords => [ '2009-01-01' ],
         pageSize => 10,
         rowsPerPage => 3,
       },
     'Location page #2 looks good'
);

#----------------------------------------------------------------------------
# www_editBadgeGroup
my $ems_tag = WebGUI::VersionTag->getWorking($session);
$ems = WebGUI::Test->asset(
    className   => 'WebGUI::Asset::Wobject::EventManagementSystem',
    groupIdEdit => '3',
);
$ems_tag->commit;
$ems = $ems->cloneFromDb;

my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Create a new one
$mech->get_ok( $ems->getUrl( 'func=editBadgeGroup;badgeGroupId=new' ), "Get form to create a new badge group" );
$mech->submit_form_ok( {
    fields => {
        name => 'Inmate Training',
    },
}, "create a new badge group" );

my $bgroup = $session->db->quickHashRef(
    "SELECT * FROM EMSBadgeGroup WHERE name=?",
    [ "Inmate Training" ],
);
ok( $bgroup, "Badge group exists" );
is( $bgroup->{emsAssetId}, $ems->getId, 'ems asset id set correctly' );

# Edit existing one
$mech->get_ok( 
    $ems->getUrl( 'func=editBadgeGroup;badgeGroupId=' . $bgroup->{badgeGroupId} ), 
    "Get form to edit our badge group",
);
$mech->submit_form_ok( {
    fields  => {
        name    => 'Inmate Beating',
    },
}, "Edit an existing badge group" );

$bgroup = $session->db->quickHashRef(
    "SELECT * FROM EMSBadgeGroup WHERE badgeGroupId=?",
    [ $bgroup->{badgeGroupId} ],
);
ok( $bgroup, "Badge group exists" );
is( $bgroup->{emsAssetId}, $ems->getId, 'ems asset id set correctly' );
is( $bgroup->{name}, "Inmate Beating", 'badge name set correctly' );

#----------------------------------------------------------------------------
# www_editEventMetaField
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Create a new one
my %metaField = ( 
    label => 'Security Level',
    visible => 1,
    required => 1,
    dataType => 'Text',
    helpText => 'What security level is required for this event?',
);

$mech->get_ok( $ems->getUrl( 'func=editEventMetaField' ), 'Get form to create new meta field' );
$mech->submit_form_ok( {
    fields => { %metaField },
}, 'create a new meta field' );

# Meta field exists
my $field = $session->db->quickHashRef(
    "SELECT * FROM EMSEventMetaField WHERE assetId=?",
    [ $ems->getId ],
);
ok( $field, 'meta field exists' );
cmp_deeply(
    $field,
    superhashof( { %metaField, assetId => $ems->getId } ), 
    'meta field contains correct data',
);

# Edit existing one
$metaField{ helpText } = "This is new help text";
$mech->get_ok( 
    $ems->getUrl( 'func=editEventMetaField;fieldId=' . $field->{fieldId} ), 
    'Get form to edit meta field' 
);
$mech->submit_form_ok( {
    fields => { %metaField },
}, 'create a new meta field' );

# Meta field still exists
my $field = $session->db->quickHashRef(
    "SELECT * FROM EMSEventMetaField WHERE assetId=?",
    [ $ems->getId ],
);
ok( $field, 'meta field exists' );
cmp_deeply(
    $field,
    superhashof( { %metaField, assetId => $ems->getId } ), 
    'meta field contains correct data',
);

#----------------------------------------------------------------------------
# getEventFieldsForImport
use Data::Dumper;
my $fields = $ems->getEventFieldsForImport;
cmp_deeply(
    $fields,
    array_each( superhashof( {
        type    => ignore(),
        name    => ignore(),
        label   => ignore(),
    } ) ),
    'getEventFieldsForImport contains correct items',
);

#----------------------------------------------------------------------------
# www_importEvents
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

$mech->get_ok( $ems->getUrl( 'func=importEvents' ), 'get form to import events' );
$mech->set_fields( 
    file_file => WebGUI::Test::collateral( "ems_events.csv" ),
    ignore_first_line => 1,
);
# Remove the fields we don't have
my @unticks = qw( assetId vendorId seatsAvailable price eventNumber location relatedBadgeGroups
    relatedRibbons
);
for my $val ( @unticks ) {
    $mech->untick( 'fieldsToImport', $val );
}
$mech->click_ok( "send", "import files" );

# Events exist
my $events = $ems->getLineage( ['children'], {
    includeOnlyClasses => ['WebGUI::Asset::Sku::EMSTicket'],
    returnObjects => 1,
} );
is( scalar @$events, 2, '2 events added' );
cmp_deeply(
    [ map { $_->get } sort { $a->title cmp $b->title } @$events ],
    [ superhashof( 
            { 
                title => "One",
                description => "Oneness",
                startDate => WebGUI::DateTime->new( $session, mysql => '2010-01-01 00:00:00', time_zone => $session->user->get('timeZone'), )->toMysql,
                duration => 2,
            }
        ),
        superhashof(
            {
                title => 'Two',
                description => 'Twoness',
                startDate => WebGUI::DateTime->new( $session, mysql => '2010-02-02 00:00:00', time_zone => $session->user->get('timeZone') )->toMysql,
                duration => 3,
            }
        ),
    ],
    'correct asset props are set'
);


#----------------------------------------------------------------------------
# www_manageRegistrant
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Need a badge
my $badger_tag = WebGUI::VersionTag->getWorking($session);
my $badger = $ems->addChild({
        className => 'WebGUI::Asset::Sku::EMSBadge',
        title => 'Badgers',
    });
$badger_tag->commit;
$badger = $badger->cloneFromDb;
# Add cart and complete checkout
my $regBadgeId 
    = $session->db->setRow( 'EMSRegistrant', 'badgeId', {
        badgeId => "new",
        badgeAssetId => $badger->getId,
        emsAssetId => $ems->getId,
    } );

$mech->get_ok( $ems->getUrl( 'func=manageRegistrant;badgeId=' . $regBadgeId ) );
my %reg = (
    userId      => '3',
    name        => 'Homer S.',
    address1    => '742 Evergreen Terr.',
    city        => 'Springfield',
    notes       => 'Will need assistance.',
);
$mech->submit_form_ok({
        fields => { %reg },
    }, 
    "save our registrant's information" 
);

my $regInfo = $session->db->getRow( 'EMSRegistrant', 'badgeId', $regBadgeId );
cmp_deeply( 
    $regInfo,
    superhashof( {
        %reg, 
        badgeAssetId => $badger->getId,
        emsAssetId => $ems->getId,
    } ),
    "Registrant info saved correctly",
);

done_testing;
