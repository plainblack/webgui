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
#WebGUI::Error->Trace(1);

#----------------------------------------------------------------------------
# Tests
plan tests => 4;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::SurveyCompleted');
my $user = WebGUI::User->new( $session, 'new' );
my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
my $survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
my $survey_id = $survey->getId();

my $responses = {
    commentCols  => 10,
    commentRows  => 5,
    copy         => 0,
    delete       => 0,
    id           => 'undefined-0',
    maxAnswers   => 1,
    questionType => 'Yes/No',
    randomWords  => undef,
    text         => 'test',
    value        => 1,
    variable     => undef,
};

my @address = split /-/, $responses->{id};

$survey->loadSurveyJSON();
$survey->survey->update( \@address, $responses );
$survey->saveSurveyJSON();

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
    
    # Simulate user starting survey
    my $response_id = $session->db->setRow("Survey_response","Survey_responseId",{
                Survey_responseId=>"new",
                userId=>$user->userId,
                startDate=>WebGUI::DateTime->now->toDatabase,
                endDate=>WebGUI::DateTime->now->toDatabase,
                assetId=>$survey->getId()
            });
    ok( !$rule->evaluateFor( { user => $user } ), q{Mr User hasn't finished Survey yet} );

    # Simulate Survey completion
    $session->db->setRow("Survey_response","Survey_responseId",{
                Survey_responseId=>$response_id,
                endDate=>WebGUI::DateTime->now->toDatabase,
                isComplete=>1
            });
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
