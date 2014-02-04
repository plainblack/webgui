# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use Test::Deep;
use Test::Warn;
use Test::Exception;
use HTML::Form;
use JSON;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Activity;
use WebGUI::Group;
use WebGUI::User;
use WebGUI::Session;
use WebGUI::Asset::Wobject::EventManagementSystem;
use WebGUI::Asset::Sku::EMSBadge;
use WebGUI::Asset::Sku::EMSTicket;
use WebGUI::Asset::Sku::EMSRibbon;
use WebGUI::Asset::Sku::EMSToken;
use WebGUI::Asset::EMSSubmission;
use WebGUI::Asset::EMSSubmissionForm;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 49;        # Increment this number for each test you create

(my $submitGroupA = WebGUI::Group->new($session,'new'))->name('groupA');
(my $submitGroupB = WebGUI::Group->new($session,'new'))->name('groupB');
(my $registrars = WebGUI::Group->new($session, 'new'))->name('registrars');
(my $attendees  = WebGUI::Group->new($session, 'new'))->name('attendees');

(my $registrar = WebGUI::User->new($session,'new'))->update({username=>'registrar'});
(my $userA = WebGUI::User->new($session,'new'))->update({username=>'userA'});
(my $userB = WebGUI::User->new($session,'new'))->update({username=>'userB'});
(my $userC = WebGUI::User->new($session,'new'))->update({username=>'userC'});

$registrars->addUsers([$registrar->getId]);
$submitGroupA->addUsers([$userA->userId,$userC->userId]);
$submitGroupB->addUsers([$userB->userId,$userC->userId]);
$attendees->addUsers([$userA->getId, $userB->getId, $userC->getId]);

WebGUI::Test->addToCleanup($submitGroupA,$submitGroupB);
WebGUI::Test->addToCleanup($registrars, $attendees);
WebGUI::Test->addToCleanup($userA,$userB,$userC,$registrar);

sub loginAdmin { $session->user({userId => 3}); }
sub loginRgstr { $session->user({userId => $registrar->userId}); }
sub loginUserA { $session->user({userId => $userA->userId}); }
sub loginUserB { $session->user({userId => $userB->userId}); }
sub loginUserC { $session->user({userId => $userC->userId}); }
sub logout     { $session->user({userId => 1}); }

#----------------------------------------------------------------------------
# put your tests here

loginAdmin;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

loginRgstr ;

# Add an EMS asset
my $ems = $node->addChild({
    className                =>'WebGUI::Asset::Wobject::EventManagementSystem',
    workflowIdCommit         => 'pbworkflow000000000003', # Commit Content Immediately
    registrationStaffGroupId => $registrars->getId,
    groupIdView              => $attendees->getId,
    submittedLocationsList   => join( "\n", my @submissionLocations = qw'loc1 loc2' ),
});
my $ems_tag = WebGUI::VersionTag->getWorking($session);
$ems_tag->commit;
WebGUI::Test->addToCleanup($ems, $ems_tag);
# I scooped this out ot WG::Asset::Wobject::EventManagementSystem
# its not pretty, but there is no other way to add a meta field
my $mf1Id = $ems->setCollateral("EMSEventMetaField", "fieldId",{
                fieldId=> 'new',
                label => 'mfRequiredUrl',
                dataType => 'url',
                visible => 1,
                required => 1,
                possibleValues => '',
                defaultValues => '',
        },1,1);

my $mf2Id = $ems->setCollateral("EMSEventMetaField", "fieldId",{
                fieldId=> 'new',
                label => 'mfDate',
                dataType => 'date',
                visible => 1,
                required => 0,
                possibleValues => '',
                defaultValues => '',
        },1,1);

my $i18n = $ems->i18n;

$ems = $ems->cloneFromDb;

my $id1 = $ems->getNextSubmissionId;
my $id2 = $ems->getNextSubmissionId;
is( $id1 +1, $id2, ' test getNextSubmissionId' );

# quick test of addGroupToSubmitList
is($ems->get('eventSubmissionGroups'),'', 'event submission groups is blank');
$ems->addGroupToSubmitList('joe');
is($ems->get('eventSubmissionGroups'),'joe', 'event submission groups has one item');
$ems->addGroupToSubmitList('frank');
is($ems->get('eventSubmissionGroups'),'frank joe', 'event submission groups has two items');
$ems->addGroupToSubmitList('joe');
is($ems->get('eventSubmissionGroups'),'joe frank', 'event submission groups still has two items');
$ems->update({eventSubmissionGroups => ''});
is($ems->get('eventSubmissionGroups'),'', 'event submission groups is reset to blank');


