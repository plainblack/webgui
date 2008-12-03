# Tests WebGUI::Asset::Wobject::Survey::SurveyJSON
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
use JSON;
use Clone qw/clone/;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 33;
plan tests => $tests + 1 + 3;

#----------------------------------------------------------------------------
# put your tests here


####################################################
#
# buildSectionSkeleton
# Test this test's helper routine for building skeletal
# section/question/answer data structures
#
####################################################

cmp_deeply(
    buildSectionSkeleton( [ [], [], ] ),
    [
        superhashof({
            type      => 'section',
            questions => [],
        }),
        superhashof({
            type      => 'section',
            questions => [],
        }),
    ],
    'buildSectionSkeleton: Two sections'
);

cmp_deeply(
    buildSectionSkeleton( [ [0], [], [], ] ),
    [
        superhashof({
            type      => 'section',
            questions => [
                superhashof({
                    type      => 'question',
                    answers => [],
                }),
            ],
        }),
        superhashof({
            type      => 'section',
            questions => [],
        }),
        superhashof({
            type      => 'section',
            questions => [],
        }),
    ],
    'buildSectionSkeleton: Two sections'
);

cmp_deeply(
    buildSectionSkeleton( [ [0,0], [1], [], ] ),
    [
        superhashof({
            type      => 'section',
            questions => [
                superhashof({
                    type      => 'question',
                    answers => [],
                }),
                superhashof({
                    type      => 'question',
                    answers => [],
                }),
            ],
        }),
        superhashof({
            type      => 'section',
            questions => [
                superhashof({
                    type      => 'question',
                    answers => [
                        superhashof({
                            type      => 'answer',
                        }),
                    ],
                }),
            ],
        }),
        superhashof({
            type      => 'section',
            questions => [],
        }),
    ],
    'buildSectionSkeleton: Two sections'
);


my $usedOk = use_ok('WebGUI::Asset::Wobject::Survey::SurveyJSON');
my ($surveyJSON);

SKIP: {

skip $tests, "Unable to load SurveyJSON" unless $usedOk;

####################################################
#
# new, part 1
#
####################################################

$surveyJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new('{}', $session->log);
isa_ok($surveyJSON, 'WebGUI::Asset::Wobject::Survey::SurveyJSON');

####################################################
#
# log
#
####################################################

WebGUI::Test->interceptLogging;

my $logger = $surveyJSON->log("Everyone in here is innocent");
is ($WebGUI::Test::logger_warns, undef, 'Did not log a warn');
is ($WebGUI::Test::logger_info,  undef, 'Did not log an info');
is ($WebGUI::Test::logger_error, "Everyone in here is innocent", 'Logged an error');

####################################################
#
# newSection, newQuestion, newAnswer
#
####################################################

my ($bareSection, $bareQuestion, $bareAnswer) = getBareSkeletons();

cmp_deeply(
    $surveyJSON->newSection(),
    $bareSection,
    'newSection data structure is okay'
);

cmp_deeply(
    $surveyJSON->newQuestion(),
    $bareQuestion,
    'newQuestion data structure is okay'
);

cmp_deeply(
    $surveyJSON->newAnswer(),
    $bareAnswer,
    'newAnswer data structure is okay'
);

####################################################
#
# new, part 2
#
####################################################

cmp_deeply(
    $surveyJSON->sections,
    [
        $surveyJSON->newSection,
    ],
    'new: empty JSON in constructor causes 1 new, default section to be created',
);

$surveyJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new(
    '{ "sections" : [], "survey" : {} }',
    $session->log,
);

cmp_deeply(
    $surveyJSON->sections,
    [
        $surveyJSON->newSection,
    ],
    'new: Always creates 1 section, if none is provided in the initial JSON string',
);

####################################################
#
# freeze
#
####################################################

like( $surveyJSON->freeze, qr/"survey":\{\}/, 'freeze: got back something that looks like JSON, not a thorough check');

####################################################
#
# newObject
#
####################################################

my $stompedAddress = [];
is_deeply($surveyJSON->newObject($stompedAddress), [1], 'newObject returns the new data structure index');
is_deeply($stompedAddress, [1], 'newObject stomps on $address');

cmp_deeply(
    $surveyJSON->sections,
    buildSectionSkeleton([ [], [] ,]),
    'newObject: Added one empty section'
);

is_deeply($surveyJSON->newObject([]), [2], 'newObject-2 returns the new data structure index');

cmp_deeply(
    $surveyJSON->sections,
    buildSectionSkeleton([ [], [], [], ]),
    'newObject: Added another empty section'
);

$stompedAddress = [1];
is_deeply($surveyJSON->newObject($stompedAddress), [1, 0], 'newObject-3 returns the new data structure index');
is_deeply($stompedAddress, [1, 0], 'newObject stomps on the address argument if it is not empty');

cmp_deeply(
    $surveyJSON->sections,
    buildSectionSkeleton([ [], [0], [], ]),
    'newObject: Added a question to the 2nd section'
);

is_deeply($surveyJSON->newObject([1]), [1, 1], 'newObject-4 returns the new data structure index');

cmp_deeply(
    $surveyJSON->sections,
    buildSectionSkeleton([ [], [0,0], [], ]),
    'newObject: Added another question to the 2nd section'
);

is_deeply($surveyJSON->newObject([1,1]), [1, 1, 0], 'newObject-5 returns the new data structure index');

cmp_deeply(
    $surveyJSON->sections,
    buildSectionSkeleton([ [], [0,1], [], ]),
    'newObject: Added an answer to the 2nd question in the 2nd section'
);

####################################################
#
# insertObject, section
#
####################################################

$surveyJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new('{}', $session->log);
{
    my $section = $surveyJSON->section([0]);
    $section->{title} = 'Section 0';
}
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [],
        },
    ],
    'insertObject: Set the title for the default section'
);

