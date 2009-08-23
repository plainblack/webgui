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
use Test::Exception;
use Data::Dumper;
use List::Util qw/shuffle/;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset::Wobject::Survey::SurveyJSON;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 106;
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
$responseJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session), '{}');
isa_ok($responseJSON , 'WebGUI::Asset::Wobject::Survey::ResponseJSON');

is($responseJSON->lastResponse(), -1, 'new: default lastResponse is -1');
is($responseJSON->questionsAnswered, 0, 'new: questionsAnswered is 0 by default');

####################################################
#
# initSurveyOrder
#
####################################################

my $rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session), q!{}!);

#$rJSON->initSurveyOrder();
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
    'initSurveyOrder, enumerated all sections, questions and answers'
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
# initSurveyOrder, part 2
#
####################################################

{
    my $rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session), q!{}!);

    $rJSON->survey->section([0])->{randomizeQuestions} = 0;
    $rJSON->initSurveyOrder();
    my @question_order = map {$_->[1]} grep {$_->[0] == 0} @{$rJSON->surveyOrder};
    cmp_deeply(\@question_order, [0,1,2], 'initSurveyOrder did not shuffle questions');

    $rJSON->survey->section([0])->{randomizeQuestions} = 1;
    srand(42); # Make shuffle predictable
    $rJSON->initSurveyOrder();
    @question_order = map {$_->[1]} grep {$_->[0] == 0} @{$rJSON->surveyOrder};
    srand(42);
    my @expected_order = shuffle(0,1,2);
    cmp_deeply(\@question_order, \@expected_order, 'initSurveyOrder shuffled questions in first section');

    $rJSON->survey->section([0])->{randomizeQuestions} = 0;
    $rJSON->survey->question([0,0])->{randomizeAnswers} = 0;
    $rJSON->initSurveyOrder();
    my @answer_order = map {@{$_->[2]}} grep {$_->[0] == 3 && $_->[1] == 1} @{$rJSON->surveyOrder};
    cmp_deeply(\@answer_order, [0,1,2,3,4,5,6], 'initSurveyOrder did not shuffle answers');
    
    $rJSON->survey->question([3,1])->{randomizeAnswers} = 1;
    srand(42); # Make shuffle predictable
    $rJSON->initSurveyOrder();
    @answer_order = map {@{$_->[2]}} grep {$_->[0] == 3 && $_->[1] == 1} @{$rJSON->surveyOrder};
    srand(42); # Make shuffle predictable
    @expected_order = shuffle(0..6);
    cmp_deeply(\@answer_order, \@expected_order, 'initSurveyOrder shuffled answers');
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
# nextResponseSectionIndex, nextResponseSection, lastResponseSectionIndex
#
####################################################

$rJSON->lastResponse(0);
is($rJSON->nextResponseSectionIndex, 0, 'nextResponseSectionIndex, lastResponse=0, nextResponseSectionIndex=0');
cmp_deeply(
    $rJSON->nextResponseSection,
    $rJSON->survey->section([0]),
    'lastResponse=0, nextResponseSection = section 0'
);
is(
    $rJSON->lastResponseSectionIndex,
    0,
    'lastResponse=0, lastResponseSectionIndex = 0'
);

$rJSON->lastResponse(2);
is($rJSON->nextResponseSectionIndex(), 1, 'nextResponseSectionIndex, lastResponse=2, nextResponseSectionIndex=1');
cmp_deeply(
    $rJSON->nextResponseSection,
    $rJSON->survey->section([1]),
    'lastResponse=2, nextResponseSection = section 1'
);
is(
    $rJSON->lastResponseSectionIndex,
    0,
    'lastResponse=2, lastResponseSectionIndex = 0'
);

$rJSON->lastResponse(6);
is($rJSON->nextResponseSectionIndex(), 3, 'nextResponseSectionIndex, lastResponse=6, nextResponseSectionIndex=3');
cmp_deeply(
    $rJSON->nextResponseSection,
    $rJSON->survey->section([3]),
    'lastResponse=0, nextResponseSection = section 3'
);
cmp_deeply(
    $rJSON->lastResponseSectionIndex,
    3,
    'lastResponse=6, lastResponseSectionIndex = 3'
);

