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
my $tests = 22;
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
is_deeply($stompedAddress, [], 'newObject does not stomp on the address argument if it is empty');

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
# TODO
#
####################################################

# To try to bust the data object
# Create a section, put questions in it.
# Copy the section, then alter one question in it.  It should
# alter the original since it is a reference.

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
