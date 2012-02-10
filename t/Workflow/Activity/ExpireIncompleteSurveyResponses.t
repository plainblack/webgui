# Test WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses

use strict;
use warnings;
use WebGUI::Test;
use Test::More;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 26;

use_ok('WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses');

my $SQL = WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses->getSql;

my $wf = WebGUI::Workflow->create($session, {
    title => 'Test ExpireIncompleteSurveyResponses',
    enabled => 1,
    type => 'None',
    mode => 'realtime',
});
isa_ok($wf, 'WebGUI::Workflow', 'Test workflow');
WebGUI::Test->addToCleanup($wf);

my $activity = $wf->addActivity('WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses');
isa_ok($activity, 'WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses', 'Test wf activity');
$activity->set('title', 'Test Expire Incomplete Survey Responses');

my $user = WebGUI::User->new($session, 'new');
WebGUI::Test->addToCleanup($user);

# Create a Survey
my $survey = WebGUI::Asset->getImportNode($session)->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
WebGUI::Test->addToCleanup(WebGUI::VersionTag->getWorking($session));
WebGUI::Test->addToCleanup($survey);
my $sJSON = $survey->getSurveyJSON;
$sJSON->newObject([0]);    # add a question to 0th section
$sJSON->update([0,0], { questionType => 'Yes/No' });
$survey->persistSurveyJSON;

# Initially, sql returns no resuts
is( scalar $session->db->buildArray($SQL), 0, 'No incomplete responses');

# Now start a response as the test user
$session->user( { user => $user } );
my $responseId = $survey->responseId;
ok($responseId, 'Started a survey response');
my ($endDate, $isComplete) = $session->db->quickArray('select endDate, isComplete from Survey_response where Survey_responseId = ?', [$responseId]);
is($endDate, 0, '..currently with no endDate');
is($isComplete, 0, '..and marked as in-progress');

# Still no resuts
is( scalar $session->db->buildArray($SQL), 0, 'Still no incomplete responses');

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

# Now we have 1 incomplete response
is( scalar $session->db->buildArray($SQL), 1, 'Now we have 1 incomplete response');

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

# Afterwards, back to no incomplete responses
is( scalar $session->db->buildArray($SQL), 0, 'Afterwards, back to no incomplete responses');

# Undo out handiwork, and chage doAfterTimeLimit to restartSurvey so that we get a different completeCode
$session->db->write('update Survey_response set endDate = 0, isComplete = 0 where Survey_responseId = ?', [$responseId]);
$survey->update( { doAfterTimeLimit => 'restartSurvey' } );

# Now we have 1 incomplete response again
is( scalar $session->db->buildArray($SQL), 1, 'Now we have 1 incomplete response again');

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

# Afterwards, back to no incomplete responses
is( scalar $session->db->buildArray($SQL), 0, 'Afterwards, back to no incomplete responses');

##
# Explicitly test for bug that existed in SQL whereby one email per revision would be sent
##

# Create a new revision
$survey->addRevision({}, time+1);
WebGUI::Test->addToCleanup(WebGUI::VersionTag->getWorking($session));

# Undo out handiwork again
is($session->db->quickScalar('select count(*) from Survey_response where Survey_responseId = ?', [$responseId]), 1, 'Start off with 1 response');
$session->db->write('update Survey_response set endDate = 0, isComplete = 0 where Survey_responseId = ?', [$responseId]);

# Make sure SQL only returns 1 incomplete response
is( scalar $session->db->buildArray($SQL), 1, 'Make sure SQL only returns 1 incomplete response');

##
# Make sure workflow handles responses for deleted users
#
$session->db->write('update Survey_response set userId = ? where Survey_responseId = ?', ['not-a-user-id', $responseId]);
is( scalar $session->db->buildArray($SQL), 1, 'Still returns 1 row, even though user does not exist (sql left outer join)');
$session->db->write('update Survey_response set userId = ? where Survey_responseId = ?', [$user->getId, $responseId]);

##
# Delete Expired
##

# Undo out handiwork again, and chage workflow to delete
is($session->db->quickScalar('select count(*) from Survey_response where Survey_responseId = ?', [$responseId]), 1, 'Start off with 1 response');
$session->db->write('update Survey_response set endDate = 0, isComplete = 0 where Survey_responseId = ?', [$responseId]);
$activity->set('deleteExpired', 1);

# Now we have 1 incomplete response again
is( scalar $session->db->buildArray($SQL), 1, 'Now we have 1 incomplete response again');

WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $wf->getId,
        skipSpectreNotification => 1,
        priority                => 1,
    }
)->start;
is($session->db->quickScalar('select count(*) from Survey_response where Survey_responseId = ?', [$responseId]), 0, 'Response has now been deleted');

# Afterwards, back to no incomplete responses
is( scalar $session->db->buildArray($SQL), 0, 'Afterwards, back to no incomplete responses');

#vim:ft=perl