{
    my $section = $surveyJSON->newSection;
    $section->{title} = 'Section 1';
    $surveyJSON->insertObject($section, [0]);
}
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [],
        },
        {
            title     => 'Section 1',
            questions => [],
        },
    ],
    'insertObject: Insert a new section after the default section'
);

{
    my $section = $surveyJSON->newSection;
    $section->{title} = 'Section 0+';
    $surveyJSON->insertObject($section, [0]);
}
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [],
        },
        {
            title     => 'Section 0+',
            questions => [],
        },
        {
            title     => 'Section 1',
            questions => [],
        },
    ],
    'insertObject: Insert another new section after the default section'
);

{
    my $question = $surveyJSON->newQuestion;
    $question->{text} = 'Question 0-0';
    $surveyJSON->insertObject($question, [0,0]);
}
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                {
                    text    => 'Question 0-0',
                    answers => [],
                }
            ],
        },
        {
            title     => 'Section 0+',
            questions => [],
        },
        {
            title     => 'Section 1',
            questions => [],
        },
    ],
    'insertObject: Insert a question into the first section'
);

{
    my $question = $surveyJSON->newQuestion;
    $question->{text} = 'Question 0-1';
    $surveyJSON->insertObject($question, [0,0]);
    my $question1 = $surveyJSON->newQuestion;
    $question1->{text} = 'Question 0-2';
    $surveyJSON->insertObject($question1, [0,1]);
    my $question2 = $surveyJSON->newQuestion;
    $question2->{text} = 'Question 0+-0';
    $surveyJSON->insertObject($question2, [1,0]);
    my $answer1 = $surveyJSON->newAnswer;
    $answer1->{text} = 'Answer 0-1-0';
    $surveyJSON->insertObject($answer1, [0,1,0]);
    my $answer2 = $surveyJSON->newAnswer;
    $answer2->{text} = 'Answer 0-1-1';
    $surveyJSON->insertObject($answer2, [0,1,0]);
    my $answer3 = $surveyJSON->newAnswer;
    $answer3->{text} = 'Answer 0-1-2';
    $surveyJSON->insertObject($answer3, [0,1,1]);
}
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                {
                    text    => 'Question 0-0',
                    answers => [],
                },
                {
                    text    => 'Question 0-1',
                    answers => [
                        {
                            text    => 'Answer 0-1-0',
                        },
                        {
                            text    => 'Answer 0-1-1',
                        },
                        {
                            text    => 'Answer 0-1-2',
                        },
                    ],
                },
                {
                    text    => 'Question 0-2',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 0+',
            questions => [
                {
                    text    => 'Question 0+-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [],
        },
    ],
    'insertObject: Adding questions and answers'
);

####################################################
#
# getObject, update, remove
#
####################################################

my $section1 = $surveyJSON->getObject([2]);

cmp_deeply(
    $section1,
    superhashof({
        type  => 'section',
        title => 'Section 1',
    }),
    'getObject: Retrieved correct section'
);

##Try a reference stomp
$section1->{title} = 'Section 2';
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                {
                    text    => 'Question 0-0',
                    answers => [],
                },
                {
                    text    => 'Question 0-1',
                    answers => [
                        {
                            text    => 'Answer 0-1-0',
                        },
                        {
                            text    => 'Answer 0-1-1',
                        },
                        {
                            text    => 'Answer 0-1-2',
                        },
                    ],
                },
                {
                    text    => 'Question 0-2',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 0+',
            questions => [
                {
                    text    => 'Question 0+-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [],
        },
    ],
    'getObject: Returns safe, cloned references'
);