$rJSON->lastResponse(20);
is($rJSON->nextResponseSectionIndex(), undef, 'nextResponseSectionIndex, lastResponse > surveyEnd, nextResponseSectionIndex=undef');

####################################################
#
# nextQuestions
#
####################################################

$rJSON->lastResponse(20);
ok($rJSON->surveyEnd, 'nextQuestions: lastResponse indicates end of survey');
is_deeply([$rJSON->nextQuestions], [], 'nextQuestions returns an empty array if there are no questions available');
$rJSON->survey->section([0])->{questionsPerPage} = 2;
$rJSON->survey->section([1])->{questionsPerPage} = 2;
$rJSON->survey->section([2])->{questionsPerPage} = 2;
$rJSON->survey->section([3])->{questionsPerPage} = 2;
$rJSON->lastResponse(-1);
cmp_deeply(
    [$rJSON->nextQuestions],
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
    [$rJSON->nextQuestions],
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
    [$rJSON->nextQuestions],
    [],
    'nextQuestions: returns an empty array if the next section is empty'
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
$rJSON->reset;
$rJSON->processGoto('goto 80');
is($rJSON->lastResponse(), -1, 'goto: no change in lastResponse if the variable cannot be found');
$rJSON->processGoto('goto 1');
is($rJSON->lastResponse(), 2, 'goto: works on existing section');
$rJSON->processGoto('goto 0-1');
is($rJSON->lastResponse(), 0, 'goto: works on existing question');
$rJSON->processGoto('goto 3-0');
is($rJSON->lastResponse(), 5, 'goto: finds first if there are duplicates');

####################################################
#
# surveyOrderIndex
#
####################################################
my $expect = {
    'goto 0'   => 0,
    'goto 0-0' => 0,
    'goto 0-1' => 1,
    'goto 0-2' => 2,
    'goto 1'   => 3,
    'goto 1-0' => 3,
    'goto 1-1' => 4,
    'goto 2'   => 5,
    'goto 3-0' => 6,
    'goto 3-2' => 8,
};
cmp_deeply($rJSON->surveyOrderIndex(), $expect, 'surveyOrderIndex');

####################################################
#
# responseScores
#
####################################################

$rJSON->survey->section([0])->{variable} = 's0';
$rJSON->survey->section([1])->{variable} = 's1';
$rJSON->survey->section([2])->{variable} = 's2';
$rJSON->survey->section([3])->{variable} = 's3';
$rJSON->survey->question([1,0])->{variable} = 's1q0';
$rJSON->survey->question([1,1])->{variable} = 's1q1';
$rJSON->survey->answer([1,0,0])->{value} = 100; # set answer score
$rJSON->survey->answer([1,1,0])->{value} = 200; # set answer score
cmp_deeply($rJSON->responseScores, {}, 'scores initially empty');

$rJSON->lastResponse(2);
$rJSON->recordResponses({
    '1-0-0'        => 'My chosen answer',
    '1-1-0'        => 'My chosen answer',
});
cmp_deeply($rJSON->responseScores(indexBy => 'variable'), { s1q0 => 100, s1q1 => 200, s1 => 300}, 'scores now reflect q answers and section totals');

####################################################
#
# processExpression
#
####################################################
# Turn on the survey Expression Engine
WebGUI::Test->originalConfig('enableSurveyExpressionEngine');
$session->config->set('enableSurveyExpressionEngine', 1);
$rJSON->survey->section([0])->{variable} = 's0';
$rJSON->survey->question([0,0])->{variable} = 's0q0'; # surveyOrder index = 0
$rJSON->survey->question([0,1])->{variable} = 's0q1'; # surveyOrder index = 1
$rJSON->survey->question([0,2])->{variable} = 's0q2'; # surveyOrder index = 2
$rJSON->survey->section([1])->{variable} = 's1';
$rJSON->survey->question([1,0])->{variable} = 's1q0'; # surveyOrder index = 3
$rJSON->survey->question([1,1])->{variable} = 's1q1'; # surveyOrder index = 4
$rJSON->survey->section([2])->{variable} = 's2'; # empty section appears as surveyOrder index = 5
$rJSON->survey->section([3])->{variable} = 's3';
$rJSON->survey->question([3,0])->{variable} = 's3q0'; # surveyOrder index = 6
$rJSON->survey->question([3,1])->{variable} = 's3q1'; # surveyOrder index = 7
$rJSON->survey->question([3,2])->{variable} = 's3q2'; # surveyOrder index = 8

$rJSON->survey->answer([0,0,0])->{value} = 100; # set answer score
$rJSON->survey->answer([0,1,0])->{value} = 200; # set answer score
$rJSON->survey->answer([0,1,0])->{verbatim} = 1; # make this answer verbatim

# Reset responses and record first answer
$rJSON->reset;
$rJSON->recordResponses({
    '0-0-0' => 3, # it's a funny email address I know...
    '0-1-0' => '13 11 66',
    '0-1-0verbatim' => 'So you want to know more',
});

is($rJSON->nextResponse, 2, 'nextResponse at 2 (s0q1) after first response');

$rJSON->processExpression('blah-dee-blah-blah {');
is($rJSON->nextResponse, 2, '..unchanged after duff expression');

$rJSON->processExpression('jump { value(s0q0) == 4} s1');
is($rJSON->nextResponse, 2, '..unchanged after false expression');

$rJSON->processExpression('jump { value(s0q0) == 4} s0; jump { value(s1q0) == 5} s1;');
is($rJSON->nextResponse, 2, '..similarly for multi-statement false expression');

$rJSON->processExpression('jump { value(s0q0) == 3} DUFF_TARGET');
is($rJSON->nextResponse, 2, '..similarly for expression with invalid target');

$rJSON->processExpression('jump { value(s0q0) == 3} s1');
is($rJSON->nextResponse, 3, 'jumps to index of first question in section');

$rJSON->processExpression('jump { value(s0q0) == 3} s2');
is($rJSON->nextResponse, 5, '..and updated to s2 with different jump target');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { value(s0q0) == 3} s3');
is($rJSON->nextResponse, 6, '..and updated to s3 with different jump target');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { value(s0q0) == 3} s3q1');
is($rJSON->nextResponse, 7, '..we can also jump to a question rather than a section');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { value(s0q0) == 3} NEXT_SECTION');
is($rJSON->nextResponse, 3, '..we can also use the NEXT_SECTION target');

$rJSON->lastResponse(3); # pretend we just finished s1q0
$rJSON->processExpression('jump { value(s0q0) == 3} NEXT_SECTION');
is($rJSON->nextResponse, 5, '..try that again from a different starting point');

$rJSON->lastResponse(8); # pretend we just finished s3q2
$rJSON->processExpression('jump { value(s0q0) == 3} NEXT_SECTION');
is($rJSON->nextResponse, 9, '..NEXT_SECTION on the last section is ok, it just ends the survey');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { value(s0q0) == 3} END_SURVEY');
is($rJSON->nextResponse, 9, '..we can also jump to end with END_SURVEY target');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { value(s0q0) == 4} s0; jump { value(s0q0) == 3} s1');
is($rJSON->nextResponse, 3, '..first true statement wins');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { score(s0q0) == 100} s1');
is($rJSON->nextResponse, 3, '..and again when score used');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { score("s0") == 300} s1');
is($rJSON->nextResponse, 3, '..and again when section score total used');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { answered(s0q0) && !answered(ABCDEFG) } s1');
is($rJSON->nextResponse, 3, '..and again when answered() used');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression('jump { value(s0q1_verbatim) eq "So you want to know more" } s1');
is($rJSON->nextResponse, 3, '..and we can access verbatim values');

$rJSON->nextResponse(2); # pretend we just finished s0q2
cmp_deeply($rJSON->tags, {}, 'No tag data');
$rJSON->processExpression('tag(a,100)');
cmp_deeply($rJSON->tags, { a => 100 }, 'Tag data set');
$rJSON->processExpression('tag(b,50); jump {tagged(a) + tagged(b) == 150} s1');

cmp_deeply($rJSON->tags, { a => 100, b => 50 }, 'Tag data cumulative');
is($rJSON->nextResponse, 3, '..and is useful for jump expressions');

# Check multi-answer questions
$rJSON->survey->question([0,2])->{maxAnswers}     = 2; # Make it possible to select both "Yes" and "No" to this Yes/No mc question
$rJSON->survey->answer([0,2,0])->{value} = 4; # set 'Yes' answer score
$rJSON->survey->answer([0,2,0])->{verbatim} = 1;
$rJSON->survey->answer([0,2,1])->{value} = 6; # set 'No' answer score
$rJSON->survey->answer([0,2,1])->{verbatim} = 1;

# Record the next question in section 0
$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->recordResponses({
    '0-2-0' => 'I chose both Yes',
    '0-2-0verbatim' => 'YesYesYes',
    '0-2-1' => '..and No to this mc question',
    '0-2-1verbatim' => 'NoNoNo',
});

is($rJSON->nextResponse, 3, 'nextResponse at 3 (s1q0) after first response');

$rJSON->processExpression(q{jump { value(s0q2) eq '1, 0' } s2});
is($rJSON->nextResponse, 5, 'value() understands multi-answer questions, and knows how to stringify');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression(q{jump { (value(s0q2))[0] == 1 && (value(s0q2))[1] == 0 } s2});
is($rJSON->nextResponse, 5, '..and it can give us a list if thats what we want');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression(q{jump { score(s0q2) == 10 } s2});
is($rJSON->nextResponse, 5, '..and score() knows how to sum multi-answer questions');

$rJSON->nextResponse(2); # pretend we just finished s0q2
$rJSON->processExpression(q{jump { (value(s0q2_verbatim))[0] eq 'YesYesYes' && (value(s0q2_verbatim))[1] eq 'NoNoNo' } s2});
is($rJSON->nextResponse, 5, '..and we can get list of verbatims too');

$rJSON->nextResponse(2); # pretend we just finished s0q2
cmp_deeply($rJSON->processExpression(q{restart()}), { restart => 1 }, 'restart works');
cmp_deeply($rJSON->processExpression(q{exitUrl(blah)}), { exitUrl => 'blah' }, 'explicit exitUrl works');
cmp_deeply($rJSON->processExpression(q{exitUrl()}), { exitUrl => undef }, 'unspecified exitUrl works too');

# Section branching should not happen until all questions in a section have been completed
$rJSON->survey->section([0])->{questionsPerPage} = 2; # Has 3 questions, so first submit will not trigger section-branching
$rJSON->survey->section([0])->{gotoExpression} = q{ tag('not so fast'); };
$rJSON->reset;
$rJSON->recordResponses({
    '0-0-0' => 1,
    '0-1-0' => '13 11 66',
});
cmp_deeply($rJSON->tags, {}, 'No tags yet, section branching should not run yet');
$rJSON->recordResponses({
    '0-2-1' => 1,
});
cmp_deeply($rJSON->tags, { 'not so fast' => 1 }, 'Section branching has now run');

# Clean up after this set of tests
$rJSON->reset;
$rJSON->survey->section([0])->{gotoExpression} = undef;
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);