is_deeply($ems->getSubmissionLocations, \@submissionLocations, 'test getSubmissionLocations' );
is_deeply( $ems->getSubmissionStatus, {
     map { $_ => $i18n->get($_) } ( qw/pending feedback failed approved created denied/ )
}, 'test getSubmissionStatus' );


loginRgstr;

is( $ems->hasSubmissionForms, 0, 'ems currently has no forms' );

#print 'press return to continue test' ; <>;

my $formAdesc = {
    _fieldList => [ qw/title description startDate/ ],
    title => 1,
    description => 1,
    duration => 0,
    startDate => 1,
    seatsAvailable => 0,
    location => 0,
};


my $frmA = $ems->addSubmissionForm({
    title                    => 'test A -- long',
    canSubmitGroupId         => $submitGroupA->getId,
    daysBeforeCleanup        => 1,
    formDescription          => $formAdesc,
});
isa_ok( $frmA, 'WebGUI::Asset::EMSSubmissionForm' );
is( $ems->hasSubmissionForms, 1, 'ems now has forms' );
is_deeply( $frmA->getFormDescription, $formAdesc, 'form description matches' );
is( $frmA->ems->getId, $ems->getId, 'test ems access function in form' );

my $formBdesc = {
    _fieldList => [ qw/title description duration mfRequiredUrl/ ],
    title => 1,
    description => 1,
    duration => 1,
    startDate => 0,
    mfRequiredUrl => 1,
    seatsAvailable => 0,
    location => 0,
};
my $frmB = $ems->addSubmissionForm({
    className                => 'WebGUI::Asset::EMSSubmissionForm',
    title                    => 'test B -- short',
    daysBeforeCleanup        => 1,
    canSubmitGroupId         => $submitGroupB->getId,
    formDescription          => $formBdesc,
});
logout;

ok( !$ems->canSubmit, 'Visitor cannot submit to this ems' );
ok( !$frmA->canSubmit, 'Visitor cannot submit to form' );

loginUserA;

ok( $ems->canSubmit, 'UserA can submit to this ems' );
ok( $frmA->canSubmit, 'UserA can submit to formA' );
ok( !$frmB->canSubmit, 'UserA cannot submit to formB' );
#print 'press return to complete test' ; <>;
ok( !$ems->hasSubmissions, 'UserA has no submissions' );

my $submission = {
    title => 'my favorite thing to talk about',
    description => 'the description',
    startDate => '1255150800',
};
$session->request->setup_body($submission);
my $sub1 = $frmA->addSubmission;
WebGUI::Test->addToCleanup( $sub1 );
print join( "\n", @{$sub1->{errors}} ),"\n" if defined $sub1->{errors};
my $isa1 = isa_ok( $sub1, 'WebGUI::Asset::EMSSubmission', "userA/formA valid submission succeeded" );
ok( $ems->hasSubmissions, 'UserA has submissions on this ems' );
is( $sub1->ems->getId, $ems->getId, 'test ems access function in submission' );
loginUserB;

ok( $ems->canSubmit, 'UserB can submit to this ems' );
ok( !$frmA->canSubmit, 'UserB cannot submit to formA' );
ok( $frmB->canSubmit, 'UserB can submit to formB' );

$submission = {
    title => 'why i like to be important',
    description => 'the description',
    mfRequiredUrl => 'http://google.com',
};
$session->request->setup_body($submission);
my $sub2 = $frmB->addSubmission;
WebGUI::Test->addToCleanup( $sub2 );
my $isa2 = isa_ok( $sub2, 'WebGUI::Asset::EMSSubmission', "userB/FormB valid submission succeeded" );

loginUserC;

ok( $ems->canSubmit, 'UserC can submit to this ems' );
ok( $frmA->canSubmit, 'UserC can submit to formA' );
ok( $frmB->canSubmit, 'UserC can submit to formB' );

loginUserA;
cmp_deeply( from_json($ems->www_getAllSubmissions), {
          sort => undef,
          startIndex => 1,
          records => [
                         {
                           lastReplyDate => '',
                           submissionId => $sub1->get('submissionId'),
                           creationDate => ignore(),
                           createdBy => 'userA',
                           url => ignore(),
                           submissionStatus => $i18n->get('pending'),
                           title => 'my favorite thing to talk about',
                           lastReplyBy => ''
                         }
                       ],
          totalRecords => '1',
          recordsReturned => 25,
          dir => 'DESC',
}, 'test getAllSubmissions for UserA' );

