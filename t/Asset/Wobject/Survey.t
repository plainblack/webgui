# Tests WebGUI::Asset::Wobject::Survey
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 47;

#----------------------------------------------------------------------------
# put your tests here

my ($survey);

my $user = WebGUI::User->new( $session, 'new' );
WebGUI::Test->usersToDelete($user);
my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
$survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
my $tag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->assetsToPurge($survey);
isa_ok($survey, 'WebGUI::Asset::Wobject::Survey');

my $sJSON = $survey->surveyJSON;

# Load bare-bones survey, containing a single section (S0)
$sJSON->update([0], { variable => 'S0' });

# Add 2 questions to S0
$sJSON->newObject([0]);    # S0Q0
$sJSON->update([0,0], { variable => 'S0Q0', questionType => 'Yes/No' });
$sJSON->newObject([0]);    # S0Q1
$sJSON->update([0,1], { variable => 'S0Q1', questionType => 'Yes/No' });

# Add a new section (S1)
$sJSON->newObject([]);     # S1
$sJSON->update([1], { variable => 'S1' });

# Add 2 questions to S1
$sJSON->newObject([1]);    # S1Q0
$sJSON->update([1,0], { variable => 'S1Q0' });
$sJSON->newObject([1]);    # S1Q1
$sJSON->update([1,1], { variable => 'S1Q1' });

$survey->persistSurveyJSON;

# Now start a response as the test user
$session->user( { user => $user } );

my $responseId = $survey->responseId;
{
    my $s = WebGUI::Asset::Wobject::Survey->newByResponseId($session, $responseId);
    is($s->getId, $survey->getId, 'newByResponseId returns same Survey');
}
is($survey->get('maxResponsesPerUser'), 1, 'maxResponsesPerUser defaults to 1');
ok($survey->canTakeSurvey, '..which means user can take survey');
is($survey->get('revisionDate'), $session->db->quickScalar('select revisionDate from Survey_response where Survey_responseId = ?', [$responseId]), 'Current revisionDate used');

####################################################
#
# startDate
#
####################################################

my $startDate = $survey->startDate;
$survey->startDate($startDate + 10);
is($survey->startDate, $startDate + 10, 'startDate get/set');

####################################################
#
# hasTimedOut
#
####################################################

ok(!$survey->hasTimedOut, 'Survey has not timed out');
$survey->update( { timeLimit => 1 });
$survey->startDate($startDate - 100);
ok($survey->hasTimedOut, '..until we set timeLimit and change startDate');

# Complete Survey
$survey->surveyEnd();

# Uncache canTake
delete $survey->{canTake};
delete $survey->{responseId};
ok(!$survey->canTakeSurvey, 'Cannot take survey a second time (maxResponsesPerUser=1)');
cmp_deeply($survey->responseId, undef, '..and similarly cannot get responseId');

# Change maxResponsesPerUser to 2
$survey->update({maxResponsesPerUser => 2});
delete $survey->{canTake};
ok($survey->canTakeSurvey, '..but can take when maxResponsesPerUser increased to 2');
ok($survey->responseId, '..and similarly can get responseId');

# Change maxResponsesPerUser to 0
$survey->update({maxResponsesPerUser => 0});
delete $survey->{canTake};
delete $survey->{responseId};
ok($survey->canTakeSurvey, '..and also when maxResponsesPerUser set to 0 (unlimited)');
ok($survey->responseId, '..(and similarly for responseId)');

# Start a new response as another user
$survey->update({maxResponsesPerUser => 1});
is($survey->takenCount( { userId => 1 } ), 0, 'Visitor has no responses');
my $u = WebGUI::User->new( $session, 'new' );
WebGUI::Test->usersToDelete($u);
is($survey->takenCount( { userId => $u->userId } ), 0, 'New user has no responses');
delete $survey->{canTake};
delete $survey->{responseId};
$session->user( { userId => $u->userId } );
ok($survey->canTakeSurvey, 'Separate counts for separate users');
ok($survey->responseId, '..(and similarly for responseId)');
# Put things back to normal..
delete $survey->{canTake};
delete $survey->{responseId};
$session->user( { user => $user } );

# Restart the survey
$survey->update({maxResponsesPerUser => 0});
$survey->submitQuestions({
    '0-0-0'        => 'this text ignored',
    '0-1-0'        => 'this text ignored',
});

cmp_deeply(
    $survey->responseJSON->responses,
    superhashof(
        {   '0-1-0' => {
                'time'     => num( time, 5 ),
                'value'    => 1
            },
            '0-0-0' => {
                'time'     => num( time, 5 ),
                'value'    => 1
            },
        }
    ),
    'submitQuestions does the right thing'
);

# Test Restart
$survey->surveyEnd( { restart => 1 } );
cmp_deeply($survey->responseJSON->responses, {}, 'restart removes the in-progress response');
ok($responseId ne $survey->responseId, '..and uses a new responseId');

# Test out exitUrl with an explicit url
use JSON;
my $surveyEnd = $survey->surveyEnd( { exitUrl => 'home' } );
cmp_deeply(from_json($surveyEnd), { type => 'forward', url => '/home' }, 'exitUrl works (it adds a slash for us)');

# Test out exitUrl using survey instance exitURL property
$survey->update({ exitURL => 'getting_started'});
$surveyEnd = $survey->surveyEnd( { exitUrl => undef } );
cmp_deeply(from_json($surveyEnd), { type => 'forward', url => '/getting_started' }, 'exitUrl works (it adds a slash for us)');