####################################################
#
# recordResponses
#
####################################################

$rJSON->survey->question([1,0])->{questionType} = 'Multiple Choice';
$rJSON->lastResponse(4);
my $terminals;
is(
    $rJSON->recordResponses({}),
    undef,
    'recordResponses, with no terminal info, returns undef',
);
is($rJSON->lastResponse(), 5, 'recordResponses, increments lastResponse if there are no questions in the section');

$rJSON->survey->section([2])->{terminal}    = 1;
$rJSON->survey->section([2])->{terminalUrl} = '/terminal';

$rJSON->lastResponse(4);
cmp_deeply(
    $rJSON->recordResponses({}),
    { terminal => '/terminal' },
    'recordResponses, if section has no questions, returns terminal info in the section.',
);
is($rJSON->questionsAnswered, 0, 'questionsAnswered=0, no questions answered');

$rJSON->survey->question([1,0])->{terminal}    = 1;
$rJSON->survey->question([1,0])->{terminalUrl} = 'question 1-0 terminal';

$rJSON->lastResponse(2);
$rJSON->survey->answer([1,0,0])->{recordedAnswer} = 1; # Set recordedAnswer

# Check that raw input is recorded for verbatim mc answers
$rJSON->survey->answer([1,0,0])->{verbatim} = 1;
$rJSON->lastResponse(2);
$rJSON->responses({});
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);
$rJSON->recordResponses({
    '1-0comment'    => 'Section 1, question 0 comment',
    '1-0-0'         => 'First answer',
    '1-0-0verbatim' => 'Section 1, question 0, answer 0 verbatim',
});
cmp_deeply(
    $rJSON->responses,
    {
        '1-0'   => {
            comment => 'Section 1, question 0 comment',
        },
        '1-0-0' => {
            'time'    => num(time(), 3),
            value   => 1, # 'recordedAnswer' value used because question is multi-choice
            verbatim => 'Section 1, question 0, answer 0 verbatim',
        },
    },
    'recordResponses: verbatim answer recorded responses correctly'
);