$session->request->setup_body({submissionId => $sub1->get('submissionId')});
cmp_deeply( from_json($ems->www_getSubmissionById), {
    title => $sub1->get('submissionId'),
    id => $sub1->get('submissionId'),
    text => ignore(),
}, 'test getSubmissionById');

loginUserC;
cmp_deeply( from_json($ems->www_getAllSubmissions), {
          sort => undef,
          startIndex => 1,
          records => [
                       ],
          totalRecords => '0',
          recordsReturned => 25,
          dir => 'DESC',
}, 'test getAllSubmissions for UserC' );

loginRgstr;
$session->request->setup_body({ orderByColumn => 'submissionId' });
cmp_deeply( from_json($ems->www_getAllSubmissions), {
          sort => 'submissionId',
          startIndex => 1,
          records => [
                         {
                           lastReplyDate => '',
                           submissionId => $sub2->get('submissionId'),
                           creationDate => ignore(),
                           createdBy => 'userB',
                           url => ignore(),
                           submissionStatus => $i18n->get('pending'),
                           title => 'why i like to be important',
                           lastReplyBy => ''
                         },
                         {
                           lastReplyDate => '',
                           submissionId => $sub1->get('submissionId'),
                           creationDate => ignore(),
                           createdBy => 'userA',
                           url => ignore(),
                           submissionStatus => $i18n->get('pending'),
                           title => 'my favorite thing to talk about',
                           lastReplyBy => ''
                         },
                       ],
          totalRecords => '2',
          recordsReturned => 25,
          dir => 'DESC',
}, 'test getAllSubmissions for Registrar' );

SKIP: { skip 'create submission failed', 8 unless $isa1 && $isa2;

loginUserA;

$sub1->addComment( 'this is a test comment' );
cmp_deeply($sub1->get('comments')->[0],{
      id => re( qr/.+/ ),
      alias => 'userA',
      userId => $userA->userId,
      comment => 'this is a test comment',
      rating => 0,
      date => re( qr/\d{10}/ ),
      ip => ignore(),
}, "successfully added comment" );

$sub1->update({
    title => 'the new title'
});

is( $sub1->get('title'),'the new title','successfully changed the title');

loginRgstr;

$sub1->update({ submissionStatus => 'approved' });
is($sub1->get('submissionStatus'),'approved','set status to approved');

$sub2->update({ submissionStatus => 'denied' });
is($sub2->get('submissionStatus'),'denied','set status to denied');
diag $sub1->submissionStatus;
diag $sub1->ticketId;

SKIP: { skip "workflow activities not coded yet", 10 if 0;

# create the workflows/activities for processing
my $approveSubmissions = WebGUI::Test::Activity->create( $session,
              "WebGUI::Workflow::Activity::ProcessEMSApprovals"
);
my $cleanupSubmissions = WebGUI::Test::Activity->create( $session,
              "WebGUI::Workflow::Activity::CleanupEMSSubmissions"
);

is($approveSubmissions->run, 'complete', 'approval complete');
is($approveSubmissions->run, 'done', 'approval done');

$sub1 = $sub1->cloneFromDb;
diag $sub1->submissionStatus;
diag $sub1->ticketId;
diag $sub1->getRevisionCount;
is( $sub1->get('submissionStatus'),'approved','approval successfull');

my $ticket = eval { WebGUI::Asset->newById($session, $sub1->get('ticketId')); };
my $e = Exception::Class->caught();
SKIP: {
    skip 'no ticket created', 2 if $e;
    isa_ok( $ticket, 'WebGUI::Asset::Sku::EMSTicket', 'approval created a ticket');
    WebGUI::Test->addToCleanup( $ticket ) if $ticket ;
    is( $ticket->get('title'), $sub1->get('title'), 'Ticket title matches submission title' );
}
 
my $newDate = time - ( 60 * 60 * 24 * ( $sub2->getParent->get('daysBeforeCleanup') + 1 ) ),
$sub2->update({
    submissionStatus => 'denied',
    # lastModified => $newDate,  -- update overrides this...
});
my $sub2Id = $sub2->getId;
$session->db->write('update assetData set lastModified = ' . $newDate . ' where assetId = "' . $sub2Id . '"' );

$cleanupSubmissions->reset;
is($cleanupSubmissions->run, 'complete', 'cleanup complete');
is($cleanupSubmissions->run, 'done', 'cleanup done');

dies_ok { WebGUI::Asset->newById($session, $sub2Id) } 'submission deleted';

} # end of workflow skip

} # end of create submission skip

