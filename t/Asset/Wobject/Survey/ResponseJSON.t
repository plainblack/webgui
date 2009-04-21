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
my $tests = 74;
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
cmp_ok((abs$responseJSON->startTime - $newTime), '<=', 2, 'new: by default startTime set to time');
is_deeply( $responseJSON->responses, {}, 'new: by default, responses is an empty hashref');

my $now = time();
my $rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session), qq!{ "startTime": $now }!);
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
# initSurveyOrder
#
####################################################

$rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(buildSurveyJSON($session), q!{}!);

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

$rJSON->lastResponse(0);
$rJSON->processGoto('goto 80');
is($rJSON->lastResponse(), 0, 'goto: no change in lastResponse if the variable cannot be found');
$rJSON->processGoto('goto 1');
is($rJSON->lastResponse(), 2, 'goto: works on existing section');
$rJSON->processGoto('goto 0-1');
is($rJSON->lastResponse(), 0, 'goto: works on existing question');
$rJSON->processGoto('goto 3-0');
is($rJSON->lastResponse(), 5, 'goto: finds first if there are duplicates');

####################################################
#
# responseScoresByVariableName
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
cmp_deeply($rJSON->responseScoresByVariableName, {}, 'scores initially empty');

$rJSON->lastResponse(2);
$rJSON->recordResponses({
    '1-0-0'        => 'My chosen answer',
    '1-1-0'        => 'My chosen answer',
});
cmp_deeply($rJSON->responseScoresByVariableName, { s1q0 => 100, s1q1 => 200, s1 => 300}, 'scores now reflect q answers and section totals');

####################################################
#
# processGotoExpression
#
####################################################
# Turn on the survey Expression Engine
WebGUI::Test->originalConfig('enableSurveyExpressionEngine');
$session->config->set('enableSurveyExpressionEngine', 1);
$rJSON->survey->section([0])->{variable} = 's0'; # our first test jump target
$rJSON->survey->section([2])->{variable} = 's2'; # our second test jump target
$rJSON->survey->question([1,0])->{variable} = 's1q0'; # a question variable to use in our expressions
$rJSON->survey->answer([1,0,0])->{recordedAnswer} = 3; # value recorded in responses hash for multi-choice answer

$rJSON->lastResponse(2);
$rJSON->recordResponses({
    '1-0comment'   => 'Section 1, question 0 comment',
    '1-0-0'        => 'My chosen answer',
    '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
});
is($rJSON->lastResponse, 4, 'lastResponse at 4 before any gotoExpressions processed');

$rJSON->processGotoExpression('blah-dee-blah-blah {');
is($rJSON->lastResponse, 4, '..unchanged after duff expression');

$rJSON->processGotoExpression('jump { value(s1q0) == 4} s0');
is($rJSON->lastResponse, 4, '..unchanged after false expression');

$rJSON->processGotoExpression('jump { value(s1q0) == 4} s0; jump { value(s1q0) == 5} s0;');
is($rJSON->lastResponse, 4, '..similarly for multi-statement false expression');

$rJSON->processGotoExpression('jump { value(s1q0) == 3} DUFF_TARGET');
is($rJSON->lastResponse, 4, '..similarly for expression with invalid target');

$rJSON->processGotoExpression('jump { value(s1q0) == 3} s0');
is($rJSON->lastResponse, -1, '..but updated to s0 after true expression');

$rJSON->processGotoExpression('jump { value(s1q0) == 4} s0; jump { value(s1q0) == 3} s2');
is($rJSON->lastResponse, 4, '..changed again for multi-statement true expression');

$rJSON->processGotoExpression('jump { score(s1q0) == 100} s0');
is($rJSON->lastResponse, -1, '..and again when score used');

$rJSON->processGotoExpression('jump { score("s1") == 300} s2');
is($rJSON->lastResponse, 4, '..and again when section score total used');

$rJSON->responses({});
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);

####################################################
#
# recordedNamedResponses (coming soon)
#
####################################################
#    {
#
#        #    $rJSON->survey->question([1,0])->{questionType} = 'Multiple Choice';
#        #    $rJSON->survey->answer([1,0,0])->{value} = 5;
#        #    cmp_deeply($rJSON->recordedNamedResponses, {}, 'recordedNamedResponses initially empty');
#        #    $rJSON->lastResponse(2);
#        #    $rJSON->recordResponses({
#        #        '1-0comment'   => 'Section 1, question 0 comment',
#        #        '1-0-0'        => 'My chosen answer',
#        #        '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
#        #    });
#        #    cmp_deeply($rJSON->recordedNamedResponses, { s1q0 => 5 }, '..now shows multi-choice answer value');
#        #    $rJSON->survey->answer([1,0,0])->{value} = 'blah';
#        #    cmp_deeply($rJSON->recordedNamedResponses, { s1q0 => 'blah' }, '..also works with string value');
#        #    $rJSON->survey->loadTypes;
#        #    my $a =
#        #    diag(Dumper ($rJSON->survey->multipleChoiceTypes));
#        
#        $rJSON->survey->question([1,0])->{variable} = 's1q0';
#
#        # First try with generic Multi Choice
#        $rJSON->survey->question( [ 1, 0 ] )->{questionType} = 'Multiple Choice';
#        $rJSON->survey->answer( [ 1, 0, 0 ] )->{recordedAnswer} = 'My recordedAnswer';
#        $rJSON->lastResponse(2);
#        $rJSON->recordResponses( { '1-0-0' => 'My chosen answer', } );
#        is( $rJSON->responses->{'1-0-0'}->{value}, 'My recordedAnswer', 'Multi-choice uses recordedAnswer' );
#
#        # Then with Yes/No bundle
#        $rJSON->survey->question( [ 1, 0 ] )->{questionType} = 'Yes/No';
#        $rJSON->lastResponse(2);
#        $rJSON->recordResponses( { '1-0-0' => 'My chosen answer', } );
#        is( $rJSON->responses->{'1-0-0'}->{value}, 'My recordedAnswer', 'Multi-choice bundle also uses recordedAnswer' );
#
#        # Then with Text
#        $rJSON->survey->question( [ 1, 0 ] )->{questionType} = 'Text';
#        $rJSON->lastResponse(2);
#        $rJSON->recordResponses( { '1-0-0' => 'My entered text', } );
#        is( $rJSON->responses->{'1-0-0'}->{value}, 'My entered text', 'Text type uses entered text' );
#        diag( Dumper( $rJSON->responses ) );
#        diag( Dumper( $rJSON->recordedNamedResponses ) );
#    }

