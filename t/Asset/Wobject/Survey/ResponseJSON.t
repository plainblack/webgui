# Tests WebGUI::Asset::Wobject::Survey
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use Test::MockObject::Extends;
use Data::Dumper;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset::Wobject::Survey::SurveyJSON;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 36;
plan tests => $tests + 1;

#----------------------------------------------------------------------------
# put your tests here

my $usedOk = use_ok('WebGUI::Asset::Wobject::Survey::ResponseJSON');
my ($responseJSON);

SKIP: {

skip $tests, "Unable to load ResponseJSON" unless $usedOk;

####################################################
#
# new, part 1
#
####################################################

my $newTime = time();
$responseJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new('{}', $session->log);
isa_ok($responseJSON , 'WebGUI::Asset::Wobject::Survey::ResponseJSON');

is($responseJSON->lastResponse(), -1, 'new: default lastResponse is -1');
is($responseJSON->{questionsAnswered}, 0, 'new: questionsAnswered is 0 by default');
cmp_ok((abs$responseJSON->{startTime} - $newTime), '<=', 2, 'new: by default startTime set to time');
is_deeply( $responseJSON->responses, {}, 'new: by default, responses is an empty hashref');
is_deeply( $responseJSON->surveyOrder, [], 'new: by default, responses is an empty arrayref');

my $now = time();
my $rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(qq!{ "startTime": $now }!, $session->log);
cmp_ok(abs($rJSON->startTime() - $now), '<=', 2, 'new: startTime set using JSON');

####################################################
#
# startTime
#
####################################################

$rJSON->startTime(780321600);
is($rJSON->startTime, 780321600, 'startTime: set and get');

####################################################
#
# hasTimedOut
#
####################################################

##Reset for next set of tests
$rJSON->startTime(time());

ok( ! $rJSON->hasTimedOut(1), 'hasTimedOut, not timed out, checked with 1 minute timeout');
ok( ! $rJSON->hasTimedOut(0), 'hasTimedOut, not timed out, checked with 0 minute timeout');

$rJSON->startTime(time()-7200);
ok(   $rJSON->hasTimedOut(1),    'hasTimedOut, timed out');
ok( ! $rJSON->hasTimedOut(0),    'hasTimedOut, bad limit');
ok( ! $rJSON->hasTimedOut(4*60), 'hasTimedOut, limit check');

####################################################
#
# createSurveyOrder
#
####################################################

$rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(q!{}!, $session->log, buildSurveyJSON($session));

$rJSON->createSurveyOrder();
cmp_deeply(
    $rJSON->surveyOrder,
    [
        [ 0, 0, [0] ],
        [ 0, 1, [0] ],
        [ 0, 2, [0, 1] ],
        [ 1, 0, [0, 1] ],
        [ 1, 1, [0, 1] ],
        [ 2 ],
        [ 3, 0, [0, 1] ],
        [ 3, 1, [0, 1, 2, 3, 4, 5, 6] ],
        [ 3, 2, [0] ],
    ],
    'createSurveyOrder, enumerated all sections, questions and answers'
);

####################################################
#
# shuffle
#
####################################################

{
    my @dataToRandomize = 0..49;
    my @randomizedData = WebGUI::Asset::Wobject::Survey::ResponseJSON::shuffle(@dataToRandomize);
    cmp_bag(\@dataToRandomize, \@randomizedData, 'shuffle: No data lost during shuffling');
}

####################################################
#
# createSurveyOrder, part 2
#
####################################################

{
    no strict "refs";
    no warnings;
    my $rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(q!{}!, $session->log, buildSurveyJSON($session));
    $rJSON->survey->section([0])->{randomizeQuestions} = 0;
    my $shuffleName = "WebGUI::Asset::Wobject::Survey::ResponseJSON::shuffle";
    my $shuffleCalled = 0;
    my $shuffleRef = \&$shuffleName;
    *$shuffleName = sub {
        $shuffleCalled = 1;
        goto &$shuffleRef;
    };
    $rJSON->createSurveyOrder();
    is($shuffleCalled, 0, 'createSurveyOrder did not call shuffle on a section');

    $shuffleCalled = 0;
    $rJSON->survey->section([0])->{randomizeQuestions} = 1;
    $rJSON->createSurveyOrder();
    is($shuffleCalled, 1, 'createSurveyOrder called shuffle on a section');

    $shuffleCalled = 0;
    $rJSON->survey->section([0])->{randomizeQuestions} = 0;
    $rJSON->survey->question([0,0])->{randomizeAnswers} = 1;
    $rJSON->createSurveyOrder();
    is($shuffleCalled, 1, 'createSurveyOrder called shuffle on a question');

    ##Restore the subroutine to the original
    *$shuffleName = &$shuffleRef;
}

####################################################
#
# surveyEnd
#
####################################################

$rJSON->lastResponse(2);
ok( ! $rJSON->surveyEnd(), 'surveyEnd, with 9 elements, 2 != end of survey');
$rJSON->lastResponse(7);
ok( ! $rJSON->surveyEnd(), 'surveyEnd, with 9 elements, 7 != end of survey');
$rJSON->lastResponse(8);
ok(   $rJSON->surveyEnd(), 'surveyEnd, with 9 elements, 8 == end of survey');
$rJSON->lastResponse(20);
ok(   $rJSON->surveyEnd(), 'surveyEnd, with 9 elements, 20 >= end of survey');

####################################################
#
# nextSectionId, nextSection, currentSection
#
####################################################

$rJSON->lastResponse(0);
is($rJSON->nextSectionId(), 0, 'nextSectionId, lastResponse=0, nextSectionId=0');
cmp_deeply(
    $rJSON->nextSection,
    $rJSON->survey->section([0]),
    'lastResponse=0, nextSection = section 0'
);
cmp_deeply(
    $rJSON->currentSection,
    $rJSON->survey->section([0]),
    'lastResponse=0, currentSection = section 0'
);

$rJSON->lastResponse(2);
is($rJSON->nextSectionId(), 1, 'nextSectionId, lastResponse=2, nextSectionId=1');
cmp_deeply(
    $rJSON->nextSection,
    $rJSON->survey->section([1]),
    'lastResponse=2, nextSection = section 1'
);
cmp_deeply(
    $rJSON->currentSection,
    $rJSON->survey->section([0]),
    'lastResponse=2, currentSection = section 0'
);

$rJSON->lastResponse(6);
is($rJSON->nextSectionId(), 3, 'nextSectionId, lastResponse=6, nextSectionId=3');
cmp_deeply(
    $rJSON->nextSection,
    $rJSON->survey->section([3]),
    'lastResponse=0, nextSection = section 3'
);
cmp_deeply(
    $rJSON->currentSection,
    $rJSON->survey->section([3]),
    'lastResponse=6, currentSection = section 3'
);

$rJSON->lastResponse(20);
is($rJSON->nextSectionId(), undef, 'nextSectionId, lastResponse > surveyEnd, nextSectionId=undef');

####################################################
#
# nextQuestions
#
####################################################

$rJSON->lastResponse(20);
ok($rJSON->surveyEnd, 'nextQuestions: lastResponse indicates end of survey');
is_deeply($rJSON->nextQuestions, [], 'nextQuestions returns an empty array ref if there are no questions available');
$rJSON->survey->section([0])->{questionsPerPage} = 2;
$rJSON->survey->section([1])->{questionsPerPage} = 2;
$rJSON->survey->section([2])->{questionsPerPage} = 2;
$rJSON->survey->section([3])->{questionsPerPage} = 2;
$rJSON->lastResponse(-1);
cmp_deeply(
    $rJSON->nextQuestions(),
    [
        superhashof({
            sid  => 0,
            id   => '0-0',
            text => 'Question 0-0',
            type => 'question',
            answers => [
                superhashof({
                    type => 'answer',
                    id   => '0-0-0',
                }),
            ],
        }),
        superhashof({
            sid  => 0,
            id   => '0-1',
            text => 'Question 0-1',
            type => 'question',
            answers => [
                superhashof({
                    type => 'answer',
                    id   => '0-1-0',
                }),
            ],
        }),
    ],
    'nextQuestions returns the correct data structre, amounts and members'
);

$rJSON->lastResponse(1);
cmp_deeply(
    $rJSON->nextQuestions(),
    [
        superhashof({
            sid  => 0,
            id   => '0-2',
            text => 'Question 0-2',
            type => 'question',
            answers => [
                superhashof({
                    type => 'answer',
                    id   => '0-2-0',
                }),
                superhashof({
                    type => 'answer',
                    id   => '0-2-1',
                }),
            ],
        }),
    ],
    'nextQuestions obeys questionPerPage'
);

$rJSON->lastResponse(4);
cmp_deeply(
    $rJSON->nextQuestions(),
    undef,
    'nextQuestions: returns undef if the next section is empty'
);

}

