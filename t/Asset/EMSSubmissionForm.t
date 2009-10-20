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
use WebGUI::Group;
use WebGUI::User;
use WebGUI::Test::Activity;
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

my $useform = use_ok 'WebGUI::Asset::EMSSubmissionForm';
my $usesubmiss = use_ok 'WebGUI::Asset::EMSSubmission';

SKIP: { skip 'package compile failed!', 50 unless $useform && $usesubmiss;

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

is( $ems->hasForms, 0, 'ems currently has no forms' );

#print 'press return to continue test' ; <>;

my $formAdesc = {
    title => { type => 'text' },
    descrition => { type => 'textarea' },
    duration => { default => 2.0 },
    startDate => { type => 'selectList',
               options =>  [ '1255150800', '1255237200', '1255323600' ],
             },
};

my $frmA = $ems->addSubmissionForm({
    title                    => 'test A -- long',
    canSubmitGroupId         => $submitGroupA->getId,
    daysBeforeCleanup        => 1,
    formDescription          => to_json( $formAdesc ),
});
isa_ok( $frmA, 'WebGUI::Asset::EMSSubmissionForm' );
is( $ems->hasForms, 1, 'ems now has forms' );
is_deeply( $frmA->getFormDescription, $formAdesc, 'form description matches' );
my $submission = {
   title => 'titlea',
   description => 'the description',
   startDate => '1255150800',
        };
my $result = $frmA->validateSubmission($submission);
ok( $result->{isValid}, 'a valid submission' );
print join( "\n", @{$result->{errors}} ),"\n" if defined $result->{errors};
$submission = {
   title => 'titlea',
   description => 'the description',
   startDate => '1205150800',
        };
$result = $frmA->validateSubmission($submission);
ok( !$result->{isValid}, 'not a valid submission: invalid value in startDate' );
print join( "\n", @{$result->{errors}} ),"\n" if defined $result->{errors};
$submission = {
   title => 'titlea',
   duration => 3.0,
   description => 'the description',
   startDate => '1255150800',
        };
$result = $frmA->validateSubmission($submission);
ok( $result->{isValid} && ! defined $result->{duration}, 'valid submission: readonly field ignored' );
print join( "\n", @{$result->{errors}} ),"\n" if defined $result->{errors};


my $formBdesc = {
    title => { type => 'text' },
    description => { type => 'textarea' },
    duration => { type => 'float', default => 0.5, max => 0.5 },
    startDate => { default => '1255150800' },
    mfRequiredUrl => { type => 'url' },
};
my $frmB = $ems->addSubmissionForm({
    className                => 'WebGUI::Asset::EMSSubmissionForm',
    title                    => 'test B -- short',
    daysBeforeCleanup        => 0,
    canSubmitGroupId         => $submitGroupB->getId,
    formDescription          => to_json($formBdesc),
});
$submission = {
   title => 'title',
   description => 'description',
   mfRequiredUrl => 'http://google.com/',
};
$result = $frmB->validateSubmission($submission);
ok( $result->{isValid},  'valid submission: test valid metafield value' );
print join( "\n", @{$result->{errors}} ),"\n" if defined $result->{errors};
$submission = {
   title => 'title',
   description => 'description',
   mfRequiredUrl => 'joe@sams.org',
};
$result = $frmB->validateSubmission($submission);
ok( !$result->{isValid}, 'invalid submission: test invalid metafield value' );
print join( "\n", @{$result->{errors}} ),"\n" if defined $result->{errors};
$submission = {
   title => 'titlea',
   duration => 0.6,
   description => 'the description',
   mfRequiredUrl => 'http://google.com/',
   adminOverride => to_json( { duration => { value => 0.6, type => 'float' } } ),
        };
$result = $frmB->validateSubmission($submission);
ok( $result->{isValid}, 'valid submission: field value override by admin' );
print join( "\n", @{$result->{errors}} ),"\n" if defined $result->{errors};
logout;

ok( !$ems->canSubmit, 'Visitor cannot submit to this ems' );
ok( !$frmA->canSubmit, 'Visitor cannot submit to form' );

loginUserA;

ok( $ems->canSubmit, 'UserA can submit to this ems' );
ok( $frmA->canSubmit, 'UserA can submit to formA' );
ok( !$frmB->canSubmit, 'UserA cannot submit to formB' );
#print 'press return to complete test' ; <>;
ok( !$ems->hasSubmissions, 'UserA has no submissions' );
# this one should work
my $sub1 = $frmA->addSubmission({
    title => 'my favorite thing to talk about',
    description => 'the description',
    startDate => '1255150800',
});
push @cleanup, sub  { $sub1->delete; };
print join( "\n", @{$sub1->{errors}} ),"\n" if defined $sub1->{errors};
isa_ok( $sub1, 'WebGUI::Asset::EMSSubmission', "userA/formA valid submission succeeded" );
is( $ems->hasSubmissions, 1, 'UserA has submissions on this ems' );

#this one should fail
my $sub2 = $frmB->addSubmission({
    title => 'why i like to be important',
});
print join( "\n", @{$sub2->{errors}} ),"\n" if defined $sub2->{errors};
ok( ref $sub2 eq 'HASH' && !$sub2->{isValid}, "UserA cannot submit to formB" );

loginUserB;

ok( $ems->canSubmit, 'UserB can submit to this ems' );
ok( !$frmA->canSubmit, 'UserB cannot submit to formA' );
ok( $frmB->canSubmit, 'UserB can submit to formB' );

$sub2 = $frmB->addSubmission({
    title => 'why i like to be important',
    description => 'the description',
    mfRequiredUrl => 'http://google.com',
});
push @cleanup, sub  { $sub2->delete; };
print join( "\n", @{$sub2->{errors}} ),"\n" if defined $sub2->{errors};
isa_ok( $sub2, 'WebGUI::Asset::EMSSubmission', "userB/FormB valid submission succeeded" );

loginUserC;

ok( $ems->canSubmit, 'UserC can submit to this ems' );
ok( $frmA->canSubmit, 'UserC can submit to formA' );
ok( $frmB->canSubmit, 'UserC can submit to formB' );

SKIP: { skip 'create submission failed', 8 unless ref $sub1 eq 'WebGUI::Asset::EMSSubmission' and ref $sub1 eq ref $sub2;

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

# TODO either remove this or make it a real test.
#loginAdmin;
#print $ems->www_addSubmissionForm;

} # end of use packages skip

#done_testing();
#print 'press return to complete test' ; <>;
#----------------------------------------------------------------------------
# Cleanup
END {
   map { eval { $_->() } } ( @cleanup );
}
#vim:ft=perl
