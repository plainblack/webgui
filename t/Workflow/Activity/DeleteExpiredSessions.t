#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Workflow::Activity::DeleteExpiredSessions;

use Test::More;

plan tests => 5; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $activity = WebGUI::Workflow::Activity::DeleteExpiredSessions->create($session);
$activity->execute();  ##Clear out any old sessions that might interfere with this test;

my $origSessionTimeout = $session->setting->get('sessionTimeout');

my $sessionCount = $session->db->quickScalar('select count(*) from userSession');
my $scratchCount = $session->db->quickScalar('select count(*) from userSessionScratch');

my @sessions;

foreach (1..2) {
    push @sessions, WebGUI::Session->open(WebGUI::Test->root, WebGUI::Test->file);
}

##Force automatic expiration of the sessions
$session->setting->set('sessionTimeout', -500);

foreach (1..2) {
    push @sessions, WebGUI::Session->open(WebGUI::Test->root, WebGUI::Test->file);
}

$session->setting->set('sessionTimeout', $origSessionTimeout );

$sessions[1]->scratch->set('scratch1', 1);
$sessions[3]->scratch->set('scratch3', 3);

my $newSessionCount = $session->db->quickScalar('select count(*) from userSession');
my $newScratchCount = $session->db->quickScalar('select count(*) from userSessionScratch');

is ($newSessionCount, $sessionCount+4, 'all new sessions created correctly');
is ($newScratchCount, $scratchCount+2, 'two of the new sessions have scratch entries');

my $returnValue = $activity->execute();
is ($returnValue, 'complete', 'DeleteExpiredSessions completed');

$newSessionCount = $session->db->quickScalar('select count(*) from userSession');
$newScratchCount = $session->db->quickScalar('select count(*) from userSessionScratch');

is ($newSessionCount, $sessionCount+2, 'two of the sessions were deleted');
is ($newScratchCount, $scratchCount+1, 'one of the new sessions have scratch entries were deleted');

foreach my $testSession (@sessions) {
    $testSession->var->end;
    $testSession->close;
}

##Add 4 sessions:
##  1) Active session
##  2) Active session with scratch
##  3) Expired session
##  4) Expired session with scratch
##
## run deleteExpiredSessions 
## Make sure that the two session were kept and the other two deleted.
## Make sure that one scratch session was deleted and the other kept.
## Close and end all four sessions

END: {
    $session->setting->set('sessionTimeout', $origSessionTimeout );
}
