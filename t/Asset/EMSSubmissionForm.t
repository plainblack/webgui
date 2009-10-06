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
use WebGUI::Group;
use WebGUI::User;
use WebGUI::Test; # Must use this before any other WebGUI modules
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

#----------------------------------------------------------------------------
# Tests

plan tests => 30;        # Increment this number for each test you create

my $submitGroupA = WebGUI::Group->new($session,'new');
my $submitGroupB = WebGUI::Group->new($session,'new');
my $registrars = WebGUI::Group->new($session, 'new');
my $attendees  = WebGUI::Group->new($session, 'new');

my $registrar = WebGUI::User->create($session);
my $userA = WebGUI::User->create($session);
my $userB = WebGUI::User->create($session);
my $userC = WebGUI::User->create($session);

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

use_ok 'WebGUI::Asset::EMSSubmissionForm';
use_ok 'WebGUI::Asset::EMSSubmission';

loginAdmin;

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"EventManagementSystem Test"});
WebGUI::Test->tagsToRollback($versionTag);

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

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
                label => 'metaField1',
                dataType => 'Url',
                visible => 1,
                required => 1,
                possibleValues => '',
                defaultValues => '',
        },1,1);

        $ems->setCollateral("EMSEventMetaField", "fieldId",{
                fieldId=> 'new',
                label => 'metaField2',
                dataType => 'Date',
                visible => 1,
                required => 0,
                possibleValues => '',
                defaultValues => '',
        },1,1);

$versionTag->commit;

$versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($versionTag);

loginRgstr;

is( $ems->hasForms, 0, 'ems currently has no forms' );

my $frmA = $ems->addChild({
    className                => 'WebGUI::Asset::EMSSubmissionForm',
    title                    => 'test A -- long',
    canSubmitGroup           => $submitGroupA->getId,
    daysBeforeCleanup        => 1,
    formDescription          => q{ {
	   'title' : { 'type' : 'text' },
	   'description' : { 'type' : 'textarea' },
	   'duration' : { 'default' : 2.0 },
	   'startDate' : { 'type' : 'selectList', 'options' :
                     [ '1255150800', '1255237200', '1255323600' ] },
                     } },
});
isa_ok( $frmA, 'WebGUI::Asset::EMSSubmissionForm' );
is( $ems->hasForms, 1, 'ems now has forms' );
ok( $frmA->validateSubmission({
   title => 'titlea',
   description => 'the description',
   startDate => '1255150800',
	}), 'a valid submission' );
ok( !$frmA->validateSubmission({
   title => 'titlea',
   description => 'the description',
   startDate => '1205150800',
	}), 'not a valid submission: invalid value' );
ok( !$frmA->validateSubmission({
   title => 'titlea',
   price => 300.0,
   description => 'the description',
   startDate => '1255150800',
	}), 'not a valid submission: invalid field' );
ok( !$frmA->validateSubmission({
   title => 'titlea',
   duration => 3.0,
   description => 'the description',
   startDate => '1255150800',
	}), 'not a valid submission: readonly field' );
ok( $frmA->validateSubmission({
   title => 'titlea',
   duration => 3.0,
   description => 'the description',
   startDate => '1255150800',
   adminOverride => q{ { 'duration' : 3.0 } },
	}), 'valid submission: field value override by admin' );


my $frmB = $ems->addChild({
    className                => 'WebGUI::Asset::EMSSubmissionForm',
    title                    => 'test B -- short',
    daysBeforeCleanup        => 0,
    canSubmitGroup           => $submitGroupB->getId,
    formDescription          => q{ {
	   'title' : { 'type' : 'text' },
	   'description' : { 'type' : 'textarea' },
	   'duration' : { 'default' : 0.5 },
	   'startDate' : { 'default' : '1255150800' },
	   'metaField1' : { 'type' : 'Url' },
                     } },
});
is( $ems->hasForms, 1, 'ems still has forms' );
ok( $frmA->validateSubmission({
   title => 'title',
   description => 'description',
   metaField1 => 'http://google.com/',
	}), 'valid submission: test valid metafield value' );
ok( !$frmA->validateSubmission({
   title => 'title',
   description => 'description',
   metaField1 => 'joe@sams.org',
	}), 'invalid submission: test invalid metafield value' );

logout;

is( $ems->canSubmit, 0, 'current user cannot submit to this ems' );

loginUserA;

is( $ems->canSubmit, 1, 'current user can submit to this ems' );
is( $ems->hasSubmissions, 0, 'current user has no submissions' );
# this one should work
my $sub1 = $frmA->addSubmission({
    title => 'my favorite thing to talk about',
});
isa_ok( $sub1, 'WebGUI::Asset::EMSSubmission', "valid submission succeeded" );
is( $ems->hasSubmissions, 1, 'current user has submissions on this ems' );

#this one should fail
my $sub2 = $frmB->addSubmission({
    title => 'why i like to be important',
});
ok( not defined $sub2, "user cannot submit to this form" );

loginUserB;

# should work
my $sub3 = $frmB->addSubmission({
    title => 'five minutes of me',
});
isa_ok( $sub3, 'WebGUI::Asset::EMSSubmission', "checked permissions for group B" );

loginUserC;

# should work
my $sub4 = $frmB->addSubmission({
    title => 'why humility is underrated',
});
isa_ok( $sub4, 'WebGUI::Asset::EMSSubmission', "user C is in group B" );

# should work
my $sub5 = $frmA->addSubmission({
    title => 'what you should know about everybody',
});
isa_ok( $sub5, 'WebGUI::Asset::EMSSubmission', "user C is also in group A" );

$sub1->addComment( 'this is a test comment' );
cmp_deeply($sub1->get('comments')->[0],{
      id => re( qr/.+/ ),
      alias => '',
      userId => $userC->userId,
      comment => 'this is a test comment',
      rating => 0,
      date => re( qr/\d{10}/ ),
      ip => undef,
}, "successfully added comment" );

ok($sub1->update({
    title => 'the new title'
}),'update submission');

is( $sub1->get('title'),'the new title','successfully changed the title');


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

is($approveSubmissions->run, 'complete', 'approval complete');
is($approveSubmissions->run, 'done', 'approval done');

is( $sub1->get('status'),'created','submission has been created');

my $TODO = q{
can we look for the EMSTicket asset for the created submission?
	-- perhaps it should be assigned to the ticket somehow?
run addpoval on a submission that is missing data
    -- approval runs fine, but status should be failed
update submissions to be more than a day old
run submission cleanup activity
    --  cleanup only denied entries
    --  cleanup denied and created entries
};

$versionTag->commit;

#done_testing();

#----------------------------------------------------------------------------
# Cleanup
END {
   $approveSubmissions->delete;
   $cleanupSubmissions->delete;
}
#vim:ft=perl