# www_jumpTo
{
    # Check a simple www_jumpTo request
    $session->user( { userId => 3 } );
    WebGUI::Test->getPage( $survey, 'www_jumpTo', { formParams => {id => '0'} } );
    is( $session->http->getStatus, '201', 'Page request ok' ); # why is "201 - created" status used??
    is($survey->responseJSON->nextResponse, 0, 'S0 is the first response');

    tie my %expectedSurveyOrder, 'Tie::IxHash';
    %expectedSurveyOrder =  (
        'undefined' => 0,
        '0' => 0,
        '0-0' => 0,
        '0-1' => 1,
        '1' => 2,
        '1-0' => 2,
        '1-1' => 3,
    );
    while (my ($id, $index) = each %expectedSurveyOrder) {
        WebGUI::Test->getPage( $survey, 'www_jumpTo', { formParams => {id => $id} } );
        is($survey->responseJSON->nextResponse, $index, "jumpTo($id) sets nextResponse to $index");
    }
}

# Response Revisioning
{
    # Delete existing responses
    $session->db->write('delete from Survey_response where assetId = ?', [$survey->getId]);
    delete $survey->{responseId};
    delete $survey->{surveyJSON};

    my $surveyId = $survey->getId;
    my $revisionDate = WebGUI::Asset->getCurrentRevisionDate($session, $surveyId);
    ok($revisionDate, 'Revision Date initially defined');

    # Modify Survey structure, new revision not created
    $survey->submitObjectEdit({ id =>  "0", text => "new text"});
    is($survey->surveyJSON->section([0])->{text}, 'new text', 'Survey updated');
    is($session->db->quickScalar('select revisionDate from Survey where assetId = ?', [$surveyId]), $revisionDate, 'Revision unchanged');

    # Push revisionDate into the past because we can't have 2 revision dates with the same epoch (this is very hacky)
    $revisionDate--;
    $session->stow->deleteAll();
    WebGUI::Cache->new($session)->flush;
    $session->db->write('update Survey set revisionDate = ? where assetId = ?', [$revisionDate, $surveyId]);
    $session->db->write('update assetData set revisionDate = ? where assetId = ?', [$revisionDate, $surveyId]);
    $session->db->write('update wobject set revisionDate = ? where assetId = ?', [$revisionDate, $surveyId]);

    $survey = WebGUI::Asset->new($session, $surveyId);
    isa_ok($survey, 'WebGUI::Asset::Wobject::Survey', 'Got back survey after monkeying with revisionDate');
    is($session->db->quickScalar('select revisionDate from Survey where assetId = ?', [$surveyId]), $revisionDate, 'Revision date pushed back');

    # Create new response
    my $responseId = $survey->responseId;
    is(
        $session->db->quickScalar('select revisionDate from Survey_response where Survey_responseId = ?', [$responseId]), 
        $revisionDate, 
        'Pushed back revisionDate used for new response'
    );

    # Make another change, causing new revision to be automatically created
    $survey->submitObjectEdit({ id =>  "0", text => "newer text"});

    my $newerSurvey = WebGUI::Asset->new($session, $surveyId); # retrieve newer revision
    isa_ok($newerSurvey, 'WebGUI::Asset::Wobject::Survey', 'After change, re-retrieved Survey instance');
    is($newerSurvey->getId, $surveyId, '..which is the same survey');
    is($newerSurvey->surveyJSON->section([0])->{text}, 'newer text', '..with updated text');
    ok($newerSurvey->get('revisionDate') > $revisionDate, '..and newer revisionDate');

    # Create another response (this one will use the new revision)
    my $newUser = WebGUI::User->new( $session, 'new' );
    WebGUI::Test->usersToDelete($newUser);
    $session->user({ user => $newUser });
    my $newResponseId = $survey->responseId;
    is($newerSurvey->responseJSON->nextResponseSection()->{text}, 'newer text', 'New response uses the new text');

    # And the punch line..
    is($survey->responseJSON->nextResponseSection()->{text}, 'new text', '..wheras the original response uses the original text');

}

# Test visualization
eval 'use GraphViz';

SKIP: {

skip "Unable to load GraphViz", 1 if $@;

$survey->surveyJSON->remove([1]);
my ($storage, $filename) = $survey->graph( { format => 'plain', layout => 'dot' } );
like($storage->getFileContentsAsScalar($filename), qr{
    ^graph .*       # starts with graph
    (node .*){3}    # ..then 3 nodes
    (edge .*){3}    # ..then 3 edges
    stop$            # ..and end with stop
}xs, 'Generated graph looks roughly okay');

}

$survey->getAdminConsole();
my $adminConsole = $survey->getAdminConsole();
cmp_deeply(
    $adminConsole->{_submenuItem},
    [
        {
          'extras' => undef,
          'url' => re('func=edit$'),
          'label' => 'Edit'
        },
        {
          'extras' => undef,
          'url' => re('func=editSurvey$'),
          'label' => 'Edit Survey'
        },
        {
          'extras' => undef,
          'url' => re('func=takeSurvey$'),
          'label' => 'Take Survey'
        },
        {
          'extras' => undef,
          'url' => re('func=graph$'),
          'label' => 'Visualize'
        },
        {
          'extras' => undef,
          'url' => re('func=editTestSuite$'),
          'label' => 'Test Suite'
        },
        {
          'extras' => undef,
          'url' => re('func=runTests$'),
          'label' => 'Run All Tests'
        },
        {
          'extras' => undef,
          'url' => re('func=runTests;format=tap$'),
          'label' => 'Run All Tests (TAP)'
        }
    ],
    "Admin console submenu",
);

####################################################
#
# www_loadSurvey
#
####################################################

my $survey_json = $survey->www_loadSurvey({});
my $survey_data = JSON::from_json($survey_json);
unlike($survey_data->{edithtml}, qr/\^International/, 'www_loadSurvey process macros');
