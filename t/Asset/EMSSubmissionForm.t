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

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my @cleanup = ();

#----------------------------------------------------------------------------
# Tests

plan tests => 50;        # Increment this number for each test you create

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

WebGUI::Test->groupsToDelete($submitGroupA,$submitGroupB);
WebGUI::Test->groupsToDelete($registrars, $attendees);
WebGUI::Test->usersToDelete($userA,$userB,$userC,$registrar);

sub loginAdmin { $session->user({userId => 3}); }
sub loginRgstr { $session->user({userId => $registrar->userId}); }
sub loginUserA { $session->user({userId => $userA->userId}); }
sub loginUserB { $session->user({userId => $userB->userId}); }
sub loginUserC { $session->user({userId => $userC->userId}); }
sub logout     { $session->user({userId => 1}); }

#----------------------------------------------------------------------------
# put your tests here
eval {
my $use = use_ok 'WebGUI::Asset::EMSSubmissionForm';
$use &&= use_ok 'WebGUI::Asset::EMSSubmission';

SKIP: { skip 'package compile failed!', 1 unless $use;

loginAdmin;

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"EventManagementSystem Test"});
WebGUI::Test->tagsToRollback($versionTag);

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

loginRgstr ;

# Add an EMS asset
my $ems = $node->addChild({
    className                =>'WebGUI::Asset::Wobject::EventManagementSystem',
    title                    => 'Test EMS',
    description              => 'This is a test ems',
    url                      => '/test-ems',
    workflowIdCommit         => 'pbworkflow000000000003', # Commit Content Immediately
    registrationStaffGroupId => $registrars->getId,
    groupIdView              => $attendees->getId
});
# I scooped this out ot WG::Asset::Wobject::EventManagementSystem
# its not pretty, but there is no other way to add a meta field
        $ems->setCollateral("EMSEventMetaField", "fieldId",{
                fieldId=> 'new',
                label => 'mfRequiredUrl',
                dataType => 'url',
                visible => 1,
                required => 1,
                possibleValues => '',
                defaultValues => '',
        },1,1);

        $ems->setCollateral("EMSEventMetaField", "fieldId",{
                fieldId=> 'new',
                label => 'mfDate',
                dataType => 'date',
                visible => 1,
                required => 0,
                possibleValues => '',
                defaultValues => '',
        },1,1);

$versionTag->commit;

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


$versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($versionTag);

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

use lib '/root/pb/lib'; use dav;
dav::dump $session;

my $frmA = $ems->addSubmissionForm({
    title                    => 'test A -- long',
    canSubmitGroupId         => $submitGroupA->getId,
    daysBeforeCleanup        => 1,
    formDescription          => $formAdesc,
});
isa_ok( $frmA, 'WebGUI::Asset::EMSSubmissionForm' );
is( $ems->hasSubmissionForms, 1, 'ems now has forms' );
is_deeply( $frmA->getFormDescription, $formAdesc, 'form description matches' );

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
    daysBeforeCleanup        => 0,
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
push @cleanup, sub  { $sub1->delete; };
print join( "\n", @{$sub1->{errors}} ),"\n" if defined $sub1->{errors};
my $isa1 = isa_ok( $sub1, 'WebGUI::Asset::EMSSubmission', "userA/formA valid submission succeeded" );
ok( $ems->hasSubmissions, 'UserA has submissions on this ems' );

loginUserB;

ok( $ems->canSubmit, 'UserB can submit to this ems' );
ok( !$frmA->canSubmit, 'UserB cannot submit to formA' );
ok( $frmB->canSubmit, 'UserB can submit to formB' );

my $submission = {
    title => 'why i like to be important',
    description => 'the description',
    mfRequiredUrl => 'http://google.com',
        };
$session->request->setup_body($submission);
my $sub2 = $frmB->addSubmission;
push @cleanup, sub  { $sub2->delete; };
my $isa2 = isa_ok( $sub2, 'WebGUI::Asset::EMSSubmission', "userB/FormB valid submission succeeded" );

loginUserC;

ok( $ems->canSubmit, 'UserC can submit to this ems' );
ok( $frmA->canSubmit, 'UserC can submit to formA' );
ok( $frmB->canSubmit, 'UserC can submit to formB' );

# TODO fix num tests
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
      ip => undef,
}, "successfully added comment" );

$sub1->update({
    title => 'the new title'
});

is( $sub1->get('title'),'the new title','successfully changed the title');

loginRgstr;

$sub1->update({ status => 'approved' });
is($sub1->get('status'),'approved','set status to approved');

