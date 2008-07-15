# Tests WebGUI::Flux::Operand::FluxRule
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux::Rule;
use WebGUI::Asset::Wobject::Survey;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 4;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::SurveyCompleted');
my $user        = WebGUI::User->new( $session, 'new' );
my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
# N.B. This is all a bit pointless until Survey 2.0 comes out because Survey don't provide 
# an API to perform these operations (thus our Operand really just tests against the manual
# sql writes we make here. Still..
my $survey_id   = $session->id->generate();
my $survey      = $import_node->addChild(
    {   className => 'WebGUI::Asset::Wobject::Survey',
        Survey_id => $survey_id,
    }
);
my $assetId = $survey->getId();
my $qid     = $survey->setCollateral(
    "Survey_question",
    "Survey_questionId",
    {   Survey_id         => $survey_id,
        Survey_questionId => 'new',
        question          => 'dummy question',
        allowComment      => 0,
        gotoQuestion      => 1,
        answerFieldType   => 'text',
        randomizeAnswers  => 0,
        Survey_sectionId  => 1,
    },
    1, 0,
    "Survey_id"
);

# Add boolean answers
$survey->addAnswer( 31, $qid );
my $aid = $survey->addAnswer( 32, $qid );

{
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'SurveyCompleted',
            operand1Args => qq[{"surveyId":  "$survey_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
        }
    );
    ok( !$rule->evaluateFor( { user => $user } ), q{Mr User hasn't even started Survey yet} );

    # Simulate Survey start..
    my $response_id = $session->db->setRow(
        "Survey_response",
        "Survey_responseId",
        {   'Survey_responseId' => "new",
            userId              => $user->userId(),
            username            => $user->username(),
            startDate           => $session->datetime->time(),
            'Survey_id'         => $survey_id
        }
    );

    $session->db->write(
        <<END_SQL
insert into Survey_questionResponse (
    Survey_answerId,
    Survey_questionId,
    Survey_responseId,
    Survey_id,
    comment,
    response,
    dateOfResponse
) values (?,?,?,?,?,?,?)
END_SQL
        , [ $aid, $qid, $response_id, $survey_id, 1, 1, $session->datetime->time() ]
    );
    
    ok( !$rule->evaluateFor( { user => $user, } ), q{Not finished yet..} );

    # Simulate Survey completion..
    $session->db->setRow(
        "Survey_response",
        "Survey_responseId",
        {   isComplete        => 1,
            endDate           => $session->datetime->time(),
            Survey_responseId => $response_id,
        }
    );

    ok( $rule->evaluateFor( { user => $user, } ), q{Now he's done it!} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
    $user->delete() if $user;

    my $versionTag = WebGUI::VersionTag->getWorking( $session, 1 );
    $versionTag->rollback() if $versionTag;
}