####################################################
#
# recordResponses
#
####################################################

$rJSON->survey->question([1,0])->{questionType} = 'Multiple Choice';
$rJSON->lastResponse(4);
my $terminals;
cmp_deeply(
    $rJSON->recordResponses({}),
    [ 0, undef ],
    'recordResponses, if section has no questions, returns terminal info in the section.  With no terminal info, returns [0, undef]',
);
is($rJSON->lastResponse(), 5, 'recordResponses, increments lastResponse if there are no questions in the section');

$rJSON->survey->section([2])->{terminal}    = 1;
$rJSON->survey->section([2])->{terminalUrl} = '/terminal';

$rJSON->lastResponse(4);
cmp_deeply(
    $rJSON->recordResponses({}),
    [ 1, '/terminal' ],
    'recordResponses, if section has no questions, returns terminal info in the section.',
);
is($rJSON->questionsAnswered, 0, 'questionsAnswered=0, no questions answered');

$rJSON->survey->question([1,0])->{terminal}    = 1;
$rJSON->survey->question([1,0])->{terminalUrl} = 'question 1-0 terminal';

$rJSON->lastResponse(2);
$rJSON->survey->answer([1,0,0])->{recordedAnswer} = 1; # Set recordedAnswer
cmp_deeply(
    $rJSON->recordResponses({
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
            value   => 1, # 'recordedAnswer' value used because question is multi-choice
        },
        '1-1'   => {
            comment => undef,
        }
    },
    'recordResponses: recorded responses correctly, two questions, one answer, comments, values and time'
);


# Repeat with non multi-choice question, to check that submitted answer value is used
# instead of recordedValue
$rJSON->survey->question([1,0])->{questionType} = 'Text';
$rJSON->lastResponse(2);
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);
$rJSON->recordResponses({
    '1-0comment'   => 'Section 1, question 0 comment',
    '1-0-0'        => 'First answer',
    '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
});
cmp_deeply(
    $rJSON->responses,
    {
        '1-0'   => {
            comment => 'Section 1, question 0 comment',
        },
        '1-0-0' => {
            comment => 'Section 1, question 0, answer 0 comment',
            'time'    => num(time(), 3),
            value   => 'First answer', # submitted answer value used this time because non-mc
        },
        '1-1'   => {
            comment => undef,
        }
    },
    'recordResponses: recorded responses correctly, two questions, one answer, comments, values and time'
);
$rJSON->survey->question([1,0])->{questionType} = 'Multiple Choice'; # revert change

$rJSON->survey->question([1,0,0])->{terminal}    = 1;
$rJSON->survey->question([1,0,0])->{terminalUrl} = 'answer 1-0-0 terminal';
$rJSON->responses({});
$rJSON->lastResponse(2);
$rJSON->questionsAnswered(-1 * $rJSON->questionsAnswered);

cmp_deeply(
    $rJSON->recordResponses({
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
    '1-0-0comment' => 'Section 1, question 0, answer 0 comment',
    '1-1comment'   => 'Section 1, question 1 comment',
    '1-1-0'        => 'Second answer',
    '1-1-0comment' => 'Section 1, question 1, answer 0 comment',
    
});
my $popped = $rJSON->pop;
cmp_deeply($popped, {
    # the first q answer
    '1-0-0'        => { 
        value => 1,
        comment => 'Section 1, question 0, answer 0 comment',
        time => num(time(), 3),
    },
    # the second q answer
    '1-1-0'        => { 
        value => 0,
        comment => 'Section 1, question 1, answer 0 comment',
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
        comment => 'Section 1, question 1, answer 0 comment',
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
        comment => 'Section 1, question 0, answer 0 comment',
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
        comment => 'Section 1, question 0, answer 0 comment',
        time => num(time(), 3),
    },
    # the first question comment
    '1-0' => {
        comment   => 'Section 1, question 0 comment',
    },
}, 'second pop removes first response');
cmp_deeply($rJSON->responses, {}, '..and now responses hash empty again');
   
is($rJSON->pop, undef, 'additional pop has no effect');

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
