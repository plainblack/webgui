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
my $tests = 25;
plan tests => $tests + 1;

#----------------------------------------------------------------------------
# put your tests here

my $usedOk = use_ok('WebGUI::Asset::Wobject::Survey');
my ($user, $import_node, $survey);

SKIP: {

skip $tests, "Unable to load Survey" unless $usedOk;
$user = WebGUI::User->new( $session, 'new' );
WebGUI::Test->usersToDelete($user);
$import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
$survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
isa_ok($survey, 'WebGUI::Asset::Wobject::Survey');

# Load bare-bones survey, containing a single section (S0)
$survey->surveyJSON_update([0], { variable => 'S0' });

# Add 2 questions to S0
$survey->surveyJSON_newObject([0]);    # S0Q0
$survey->surveyJSON_update([0,0], { variable => 'S0Q0' });
$survey->surveyJSON_newObject([0]);    # S0Q1
$survey->surveyJSON_update([0,1], { variable => 'S0Q1' });

# Add a new section (S1)
$survey->surveyJSON_newObject([]);     # S1
$survey->surveyJSON_update([1], { variable => 'S1' });

# Add 2 questions to S1
$survey->surveyJSON_newObject([1]);    # S1Q0
$survey->surveyJSON_update([1,0], { variable => 'S1Q0' });
$survey->surveyJSON_newObject([1]);    # S1Q1
$survey->surveyJSON_update([1,1], { variable => 'S1Q1' });

# Now start a response as admin user
$session->user( { userId =>3 } );
$survey->responseIdCookies(0);

my $responseId = $survey->responseId;
my $s = WebGUI::Asset::Wobject::Survey->newByResponseId($session, $responseId);
is($s->getId, $survey->getId, 'newByResponseId returns same Survey');
is($s->get('maxResponsesPerUser'), 1, 'maxResponsesPerUser defaults to 1');
ok($s->canTakeSurvey, '..which means user can take survey');

# Complete Survey
$s->surveyEnd();

# Uncache canTake
delete $s->{canTake};
delete $s->{responseId};
$s->responseIdCookies(0);
ok(!$s->canTakeSurvey, 'Cannot take survey a second time (maxResponsesPerUser=1)');
cmp_deeply($s->responseId, undef, '..and similarly cannot get responseId');

# Change maxResponsesPerUser to 2
$s->update({maxResponsesPerUser => 2});
delete $s->{canTake};
ok($s->canTakeSurvey, '..but can take when maxResponsesPerUser increased to 2');
ok($s->responseId, '..and similarly can get responseId');

# Change maxResponsesPerUser to 0
$s->update({maxResponsesPerUser => 0});
delete $s->{canTake};
delete $s->{responseId};
ok($s->canTakeSurvey, '..and also when maxResponsesPerUser set to 0 (unlimited)');
ok($s->responseId, '..(and similarly for responseId)');

# Restart the survey
$s->submitQuestions({
    '0-0-0'        => 'My chosen answer',
    '0-1-0'        => 'My chosen answer',
});

cmp_deeply(
    $s->responseJSON->responses,
    superhashof(
        {   '0-1-0' => {
                'verbatim' => undef,
                'comment'  => undef,
                'time'     => num( time, 5 ),
                'value'    => ''
            },
            '0-0-0' => {
                'verbatim' => undef,
                'comment'  => undef,
                'time'     => num( time, 5 ),
                'value'    => ''
            },
        }
    ),
    'submitQuestions does the right thing'
);

# Test Restart
$s->surveyEnd( { restart => 1 } );
cmp_deeply($s->responseJSON->responses, {}, 'restart removes the in-progress response');
ok($responseId ne $s->responseId, '..and uses a new responseId');

# Test out exitUrl with an explicit
use JSON;
my $surveyEnd = $s->surveyEnd( { exitUrl => 'home' } );
cmp_deeply(from_json($surveyEnd), { type => 'forward', url => '/home' }, 'exitUrl works (it adds a slash for us)');

# Test out exitUrl using survye instance exitURL property
$s->update({ exitURL => 'getting_started'});
$surveyEnd = $s->surveyEnd( { exitUrl => undef } );
cmp_deeply(from_json($surveyEnd), { type => 'forward', url => '/getting_started' }, 'exitUrl works (it adds a slash for us)');

# www_jumpTo
{
    # Check a simple www_jumpTo request
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


}

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

#----------------------------------------------------------------------------
# Cleanup
END {
    $survey->purge() if $survey;

    my $versionTag = WebGUI::VersionTag->getWorking( $session, 1 );
    $versionTag->rollback() if $versionTag;
}