# Repeat with non multi-choice question, to check that submitted answer value is used
# instead of recordedValue
$rJSON->survey->question([1,0])->{questionType} = 'Text';
$rJSON->lastResponse(2);
$rJSON->responses({});
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);
$rJSON->recordResponses({
    '1-0comment'   => 'Section 1, question 0 comment',
    '1-0-0'        => 'First answer',
    '1-0-0verbatim' => 'Section 1, question 0, answer 0 comment',
});
cmp_deeply(
    $rJSON->responses,
    {
        '1-0'   => {
            comment => 'Section 1, question 0 comment',
        },
        '1-0-0' => {
            verbatim => 'Section 1, question 0, answer 0 comment',
            'time'    => num(time(), 3),
            value   => 'First answer', # submitted answer value used this time because non-mc
        },
    },
    'recordResponses: recorded responses correctly, two questions, one answer, comments, values and time'
);
$rJSON->survey->question([1,0])->{questionType} = 'Multiple Choice'; # revert change
$rJSON->survey->answer([1,0,0])->{verbatim} = 0; # revert change

$rJSON->survey->answer([1,0,0])->{terminal}    = 1;
$rJSON->survey->answer([1,0,0])->{terminalUrl} = 'answer 1-0-0 terminal';
$rJSON->responses({});
$rJSON->lastResponse(2);
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);

