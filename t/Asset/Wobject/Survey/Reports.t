# Tests WebGUI::Asset::Wobject::Survey Reporting
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Asset::Wobject::Survey');
my ($survey);

# Returns the contents of the Survey_tempReport table
sub getAll { $session->db->buildArrayRefOfHashRefs('select * from Survey_tempReport where assetId = ?', [$survey->getId]) }

my $user = WebGUI::User->new( $session, 'new' );
WebGUI::Test->addToCleanup($user);
my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
$survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
WebGUI::Test->addToCleanup($survey);
isa_ok($survey, 'WebGUI::Asset::Wobject::Survey');

my $sJSON = $survey->getSurveyJSON;

# Load bare-bones survey, containing a single section (S0)
$sJSON->update([0], { variable => 'S0' });

# Add 2 questions to S0
$sJSON->newObject([0]);    # S0Q0
$sJSON->update([0,0], { variable => 'S0Q0', questionType => 'Yes/No' });

# Change the Yes/No default properties
my $yesProps = { 
    value => 10, # e.g. score
    recordedAnswer => 'Yessir',
    isCorrect => 0,
    verbatim => 1,
    };
my $noProps = { 
    value => 20, # e.g. score
    recordedAnswer => 'Nosir',
    isCorrect => 1,
    verbatim => 1,
    };
$sJSON->update([0,0,0], $yesProps);
$sJSON->update([0,0,1], $noProps);
$sJSON->newObject([0]);    # S0Q1
$sJSON->update([0,1], { variable => 'S0Q1', questionType => 'Yes/No' });
$sJSON->update([0,1,0], $yesProps);
$sJSON->update([0,1,1], $noProps);

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
$survey->recordResponses( {
    '0-0-0' => 'Y',
    '0-0comment' => 'I answered S0Q0',
    '0-0-0verbatim' => '..and chose Y',
    '0-1-1' => 'N',
    '0-1comment' => 'I answered S0Q1',
    '0-1-1verbatim' => '..and chose N',
    } );
$survey->loadTempReportTable;

cmp_deeply(getAll, [
superhashof({
    assetId => $survey->getId,
    Survey_responseId => $responseId,
    order => 1,
    sectionNumber => 0,
    sectionName => 'S0',
    questionNumber => 0,
    questionName => 'S0Q0',
    questionComment => 'I answered S0Q0',
    answerNumber => 0,
    answerValue => 'Yessir', # e.g. recorded value
    answerComment => '..and chose Y',
    isCorrect => 0,
    value => 10, # e.g. score
}),
superhashof({
    assetId => $survey->getId,
    Survey_responseId => $responseId,
    order => 2,
    sectionNumber => 0,
    sectionName => 'S0',
    questionNumber => 1,
    questionName => 'S0Q1',
    questionComment => 'I answered S0Q1',
    answerNumber => 1,
    answerValue => 'Nosir', # e.g. recorded value
    answerComment => '..and chose N',
    isCorrect => 1,
    value => 20, # e.g. score
})]);


#vim:ft=perl
