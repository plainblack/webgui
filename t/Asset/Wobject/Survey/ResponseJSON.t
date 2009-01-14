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
my $tests = 77;
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

####################################################
#
# goto
#
####################################################
$rJSON->survey->section([0])->{variable} = 'goto 0';
$rJSON->survey->question([0,0])->{variable} = 'goto 0-0';
$rJSON->survey->question([0,1])->{variable} = 'goto 0-1';
$rJSON->survey->question([0,2])->{variable} = 'goto 0-2';
$rJSON->survey->section([1])->{variable} = 'goto 1';
$rJSON->survey->question([1,0])->{variable} = 'goto 1-0';
$rJSON->survey->question([1,1])->{variable} = 'goto 1-1';
$rJSON->survey->section([2])->{variable} = 'goto 2';
$rJSON->survey->section([3])->{variable} = 'goto 2';
$rJSON->survey->question([3,0])->{variable} = 'goto 3-0';
$rJSON->survey->question([3,1])->{variable} = 'goto 3-0';  ##Intentional duplicate
$rJSON->survey->question([3,2])->{variable} = 'goto 3-2';

$rJSON->lastResponse(0);
$rJSON->goto('goto 80');
is($rJSON->lastResponse(), 0, 'goto: no change in lastResponse if the variable cannot be found');
$rJSON->goto('goto 1');
is($rJSON->lastResponse(), 2, 'goto: works on existing section');
$rJSON->goto('goto 0-1');
is($rJSON->lastResponse(), 0, 'goto: works on existing question');
$rJSON->goto('goto 3-0');
is($rJSON->lastResponse(), 5, 'goto: finds first if there are duplicates');

####################################################
#
# processGotoExpression
#
####################################################
is($rJSON->processGotoExpression(),
    undef, 'processGotoExpression undef with empty arguments');
is($rJSON->processGotoExpression('blah-dee-blah-blah'),
    undef, '.. and undef with duff expression');
is($rJSON->processGotoExpression(':'),
    undef, '.. and undef with missing target');
is($rJSON->processGotoExpression('t1:'),
    undef, '.. and undef with missing expression');
cmp_deeply($rJSON->processGotoExpression('t1: 1'),
    { target => 't1', expression => '1'}, 'works for simple numeric expression');
cmp_deeply($rJSON->processGotoExpression('t1: 1 - 23 + 456 * (78 / 9.0)'),
    { target => 't1', expression => '1 - 23 + 456 * (78 / 9.0)'}, 'works for expression using all algebraic tokens');
is($rJSON->processGotoExpression('t1: 1 + &'), undef, '.. but disallows expression containing non-whitelisted token');
cmp_deeply($rJSON->processGotoExpression('t1: 1 = 3'),
    { target => 't1', expression => '1 == 3'}, 'converts single = to ==');