cmp_deeply(
    $rJSON->recordResponses({
        '1-0comment'   => 'Section 1, question 0 comment',
        '1-0-0'        => 1,
        '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
    }),
    { terminal => 'answer 1-0-0 terminal'},
    'recordResponses: answer terminal overrides section terminals',
);

$rJSON->responses({});
$rJSON->lastResponse(2);
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);
cmp_deeply(
    $rJSON->responses,
    {
#        '1-0'   => {
#            comment => 'Section 1, question 0 comment',
#        },
#        '1-1'   => {
#            comment => undef,
#        }
    },
    'recordResponses: if the answer is all whitespace, it is skipped over'
);
is($rJSON->questionsAnswered, 0, 'question was all whitespace, not answered');

####################################################
#
# pop
#
####################################################
$rJSON->responses({});
$rJSON->lastResponse(2);
is($rJSON->pop, undef, 'pop with no responses returns undef');
cmp_deeply($rJSON->responses, {}, 'initially no responses');
$rJSON->recordResponses({
    '1-0comment'   => 'Section 1, question 0 comment',
    '1-0-0'        => 'First answer',
    '1-1comment'   => 'Section 1, question 1 comment',
    '1-1-0'        => 'Second answer',
    
});
my $popped = $rJSON->pop;
cmp_deeply($popped, {
    # the first q answer
    '1-0-0'        => { 
        value => 1,
        time => num(time(), 3),
    },
    # the second q answer
    '1-1-0'        => { 
        value => 0,
        time => num(time(), 3),
    },
    # the first question comment
    '1-0' => {
        comment   => 'Section 1, question 0 comment',
    },
    # the second question comment
    '1-1' => {
        comment   => 'Section 1, question 1 comment',
    }
}, 'pop removes only existing response');
cmp_deeply($rJSON->responses, {}, 'and now back to no responses');
is($rJSON->pop, undef, 'additional pop has no effect');

