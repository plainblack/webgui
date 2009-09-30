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

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $TODO = q{
create a version tag
};


#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

$submitGroupA = WebGUI::Group->new($session,'new');
$submitGroupB = WebGUI::Group->new($session,'new');

$userA = WebGUI::User->create($session);
$userB = WebGUI::User->create($session);
$userC = WebGUI::User->create($session);

$submitGroupA->addUsers([$userA->userId,$userC->userId]);
$submitGroupB->addUsers([$userB->userId,$userC->userId]);

WebGUI::Test->groupsToDelete($submitGroupA,$submitGroupB);
WebGUI::Test->usersToDelete($userA,$userB,$userC);

sub loginAdmin { $session->user({userId => 3}); }
sub logout     { $session->user({userId => 1}); }
sub loginUserA { $session->user({userId => $userA->userId}); }
sub loginUserB { $session->user({userId => $userB->userId}); }
sub loginUserC { $session->user({userId => $userC->userId}); }

#----------------------------------------------------------------------------
# put your tests here

use_ok WebGUI::Asset::Wobject::EventManagementSystem;
use_ok WebGUI::Asset::EMSSubmissionForm;
use_ok WebGUI::Asset::EMSSubmission;

loginAdmin;

my $TODO = q{
create EMS
create submission form(s)
create submission(s)
comment on submission(s)
modify submission(s)
change submission status
run submission approval activity
run submission cleanup activity
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