####################################################
#
# Utility test routines
#
####################################################

sub buildSurveyJSON {
    my $session = shift;
    my $sjson = WebGUI::Asset::Wobject::Survey::SurveyJSON->new(undef, $session->log);
    ##Build 4 sections.  Remembering that one is created by default when you make an empty SurveyJSON object
    $sjson->newObject([]);
    $sjson->newObject([]);
    $sjson->newObject([]);
    ##Add questions to the sections
    $sjson->newObject([0]);
    $sjson->newObject([0]);
    $sjson->newObject([0]);
    $sjson->newObject([1]);
    $sjson->newObject([1]);
    ##Section 3 has no questions
    $sjson->newObject([3]);
    $sjson->newObject([3]);
    $sjson->newObject([3]);
    ##Add questions
    $sjson->updateQuestionAnswers([0,0], 'Email');
    $sjson->updateQuestionAnswers([0,1], 'Phone number');
    $sjson->updateQuestionAnswers([0,2], 'Yes/No');
    $sjson->updateQuestionAnswers([1,0], 'True/False');
    $sjson->updateQuestionAnswers([1,1], 'Gender');
    $sjson->updateQuestionAnswers([3,0], 'Date Range');
    $sjson->updateQuestionAnswers([3,1], 'Ideology');
    $sjson->updateQuestionAnswers([3,2], 'Email');
    ##Title the sections and questions
    $sjson->section([0])->{title} = "Section 0";
    $sjson->section([1])->{title} = "Section 1";
    $sjson->section([2])->{title} = "Section 2";
    $sjson->section([3])->{title} = "Section 3";
    $sjson->question([0,0])->{text} = "Question 0-0";
    $sjson->question([0,1])->{text} = "Question 0-1";
    $sjson->question([0,2])->{text} = "Question 0-2";
    $sjson->question([1,0])->{text} = "Question 1-0";
    $sjson->question([1,1])->{text} = "Question 1-1";
    $sjson->question([3,0])->{text} = "Question 3-0";
    $sjson->question([3,1])->{text} = "Question 3-1";
    $sjson->question([3,2])->{text} = "Question 3-2";
    return $sjson;
}

#----------------------------------------------------------------------------
# Cleanup
END { }