$rJSON->responses({});
$rJSON->lastResponse(2);
$rJSON->recordResponses({
    '1-0comment'   => 'Section 1, question 0 comment',
    '1-0-0'        => 'First answer',
    '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
    '1-1comment'   => 'Section 1, question 1 comment',
    '1-1-0'        => 'Second answer',
    '1-1-0comment' => 'Section 1, question 1, answer 0 comment',
});

# fake time so that pop thinks first response happened earlier
$rJSON->responses->{'1-0-0'}->{time} -= 1;
cmp_deeply($rJSON->pop, {
    # the second q answer
    '1-1-0'        => { 
        value => 0,
        time => num(time(), 3),
    },
    # the second question comment
    '1-1' => {
        comment   => 'Section 1, question 1 comment',
    }
}, 'pop now only removes the most recent response');
cmp_deeply($rJSON->responses, {
    # the first q answer
    '1-0-0'        => { 
        value => 1,
        time => num(time(), 3),
    },
    # the first question comment
    '1-0' => {
        comment   => 'Section 1, question 0 comment',
    },
   }, 'and first response left in tact');
cmp_deeply($rJSON->pop, {
    # the first q answer
    '1-0-0'        => { 
        value => 1,
        time => num(time(), 3),
    },
    # the first question comment
    '1-0' => {
        comment   => 'Section 1, question 0 comment',
    },
}, 'second pop removes first response');
cmp_deeply($rJSON->responses, {}, '..and now responses hash empty again');
   
is($rJSON->pop, undef, 'additional pop has no effect');

####################################################
#
# Question Types
#
####################################################
$rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session));

# Use Section 1 (containing 2 questions) for testing. This allows us to test 2 different responses at once.
########
# Country
for my $q (0,1) {
    $rJSON->survey->updateQuestionAnswers([1,$q], 'Country');
    $rJSON->survey->answer([1,$q,0])->{recordedAnswer} = '-';
    $rJSON->survey->answer([1,$q,0])->{verbatim} = 1;
}
$rJSON->reset;
$rJSON->lastResponse(2);
$rJSON->recordResponses( {
    '1-0-0' => 'Australia',
    '1-0-0verbatim' => 'insert witty comment',
    '1-1-0' => 'JTville',
    '1-1-0verbatim' => '',
});
cmp_deeply(
    $rJSON->responses->{'1-0-0'}, 
    {
        'verbatim' => 'insert witty comment',
        'time' => num(time(), 3),
        'value' => 'Australia'
    }, 
    'Valid value recorded correctly'
);
is($rJSON->responses->{'1-1-0'}, undef, 'Invalid country ignored');

########
# Date
for my $q (0,1) {
    $rJSON->survey->updateQuestionAnswers([1,$q], 'Date');
    $rJSON->survey->answer([1,$q,0])->{recordedAnswer} = '-';
    $rJSON->survey->answer([1,$q,0])->{verbatim} = 1;
}
$rJSON->reset;
$rJSON->lastResponse(2);
$rJSON->recordResponses( {
    '1-0-0' => '2009/05/01',
    '1-0-0verbatim' => 'insert witty comment',
    '1-1-0' => '12345',
});
cmp_deeply(
    $rJSON->responses->{'1-0-0'}, 
    {
        'verbatim' => 'insert witty comment',
        'time' => num(time(), 3),
        'value' => '2009/05/01'
    }, 
    'Valid value recorded correctly'
);
# All date input accepted until validation options supported
#is($rJSON->responses->{'1-1-0'}, undef, 'Invalid date ignored');

########
# Number
for my $q (0,1) {
    $rJSON->survey->updateQuestionAnswers([1,$q], 'Number');
    $rJSON->survey->answer([1,$q,0])->{recordedAnswer} = '-';
    $rJSON->survey->answer([1,$q,0])->{verbatim} = 1;
    $rJSON->survey->answer([1,$q,0])->{min} = '-5';
    $rJSON->survey->answer([1,$q,0])->{max} = '10';
}
$rJSON->reset;
$rJSON->lastResponse(2);
$rJSON->recordResponses( {
    '1-0-0' => '-3',
    '1-0-0verbatim' => 'insert witty comment',
    '1-1-0' => '11',
});
cmp_deeply(
    $rJSON->responses->{'1-0-0'}, 
    {
        'verbatim' => 'insert witty comment',
        'time' => num(time(), 3),
        'value' => '-3'
    }, 
    'Valid value recorded correctly'
);
is($rJSON->responses->{'1-1-0'}, undef, 'Invalid number ignored');

