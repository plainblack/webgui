# Test WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$FindBin::Bin/../../lib";
use WebGUI::Test;
use Test::More;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 15;

use_ok('WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses');

my $wf = WebGUI::Workflow->create($session, {
    title => 'Test ExpireIncompleteSurveyResponses',
    enabled => 1,
    type => 'None',
    mode => 'realtime',
});
isa_ok($wf, 'WebGUI::Workflow', 'Test workflow');
WebGUI::Test->workflowsToDelete($wf);

my $activity = $wf->addActivity('WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses');
isa_ok($activity, 'WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses', 'Test wf activity');
$activity->set('title', 'Test Expire Incomplete Survey Responses');

my $user = WebGUI::User->new($session, 'new');
WebGUI::Test->usersToDelete($user);

# Create a Survey
my $survey = WebGUI::Asset->getImportNode($session)->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
WebGUI::Test->tagsToRollback(WebGUI::VersionTag->getWorking($session));
WebGUI::Test->assetsToPurge($survey);
my $sJSON = $survey->surveyJSON;
$sJSON->newObject([0]);    # add a question to 0th section
$sJSON->update([0,0], { questionType => 'Yes/No' });
$survey->persistSurveyJSON;

# Now start a response as the test user
$session->user( { user => $user } );
my $responseId = $survey->responseId;
ok($responseId, 'Started a survey response');
my ($endDate, $isComplete) = $session->db->quickArray('select endDate, isComplete from Survey_response where Survey_responseId = ?', [$responseId]);
is($endDate, 0, '..currently with no endDate');
is($isComplete, 0, '..and marked as in-progress');

WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $wf->getId,
        skipSpectreNotification => 1,
        priority                => 1,
    }
)->start;
($endDate, $isComplete) = $session->db->quickArray('select endDate, isComplete from Survey_response where Survey_responseId = ?', [$responseId]);
is($endDate + $isComplete, 0, '..no change after workflow runs the first time');

# Change survey time limit
ok(!$survey->hasTimedOut, 'Survey has not timed out (yet)');
$survey->update( { timeLimit => 1 } );
$survey->startDate($survey->startDate - 100);
ok($survey->hasTimedOut, '..until we set a timeLimit and push startDate into the past');

WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $wf->getId,
        skipSpectreNotification => 1,
        priority                => 1,
    }
)->start;
($endDate, $isComplete) = $session->db->quickArray('select endDate, isComplete from Survey_response where Survey_responseId = ?', [$responseId]);
ok($endDate, 'endDate now set');
is($isComplete, 3, '..and isComplete set to timeout code');

# Undo out handiwork, and chage doAfterTimeLimit to restartSurvey so that we get a different completeCode
$session->db->write('update Survey_response set endDate = 0, isComplete = 0 where Survey_responseId = ?', [$responseId]);
$survey->update( { doAfterTimeLimit => 'restartSurvey' } );
WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $wf->getId,
        skipSpectreNotification => 1,
        priority                => 1,
    }
)->start;
($endDate, $isComplete) = $session->db->quickArray('select endDate, isComplete from Survey_response where Survey_responseId = ?', [$responseId]);
ok($endDate, 'endDate set again');
is($isComplete, 4, '..and isComplete now set to timeoutRestart code');

# Undo out handiwork again, and chage workflow to delete
is($session->db->quickScalar('select count(*) from Survey_response where Survey_responseId = ?', [$responseId]), 1, 'Start off with 1 response');
$session->db->write('update Survey_response set endDate = 0, isComplete = 0 where Survey_responseId = ?', [$responseId]);
$activity->set('deleteExpired', 1);
WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $wf->getId,
        skipSpectreNotification => 1,
        priority                => 1,
    }
)->start;
is($session->db->quickScalar('select count(*) from Survey_response where Survey_responseId = ?', [$responseId]), 0, 'Response has now been deleted');

END {
    $session->db->write('delete from Survey_response where userId = ?', [$user->userId]) if $user;
}