$sub2->update({ status => 'denied' });
is($sub2->get('status'),'denied','set status to denied');

# create the workflows/activities for processing
my $approveSubmissions = WebGUI::Test::Activity->create( $session,
              "WebGUI::Workflow::Activity::ProcessEMSApprovals"
);
my $cleanupSubmissions = WebGUI::Test::Activity->create( $session,
              "WebGUI::Workflow::Activity::CleanupEMSSubmissions"
);

push @cleanup, sub  { $approveSubmissions->delete; $cleanupSubmissions->delete; };

is($approveSubmissions->run, 'complete', 'approval complete');
is($approveSubmissions->run, 'done', 'approval done');

is( $sub1->get('status'),'failed','submission failed to create');

# TODO fill in the rest of the data required by EMSTicket

is($approveSubmissions->run, 'complete', 'approval complete');
is($approveSubmissions->run, 'done', 'approval done');

is( $sub1->get('status'),'created','approval successfull');

my $ticket = WebGUI::Asset->newByDynamicClass($session, $sub1->get('ticketId'));
isa_ok( $ticket, 'WebGUI::Asset::Sku::EMS_Ticket', 'approval created a ticket');
push @cleanup, sub  { $ticket->delete; };
 
$sub2->update({
    lastModified => time - ( 60 * 60 * 72 ),   # last modified 3 days ago
});
my $submissionId = $sub2->get('assetId');

is($cleanupSubmissions->run, 'complete', 'cleanup complete');
is($cleanupSubmissions->run, 'done', 'cleanup done');

$sub2 = WebGUI::Asset->newByDynamicClass($session, $submissionId);
is( $sub2, undef, 'approval created a ticket');

# TODO add a test to cleanup denied and created entries

} # end of create submission skip

$versionTag->commit;


SKIP: { skip 'requires HTML::Form', 2 unless use_ok 'HTML::Form';
# this is not the greatest testm but it does run through the basic create submissionForm code.
loginAdmin;

my %settings = (
    assetId => 'new',
    fieldNames => 'title description startDate duration seatsAvailable location nzymEeuHPQIsgXY0hZxDxA xlvMNwFi1FWwP0PrUAnxSQ',
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
    nzymEeuHPQIsgXY0hZxDxA_yesNo => 1,
    xlvMNwFi1FWwP0PrUAnxSQ_yesNo => 1,
);

my $expected = {
          'submissionDeadline' => '1991-06-21',
          'menuTitle' => 'Untitled',
          'pastDeadlineMessage' => 'The deadline for this submission is past, no more submissions will be taken at this time.',
          'formDescription' => {
                                 'location' => '1',
                                 'nzymEeuHPQIsgXY0hZxDxA' => 'xlvMNwFi1FWwP0PrUAnxSQ',
                                 'seatsAvailable' => '1',
                                 'duration' => '1',
                                 'title' => '1',
                                 'startDate' => '1',
                                 'description' => '1',
                                 '_fieldList' => [
                                                   'title',
                                                   'description',
                                                   'startDate',
                                                   'duration',
                                                   'seatsAvailable',
                                                   'location',
                                                   'nzymEeuHPQIsgXY0hZxDxA'
                                                 ]
                               },
          'description' => undef,
          '_isValid' => 1,
          'deleteCreatedItems' => undef,
          'canSubmitGroupId' => '2',
          'assetId' => 'new',
          'url' => undef,
          'daysBeforeCleanup' => '7',
          'title' => 'Untitled'
        } ;

my $htmlText = $ems->www_addSubmissionForm;
my $form = HTML::Form->parse($htmlText,'http://localhost/');
for my $input ( $form->inputs ) {
    $input->value($settings{$input->name})if exists $settings{$input->name};
}
$session->request->setup_body( { $form->form } );
my $result = WebGUI::Asset::EMSSubmissionForm->processForm($ems);
dav::dump $result;
cmp_deeply( $result, $expected , 'test process form' );
$expected = {
          'errors' => [
                        {
                          'text' => 'you should turn on at least one entry field'
                        }
                      ],
          'submissionDeadline' => undef,
          'menuTitle' => undef,
          'pastDeadlineMessage' => undef,
          'formDescription' => {
                                 '_fieldList' => []
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
dav::dump $result;
cmp_deeply( $result, $expected , 'test process form' );
} # end of skip HTML::Form

} # end of use packages skip

}; # end of eval
print $@ if $@;

#done_testing();
#print 'press return to complete test' ; <>;
#----------------------------------------------------------------------------
# Cleanup
END {
   map { eval { $_->() } } ( @cleanup );
}
#vim:ft=perl