########
# Slider
for my $q (0,1) {
    $rJSON->survey->updateQuestionAnswers([1,$q], 'Slider');
    $rJSON->survey->answer([1,$q,0])->{recordedAnswer} = '-';
    $rJSON->survey->answer([1,$q,0])->{verbatim} = 1;
    $rJSON->survey->answer([1,$q,0])->{min} = '-5';
    $rJSON->survey->answer([1,$q,0])->{max} = '10';
    $rJSON->survey->answer([1,$q,0])->{step} = '1';
}
$rJSON->reset;
$rJSON->lastResponse(2);
$rJSON->recordResponses( {
    '1-0-0' => '-3',
    '1-0-0verbatim' => 'insert witty comment',
    '1-1-0' => '11',
});
cmp_deeply(
    $rJSON->responses->{'1-0-0'}, 
    {
        'verbatim' => 'insert witty comment',
        'time' => num(time(), 3),
        'value' => '-3'
    }, 
    'Valid value recorded correctly'
);
is($rJSON->responses->{'1-1-0'}, undef, 'Invalid slider value ignored');

########
# Yes/No
$rJSON->survey->updateQuestionAnswers([1,0], 'Yes/No');
$rJSON->survey->updateQuestionAnswers([1,1], 'Yes/No');
for my $q (0,1) {
    $rJSON->survey->answer([1,$q,0])->{recordedAnswer} = 'Yes';
    $rJSON->survey->answer([1,$q,1])->{recordedAnswer} = 'No';
    $rJSON->survey->answer([1,$q,0])->{verbatim} = 1;
    $rJSON->survey->answer([1,$q,1])->{verbatim} = 1;
}
$rJSON->reset;
$rJSON->lastResponse(2);
$rJSON->recordResponses( {
    '1-0-0' => 1, # Multi-choice answers are submitted like this, 
    '1-0-0verbatim' => 'insert witty comment',
    '1-1-1' => 1, # with the selected answer set to 1
    '1-1-1verbatim' => ' ',
});
cmp_deeply(
    $rJSON->responses->{'1-0-0'}, 
    {
        'verbatim' => 'insert witty comment',
        'time' => num(time(), 3),
        'value' => 'Yes'
    }, 
    'Yes recorded correctly'
);
cmp_deeply(
    $rJSON->responses->{'1-1-1'}, 
    {
        'verbatim' => ' ',
        'time' => num(time(), 3),
        'value' => 'No'
    }, 
    'No recorded correctly'
);

########
# True/False
$rJSON->survey->updateQuestionAnswers([1,0], 'True/False');
$rJSON->survey->updateQuestionAnswers([1,1], 'True/False');
for my $q (0,1) {
    $rJSON->survey->answer([1,$q,0])->{recordedAnswer} = 'True';
    $rJSON->survey->answer([1,$q,1])->{recordedAnswer} = 'False';
    $rJSON->survey->answer([1,$q,0])->{verbatim} = 0;
    $rJSON->survey->answer([1,$q,1])->{verbatim} = 0;
}
$rJSON->reset;
$rJSON->lastResponse(2);
$rJSON->recordResponses( {
    '1-0-0' => 1, # Multi-choice answers are submitted like this, 
    '1-0-0verbatim' => 'will be ignored',
    '1-1-1' => 1, # with the selected answer set to 1
    '1-1-1verbatim' => 'will be ignored',
});
cmp_deeply(
    $rJSON->responses->{'1-0-0'}, 
    {
        'time' => num(time(), 3),
        'value' => 'True'
    }, 
    'True recorded correctly'
);
cmp_deeply(
    $rJSON->responses->{'1-1-1'}, 
    {
        'time' => num(time(), 3),
        'value' => 'False'
    }, 
    'False recorded correctly'
);