# this is not the greatest test but it does run through the basic create submissionForm code.
loginRgstr;

my %settings = (
    assetId => 'new',
    fieldNames => "title description startDate duration seatsAvailable location $mf1Id $mf2Id",
    title => 'Untitled',
    menuTitle => 'Untitled',
    url => '',
    canSubmitGroupId => 2,
    daysBeforeCleanup => 7,
    deleteCreatedItems => 0,
    submissionDeadline => '1991-06-21',
    pastDeadlineMessage => 'The deadline for this submission is past, no more submissions will be taken at this time.',
    title_yesNo => 1,
    description_yesNo => 1,
    startDate_yesNo => 1,
    duration_yesNo => 1,
    seatsAvailable_yesNo => 1,
    location_yesNo => 1,
    $mf1Id . '_yesNo' => 1,
    $mf2Id . '_yesNo' => 1,
);

my $expected = {
          'submissionDeadline' => '1991-06-21',
          'menuTitle' => 'Untitled',
          'pastDeadlineMessage' => $settings{pastDeadlineMessage},
          'formDescription' => {
                                 'location' => '1',
                                 $mf1Id => 1,
                                 $mf2Id => 1,
                                 'seatsAvailable' => '1',
                                 'duration' => '1',
                                 'title' => '1',
                                 'startDate' => '1',
                                 'description' => '1',
				 'submissionStatus' => '0',
                                 '_fieldList' => [
                                                   'title',
                                                   'description',
                                                   'startDate',
                                                   'duration',
                                                   'seatsAvailable',
                                                   'location',
                                                   $mf1Id,
						   $mf2Id,
                                                 ]
                               },
          'description' => undef,
          '_isValid' => 1,
          'deleteCreatedItems' => 0,
          'canSubmitGroupId' => '2',
          'assetId' => 'new',
          'url' => '',
          'daysBeforeCleanup' => '7',
          'title' => 'Untitled',
        } ;

my $htmlText = $ems->www_addSubmissionForm;
my $form = HTML::Form->parse($htmlText,'http://localhost/');
isnt( $form, undef, 'form created successfully' );
my $result;
SKIP: { skip 'failed to create form', 1 unless $form;
    for my $input ( $form->inputs ) {
        $input->value($settings{$input->name})if exists $settings{$input->name};
    }
    $session->request->setup_body( { $form->form } );
    $result = WebGUI::Asset::EMSSubmissionForm->processForm($ems);
    cmp_deeply( $result, $expected , 'test process form -- with data' );
}
$expected = {
          'errors' => [
                        {
                          'text' => ignore(),
                        }
                      ],
          'submissionDeadline' => undef,
          'menuTitle' => undef,
          'pastDeadlineMessage' => undef,
          'formDescription' => {
                                 '_fieldList' => [],
				 'submissionStatus' => 0,
                               },
          'description' => undef,
          '_isValid' => 0,
          'deleteCreatedItems' => undef,
          'canSubmitGroupId' => undef,
          'assetId' => undef,
          'url' => undef,
          'daysBeforeCleanup' => undef,
          'title' => undef,
        };
$session->request->setup_body( { } );
$result = WebGUI::Asset::EMSSubmissionForm->processForm($ems);
cmp_deeply( $result, $expected , 'test process form -- no data' );

# these run code to see that it runs, but do not check for correctness

warnings_are {

$ems->www_viewSubmissionQueue;
$ems->www_addSubmission;
$ems->www_addSubmissionForm;
$ems->www_editSubmissionForm;
$ems->www_editSubmissionFormSave;
$frmA->www_editSubmissionForm;
$frmA->www_addSubmission;
$frmA->www_editSubmission;
$frmA->www_editSubmissionSave;
$frmA->processForm;
$sub1->drawLocationField;
$sub1->drawRelatedBadgeGroupsField;
$sub1->drawRelatedRibbonsField;
$sub1->drawStatusField;
$sub1->www_editSubmission;
$sub1->www_editSubmissionSave;
$sub1->processForm;
# test comments
$sub1->getFormattedComments;

} [], 'no warnings from calling a bunch of functions';

#vim:ft=perl