cmp_deeply($rJSON->processGotoExpression('t1: 1 != 3 <= 4 >= 5'),
    { target => 't1', expression => '1 != 3 <= 4 >= 5'}, q{..but doesn't mess with other ops containing =});
cmp_deeply($rJSON->processGotoExpression('t1: q1 + q2 * q3 - 4', { q1 => 11, q2 => 22, q3 => 33}),
    { target => 't1', expression => '11 + 22 * 33 - 4'}, 'substitues q for value');
cmp_deeply($rJSON->processGotoExpression('t1: a silly var name * 10 + another var name', { 'a silly var name' => 345, 'another var name' => 456}),
    { target => 't1', expression => '345 * 10 + 456'}, '..it even works for vars with spaces in their names');
is($rJSON->processGotoExpression('t1: qX + 3', { q1 => '7'}),
    undef, q{..but doesn't like invalid var names});

####################################################
#
# gotoExpression
#
####################################################

$rJSON->survey->section([0])->{variable} = 's0';
$rJSON->survey->section([2])->{variable} = 's2';
$rJSON->survey->question([1,0])->{variable} = 's1q0';
$rJSON->survey->answer([1,0,0])->{value} = 3;

$rJSON->lastResponse(2);
$rJSON->recordResponses($session, {
    '1-0comment'   => 'Section 1, question 0 comment',
    '1-0-0'        => 'First answer',
    '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
});
is($rJSON->gotoExpression('blah-dee-blah-blah'), undef, 'invalid gotoExpression is false');
ok($rJSON->gotoExpression('s0: s1q0 = 3'), '3 == 3 is true');
ok(!$rJSON->gotoExpression('s0: s1q0 = 4'), '3 == 4 is false');
ok($rJSON->gotoExpression('s0: s1q0 != 2'), '3 != 2 is true');
ok(!$rJSON->gotoExpression('s0: s1q0 != 3'), '3 != 3 is false');
ok($rJSON->gotoExpression('s0: s1q0 > 2'), '3 > 2 is true');
ok($rJSON->gotoExpression('s0: s1q0 < 4'), '3 < 2 is true');
ok(!$rJSON->gotoExpression('s0: s1q0 >= 4'), '3 >= 4 is false');
ok(!$rJSON->gotoExpression('s0: s1q0 <= 2'), '3 >= 4 is false');

cmp_deeply($rJSON->gotoExpression(<<"END_EXPRESSION"), {target => 's2', expression => '3 == 3'}, 'first true expression wins');
s0: s1q0 <= 2
s2: s1q0 = 3
END_EXPRESSION

ok(!$rJSON->gotoExpression(<<"END_EXPRESSION"), 'but multiple false expressions still false');
s0: s1q0 <= 2
s2: s1q0 = 345
END_EXPRESSION

$rJSON->gotoExpression('s0: s1q0 = 3');
is($rJSON->lastResponse(), -1, '.. lastResponse changed to -1 due to goto(s0)');
$rJSON->gotoExpression('s2: s1q0 = 3');
is($rJSON->lastResponse(), 4, '.. lastResponse changed to 4 due to goto(s2)');

$rJSON->{responses} = {};
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);

####################################################
#
# recordResponses
#
####################################################

$rJSON->lastResponse(4);
my $terminals;
cmp_deeply(
    $rJSON->recordResponses($session, {}),
    [ 0, undef ],
    'recordResponses, if section has no questions, returns terminal info in the section.  With no terminal info, returns [0, undef]',
);
is($rJSON->lastResponse(), 5, 'recordResponses, increments lastResponse if there are no questions in the section');

$rJSON->survey->section([2])->{terminal}    = 1;
$rJSON->survey->section([2])->{terminalUrl} = '/terminal';

$rJSON->lastResponse(4);
cmp_deeply(
    $rJSON->recordResponses($session, {}),
    [ 1, '/terminal' ],
    'recordResponses, if section has no questions, returns terminal info in the section.',
);
is($rJSON->questionsAnswered, 0, 'questionsAnswered=0, no questions answered');

$rJSON->survey->question([1,0])->{terminal}    = 1;
$rJSON->survey->question([1,0])->{terminalUrl} = 'question 1-0 terminal';

$rJSON->lastResponse(2);
cmp_deeply(
    $rJSON->recordResponses($session, {
        '1-0comment'   => 'Section 1, question 0 comment',
        '1-0-0'        => 'First answer',
        '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
    }),
    [ 1, 'question 1-0 terminal' ],
    'recordResponses: question terminal overrides section terminal',
);
is($rJSON->lastResponse(), 4, 'lastResponse advanced to next page of questions');
is($rJSON->questionsAnswered, 1, 'questionsAnswered=1, answered one question');

cmp_deeply(
    $rJSON->responses,
    {
        '1-0'   => {
            comment => 'Section 1, question 0 comment',
        },
        '1-0-0' => {
            comment => 'Section 1, question 0, answer 0 comment',
            'time'    => num(time(), 3),
            value   => 1,
        },
        '1-1'   => {
            comment => undef,
        }
    },
    'recordResponses: recorded responses correctly, two questions, one answer, comments, values and time'
);

$rJSON->survey->question([1,0,0])->{terminal}    = 1;
$rJSON->survey->question([1,0,0])->{terminalUrl} = 'answer 1-0-0 terminal';
$rJSON->{responses} = {};
$rJSON->lastResponse(2);
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);

cmp_deeply(
    $rJSON->recordResponses($session, {
        '1-0comment'   => 'Section 1, question 0 comment',
        '1-0-0'        => "\t\t\t\n\n\n\t\t\t", #SOS in whitespace
        '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
    }),
    [ 1, 'answer 1-0-0 terminal' ],
    'recordResponses: answer terminal overrides question and section terminals',
);

cmp_deeply(
    $rJSON->responses,
    {
        '1-0'   => {
            comment => 'Section 1, question 0 comment',
        },
        '1-1'   => {
            comment => undef,
        }
    },
    'recordResponses: if the answer is all whitespace, it is skipped over'
);
is($rJSON->questionsAnswered, 0, 'question was all whitespace, not answered');

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