####################################################
#
# logical sections
#
####################################################
$rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session));
cmp_deeply(
    $rJSON->surveyOrder,
    [   [ 0, 0, [0] ],                      # S0Q0 (surveyOrder: 0)
        [ 0, 1, [0] ],                      # S0Q1 (surveyOrder: 1)
        [ 0, 2, [ 0, 1 ] ],                 # S0Q2 (surveyOrder: 2)
        [ 1, 0, [ 0, 1 ] ],                 # S1Q0 (surveyOrder: 3)
        [ 1, 1, [ 0, 1 ] ],                 # S1Q1 (surveyOrder: 4)
        [2],                                # S2   (surveyOrder: 5)
        [ 3, 0, [ 0, 1 ] ],                 # S3Q0 (surveyOrder: 6)
        [ 3, 1, [ 0, 1, 2, 3, 4, 5, 6 ] ],  #S3Q1  (surveyOrder: 7)
        [ 3, 2, [0] ],                      #S3Q2  (surveyOrder: 8)
    ], 
    'surveyOrder',
);

$rJSON->survey->section([$_])->{gotoExpression} = qq{tag('tagged at s$_')} for (0..3);
$rJSON->survey->section([$_])->{variable} = "S$_" for (0..3);
$rJSON->survey->answer([0,2,1])->{goto} = 'S2';

# Submit section 0, should fall through to section 2 because section 1 is logical
# If we submit S0 normally, nextResponse will be 3 (S1 / S1Q0)
$rJSON->recordResponses( {
    '0-0-0' => 'me@email.com',
    '0-1-0' => 'my phone',
    '0-2-0' => 1,
});
is($rJSON->nextResponse, 3, 'Natural progression');

# However if S1 is logical, nextResponse will be 5 (S2)
$rJSON->reset;
$rJSON->survey->section([1])->{logical} = 1;

$rJSON->recordResponses( {
    '0-0-0' => 'me@email.com',
    '0-1-0' => 'my phone',
    '0-2-0' => 1,
});
is($rJSON->nextResponse, 5, 'Logical section processed automatically');
cmp_deeply($rJSON->tags, { 'tagged at s0' => 1, 'tagged at s1' => 1,  }, 'Logical section gotoExpression can still tag data');
$rJSON->survey->section([1])->{logical} = 0;

# Check behaviour when first section is logical
$rJSON->reset;
cmp_deeply( [ $rJSON->nextQuestions ],
    [ 
        superhashof( { id => '0-0' } ), 
        superhashof( { id => '0-1' } ), 
        superhashof( { id => '0-2' } ),
    ], 
    'Normally nextQuestions returns all questions in first section' 
);
$rJSON->survey->section([0])->{logical} = 1;
$rJSON->reset;
cmp_deeply( [ $rJSON->nextQuestions ],
    [ 
        superhashof( { id => '1-0' } ), 
        superhashof( { id => '1-1' } ), 
    ], 
    '..but when first section logical, second section questions returned instead' 
);
cmp_deeply($rJSON->tags, { 'tagged at s0' => 1 }, '..and s0 gotoExpression was run');

# Check behaviour when all sections logical
$rJSON->survey->section([$_])->{logical} = 1 for (0..3);
$rJSON->reset;
cmp_deeply($rJSON->tags, 
    { 
        'tagged at s0' => 1,
        'tagged at s1' => 1,
        'tagged at s2' => 1,
        'tagged at s3' => 1,
    }, 
    '..all gotoExpressions run'
);
$rJSON->survey->section([$_])->{logical} = 0 for (0..3);

# Check that we can jump to a logical section
$rJSON->survey->section([2])->{logical} = 1;
$rJSON->reset;
$rJSON->recordResponses( {
    '0-0-0' => 'me@email.com',
    '0-1-0' => 'my phone',
    '0-2-1' => 1, # goto -> S2
});
is($rJSON->nextResponse, 6, 'S2 processed automatically and we land as S3');

}

####################################################
#
# Utility test routines
#
####################################################

sub buildSurveyJSON {
    my $session = shift;
    my $sjson = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session);
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
    $sjson->updateQuestionAnswers([0,1], 'Phone Number');
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
