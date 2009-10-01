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
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Group;
use WebGUI::User;
use WebGUI::Test; # Must use this before any other WebGUI modules
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

plan tests => 1;        # Increment this number for each test you create

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

use_ok WebGUI::Asset::EMSSubmissionForm;
use_ok WebGUI::Asset::EMSSubmission;

loginAdmin;

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"EventManagementSystem Test"});

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
$versionTag->commit;
WebGUI::Test->tagsToRollback($versionTag);

$versionTag = WebGUI::VersionTag->getWorking($session);

loginRgstr;

my $frmA = $ems->addChild({
    className                => 'WebGUI::Asset::EMSSubmissionForm',
    canSubmitGroup           => $submitGroupA->getId,
    formDescription          => q{
   TODO = 1
                     },
});
isa( $frmA, 'WebGUI::Asset::EMSSubmissionForm' );

my $frmB = $ems->addChild({
    className                => 'WebGUI::Asset::EMSSubmissionForm',
    canSubmitGroup           => $submitGroupB->getId,
    formDescription          => q{
   TODO = 1
                     },
});

my $TODO = q{
create submission(s)
comment on submission(s)
modify submission(s)
change submission status
run submission approval activity
run submission cleanup activity
}
$versionTag->commit;
WebGUI::Test->tagsToRollback($versionTag);

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
