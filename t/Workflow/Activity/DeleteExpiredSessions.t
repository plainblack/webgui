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
use lib "$FindBin::Bin/../../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Workflow::Activity::DeleteExpiredSessions;

use Test::More;

plan tests => 7; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $workflow  = WebGUI::Workflow->create($session,
    {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    },
);
my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::DeleteExpiredSessions');

my $instance1 = WebGUI::Workflow::Instance->create($session,
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

my $origSessionTimeout = $session->setting->get('sessionTimeout');

my $sessionCount = $session->db->quickScalar('select count(*) from userSession');
my $scratchCount = $session->db->quickScalar('select count(*) from userSessionScratch');

note $sessionCount;
note $scratchCount;

my @sessions;

foreach (1..2) {
    push @sessions, WebGUI::Session->open(WebGUI::Test->file);
}

##Force automatic expiration of the sessions
$session->setting->set('sessionTimeout', -500);

foreach (1..2) {
    push @sessions, WebGUI::Session->open(WebGUI::Test->file);
}

$session->setting->set('sessionTimeout', $origSessionTimeout );

my $newSessionCount = $session->db->quickScalar('select count(*) from userSession');
my $newScratchCount = $session->db->quickScalar('select count(*) from userSessionScratch');

is ($newSessionCount, $sessionCount+4, 'all new sessions created correctly');
is ($newScratchCount, $scratchCount+4, 'all new user sessions created correctly');

my $instance2 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

my $counter = 0;
PAUSE: while ($retVal = $instance2->run()) {
    last PAUSE if $retVal eq 'done';
    last PAUSE if $counter > 6;  #Emergency exit clause
}

is($retVal, 'done', 'Workflow completed successfully');

$newSessionCount = $session->db->quickScalar('select count(*) from userSession');
$newScratchCount = $session->db->quickScalar('select count(*) from userSessionScratch');

is ($newSessionCount, $sessionCount+2, 'two of the sessions were deleted');
is ($newScratchCount, $scratchCount+2, 'scratch from both sessions cleaned up');

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

END {
    $workflow->delete;
}