##Propertly update a section
{
    my $section = $surveyJSON->getObject([1]);
    $section->{title} = 'Section 1';
    $surveyJSON->update([1], $section );
}
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                {
                    text    => 'Question 0-0',
                    answers => [],
                },
                {
                    text    => 'Question 0-1',
                    answers => [
                        {
                            text    => 'Answer 0-1-0',
                        },
                        {
                            text    => 'Answer 0-1-1',
                        },
                        {
                            text    => 'Answer 0-1-2',
                        },
                    ],
                },
                {
                    text    => 'Question 0-2',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                {
                    text    => 'Question 0+-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [],
        },
    ],
    'Update: updated a section'
);

my $question1 = $surveyJSON->getObject([1, 0]);

cmp_deeply(
    $question1,
    superhashof({
        type => 'question',
        text => 'Question 0+-0',
    }),
    'getObject: Retrieved correct question'
);

$question1->{text} = 'Question 1-0';
$surveyJSON->update([1, 0], $question1 );

cmp_deeply(
    $surveyJSON->getObject([1, 0]),
    superhashof({
        type => 'question',
        text => 'Question 1-0',
        answers => [
        ],
    }),
    'update: updating a question adds a new, default answer?'
);

$surveyJSON->remove([1, 0, 0]),
cmp_deeply(
    $surveyJSON->getObject([1, 0]),
    superhashof({
        type => 'question',
        text => 'Question 1-0',
        answers => [
        ],
    }),
    'remove: No problems with removing nonexistant data'
);


####################################################
#
# TODO
#
####################################################

# To try to bust the data object
# Create a section, put questions in it.
# Copy the section, then alter one question in it.  It should
# alter the original since it is a reference.

}

# Go through a JSON survey type data structure and just grab some unique
# elements

sub summarizeSectionSkeleton {
    my ($skeleton) = @_;
    my $summary = [];
    foreach my $section (@{ $skeleton->{sections} }) {
        my $summarySection = {
            title     => $section->{title},
            questions => [],
        };
        foreach my $question ( @{ $section->{questions} } ) {
            my $summaryQuestion = {
                text   => $question->{text},
                answers => [],
            };
            foreach my $answer ( @{ $question->{answers} } ) {
                my $summaryAnswer = {
                    text => $answer->{text},
                };
                push @{ $summaryQuestion->{answers} }, $summaryAnswer;
            }
            push @{ $summarySection->{questions} }, $summaryQuestion;
        }
        push @{ $summary }, $summarySection;
    }
    return $summary;
}

#  [
#      [0,1,1], # A section with three questions, no answer, 1 answer, 1 answer
#      [4],     # A section with 1 question with 4 answers
#  ]

sub buildSectionSkeleton {
    my ($spec) = @_;
    my $sections = [];
    my ($bareSection, $bareQuestion, $bareAnswer) = getBareSkeletons();
    foreach my $questionSpec ( @{ $spec } ) {
        my $section = clone $bareSection;
        push @{ $sections }, $section;
        foreach my $answers ( @{$questionSpec} ) {
            my $question = clone $bareQuestion;
            push @{ $section->{questions} }, $question;
            while ($answers-- > 0) {
                my $answer = clone $bareAnswer;
                push @{ $question->{answers} }, $answer;
            }
        }
    }
    return $sections;
}

sub getBareSkeletons {
    return
        {
           text                   => '',
           title                  => 'NEW SECTION',
           variable               => '',
           questionsPerPage       => 5,
           questionsOnSectionPage => 1,
           randomizeQuestions     => 0,
           everyPageTitle         => 1,
           everyPageText          => 1,
           terminal               => 0,
           terminalUrl            => '',
           goto                   => '',
           timeLimit              => 0,
           type                   => 'section',
           questions              => [],
        },
        {
           text                   => '',
           variable               => '',
           allowComment           => 0,
           commentCols            => 10,
           commentRows            => 5,
           randomizeAnswers       => 0,
           questionType           => 'Multiple Choice',
           randomWords            => '',
           verticalDisplay        => 0,
           required               => 0,
           maxAnswers             => 1,
           value                  => 1,
           textInButton           => 0,
           type                   => 'question',
           answers                => [],
        },
        {
           text                   => '',
           verbatim               => 0,
           textCols               => 10,
           textRows               => 5,
           goto                   => '',
           recordedAnswer         => '',
           isCorrect              => 1,
           min                    => 1,
           max                    => 10,
           step                   => 1,
           value                  => 1,
           terminal               => 0,
           terminalUrl            => '',
           type                   => 'answer',
        };
}

#----------------------------------------------------------------------------
# Cleanup
END { }
