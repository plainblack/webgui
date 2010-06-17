# Tests WebGUI::Asset::Wobject::Survey::SurveyJSON
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use Test::Exception;
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
my $tests = 140;
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

$surveyJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, '{}');
isa_ok($surveyJSON, 'WebGUI::Asset::Wobject::Survey::SurveyJSON');

my $sJSON2 = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session);
isa_ok($sJSON2, 'WebGUI::Asset::Wobject::Survey::SurveyJSON', 'even with absolutely no JSON');
undef $sJSON2;

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
# freeze, compress, uncompress
#
####################################################
{
my $sJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session);
my $mold = { 
        answer => $sJSON->newAnswer,
        question => $sJSON->newQuestion,
        section => $sJSON->newSection,
    };
cmp_deeply(from_json($sJSON->freeze), {
    sections => [ {} ],
    mold => $mold,
    }, 'got back appropriate frozen object for empty survey');

# Set a few non-standard properties on the (default) 0th Section
my $nonStandardSProps = { variable => 'S0', logical => '0 but true' };
$sJSON->update( [0], $nonStandardSProps );

# Create a question, and set some other non-standard properties
$sJSON->newObject( [0] );
my $nonStandardQProps = { randomizeAnswers => 1, textInButton => '1', text => 'blah' };
$sJSON->update( [0, 0], $nonStandardQProps );

# And create an answer
$sJSON->updateQuestionAnswers( [0], 'Country' );
$nonStandardQProps->{questionType} = 'Country';
my $nonStandardAProps = { value => 0, terminal => '' };
$sJSON->update( [0, 0, 0], $nonStandardAProps );

$nonStandardSProps->{questions} = [$nonStandardQProps];
$nonStandardQProps->{answers} = [$nonStandardAProps];
cmp_deeply(from_json($sJSON->freeze)->{sections}, $sJSON->compress, 'freeze returns sections via compress');
cmp_deeply($sJSON->compress, [$nonStandardSProps], 'molded data only contains non-standard properties');

cmp_deeply($sJSON->uncompress($sJSON->compress), $sJSON->{_sections}, 'uncompress completes the round-trip');
}

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

$surveyJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, 
    '{ "sections" : [], "survey" : {} }',
);

cmp_deeply(
    $surveyJSON->sections,
    [
        $surveyJSON->newSection,
    ],
    'new: Always creates 1 section, if none is provided in the initial JSON string',
);

lives_ok
    {
        my $foo = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, 
            encode_json({survey => "on 16\x{201d}" }),
        );
    }
    'new handles wide characters';

$sJSON2 = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, 
    '{ "sections" : [ { "type" : "section" } ], "survey" : {} }',
);

cmp_deeply(
    $sJSON2->sections,
    [
        superhashof {
            type => 'section',
            logical => 0, # this is added from the default-created mold
        },
    ],
    'new: If the JSON has a section, a new one will not be added (but mold defaults will be)',
);

undef $sJSON2;

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

$surveyJSON = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, '{}');
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
        type      => 'section',
        title     => 'Section 1',
        questions => [],
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
##Update the title to make it clearer.
$surveyJSON->section([2])->{title} = 'Section 2';
##And give it a question
$surveyJSON->newObject([2]);
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                { text    => 'Question 0-0', answers => [], },
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
                { text    => 'Question 0-2', answers => [], },
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
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
    ],
    'Update: updated a section'
);

my $question1 = $surveyJSON->getObject([1, 0]);

cmp_deeply(
    $question1,
    superhashof({
        type    => 'question',
        text    => 'Question 0+-0',
        answers => [],
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
    'update: updating a question properly'
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

$surveyJSON->remove([0, 1, 2]),
cmp_deeply(
    $surveyJSON->getObject([0, 1]),
    superhashof({
        type => 'question',
        text => 'Question 0-1',
        answers => [
            superhashof({
                type => 'answer',
                text => 'Answer 0-1-0',
            }),
            superhashof({
                type => 'answer',
                text => 'Answer 0-1-1',
            }),
        ],
    }),
    'remove: Remove an answer'
);

$surveyJSON->remove([0]),
cmp_deeply(
    $surveyJSON->getObject([0]),
    superhashof({
        type  => 'section',
        title => 'Section 0',
    }),
    'remove: Cannot remove the first section, by default'
);

my $sectionAddress = $surveyJSON->newObject([]);

cmp_deeply(
    $surveyJSON->sections,
    [
        superhashof({
            type      => 'section',
            title     => 'Section 0',
            questions => ignore(),
        }),
        superhashof({
            type      => 'section',
            title     => 'Section 1',
            questions => ignore(),
        }),
        superhashof({
            type      => 'section',
            title     => 'Section 2',
            questions => ignore(),
        }),
        superhashof({
            type      => 'section',
            title     => 'NEW SECTION',
            questions => ignore(),
        }),
    ],
    'Added new section for testing remove'
);

$surveyJSON->remove($sectionAddress),
cmp_deeply(
    $surveyJSON->sections,
    [
        superhashof({
            type      => 'section',
            title     => 'Section 0',
            questions => ignore(),
        }),
        superhashof({
            type      => 'section',
            title     => 'Section 1',
            questions => ignore(),
        }),
        superhashof({
            type      => 'section',
            title     => 'Section 2',
            questions => ignore(),
        }),
    ],
    'remove: Removed a section'
);


$surveyJSON->newObject([2]);
cmp_deeply(
    $surveyJSON->getObject([2]),
    #$surveyJSON->section([2]),
    superhashof({
        title => 'Section 2',
        type  => 'section',
        questions => [
            superhashof({
                text => '',
                type => 'question',
            }),
            superhashof({
                text => '',
                type => 'question',
            }),
        ],
    }),
    'Added a question to section 2 to test removing it'
);

$surveyJSON->remove([2,0]);
cmp_deeply(
    $surveyJSON->getObject([2]),
    superhashof({
        title => 'Section 2',
        type  => 'section',
        questions => [
            superhashof({
                text => '',
                type => 'question',
            }),
        ],
    }),
    'remove: removed a question'
);

####################################################
#
# copy
#
####################################################

##Test return value, and stomped address
$stompedAddress = [0, 1];
my $returnedAddress = $surveyJSON->copy($stompedAddress);
is_deeply($returnedAddress, [0, 3], 'Added a question');
is_deeply($stompedAddress,  [0, 3], 'copy writes to the reference when copying a question');
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
                    ],
                },
                {
                    text    => 'Question 0-2',
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
                    ],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                {
                    text    => 'Question 1-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
    ],
    'copy: copied a question with answers'
);

##Test that copy handles references correctly
$surveyJSON->answer([0,3,0])->{text} = 'Answer 0-3-0';
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
                    ],
                },
                {
                    text    => 'Question 0-2',
                    answers => [],
                },
                {
                    text    => 'Question 0-1',
                    answers => [
                        {
                            text    => 'Answer 0-3-0',
                        },
                        {
                            text    => 'Answer 0-1-1',
                        },
                    ],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                {
                    text    => 'Question 1-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
    ],
    'copy: copies safe references for a question'
);

##Now, try a section copy.
$stompedAddress = [1];
$returnedAddress = $surveyJSON->copy($stompedAddress);
is_deeply($returnedAddress, [3], 'Added a section');
is_deeply($stompedAddress,  [3], 'copy writes to the reference when copying a section');
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
                    ],
                },
                {
                    text    => 'Question 0-2',
                    answers => [],
                },
                {
                    text    => 'Question 0-1',
                    answers => [
                        {
                            text    => 'Answer 0-3-0',
                        },
                        {
                            text    => 'Answer 0-1-1',
                        },
                    ],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                {
                    text    => 'Question 1-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                {
                    text    => 'Question 1-0',
                    answers => [],
                },
            ],
        },
    ],
    'copy: copied a section'
);

$surveyJSON->question([3,0])->{text} = 'Question 3-0';
$surveyJSON->section([3])->{title} = 'Section 3';
cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                { text    => 'Question 0-0', answers => [], },
                {
                    text    => 'Question 0-1',
                    answers => [
                        { text    => 'Answer 0-1-0', },
                        { text    => 'Answer 0-1-1', },
                    ],
                },
                { text    => 'Question 0-2', answers => [], },
                {
                    text    => 'Question 0-1',
                    answers => [
                        { text    => 'Answer 0-3-0', },
                        { text    => 'Answer 0-1-1', },
                    ],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                { text    => 'Question 1-0', answers => [], },
            ],
        },
        {
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 3',
            questions => [
                { text    => 'Question 3-0', answers => [], },
            ],
        },
    ],
    'copy: safe copy of a section'
);

##Finish renaming copied sections for sane downstream testing

$surveyJSON->question([0, 3])->{text} = 'Question 0-3';
$surveyJSON->answer([0, 3, 1])->{text} = 'Answer 0-3-1';

##Now, try copying the last section.
$surveyJSON->copy([3]);
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
                    ],
                },
                {
                    text    => 'Question 0-2',
                    answers => [],
                },
                {
                    text    => 'Question 0-3',
                    answers => [
                        {
                            text    => 'Answer 0-3-0',
                        },
                        {
                            text    => 'Answer 0-3-1',
                        },
                    ],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                {
                    text    => 'Question 1-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 3',
            questions => [
                {
                    text    => 'Question 3-0',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 3',
            questions => [
                {
                    text    => 'Question 3-0',
                    answers => [],
                },
            ],
        },
    ],
    'copy: copied last section'
);

$surveyJSON->remove([4]);

cmp_deeply(
    summarizeSectionSkeleton($surveyJSON),
    [
        {
            title     => 'Section 0',
            questions => [
                {
                    text    => 'Question 0-0', answers => [],
                },
                {
                    text    => 'Question 0-1',
                    answers => [
                        { text    => 'Answer 0-1-0', },
                        { text    => 'Answer 0-1-1', },
                    ],
                },
                { text    => 'Question 0-2', answers => [],
                },
                {
                    text    => 'Question 0-3',
                    answers => [
                        { text    => 'Answer 0-3-0', },
                        { text    => 'Answer 0-3-1', },
                    ],
                },
            ],
        },
        {
            title     => 'Section 1',
            questions => [
                { text    => 'Question 1-0', answers => [], },
            ],
        },
        {
            title     => 'Section 2',
            questions => [
                {
                    text    => '',
                    answers => [],
                },
            ],
        },
        {
            title     => 'Section 3',
            questions => [
                {
                    text    => 'Question 3-0', answers => [],
                },
            ],
        },
    ],
    'sanity check'
);

####################################################
#
# getDragDropList
#
####################################################

cmp_deeply(
    $surveyJSON->getDragDropList([0, 1]),
    [
        {
            type => 'section',
            text => 'Section 0',
        },
        {
            type => 'question',
            text => 'Question 0-0',
        },
        {
            type => 'question',
            text => 'Question 0-1',
        },
        {
            type => 'answer',
            text => 'Answer 0-1-0',
        },
        {
            type => 'answer',
            text => 'Answer 0-1-1',
        },
        {
            type => 'question',
            text => 'Question 0-2',
        },
        {
            type => 'question',
            text => 'Question 0-3',
        },
        {
            type => 'section',
            text => 'Section 1',
        },
        {
            type => 'section',
            text => 'Section 2',
        },
        {
            type => 'section',
            text => 'Section 3',
        },
    ],
    'getDragDropList: list of sections, questions and answers is correct'
);

cmp_deeply(
    $surveyJSON->getDragDropList([1, 0]),
    [
        {
            type => 'section',
            text => 'Section 0',
        },
        {
            type => 'section',
            text => 'Section 1',
        },
        {
            type => 'question',
            text => 'Question 1-0',
        },
        {
            type => 'section',
            text => 'Section 2',
        },
        {
            type => 'section',
            text => 'Section 3',
        },
    ],
    'getDragDropList: list of sections, and question with no answer'
);

cmp_deeply(
    $surveyJSON->getDragDropList([2, 0]),
    [
        {
            type => 'section',
            text => 'Section 0',
        },
        {
            type => 'section',
            text => 'Section 1',
        },
        {
            type => 'section',
            text => 'Section 2',
        },
        {
            type => 'question',
            text => '',
        },
        {
            type => 'section',
            text => 'Section 3',
        },
    ],
    'getDragDropList: FIXME: list of sections, no questions'
);

####################################################
#
# getAnswerEditVars
#
####################################################

cmp_deeply(
    $surveyJSON->getAnswerEditVars([0,1,0]),
    superhashof({
        id           => '0-1-0',
        displayed_id => '1',
        text         => 'Answer 0-1-0',
        type         => 'answer',
    }),
    'getAnswerEditVars: retrieved correct answer'
);

my $answerEditVars = $surveyJSON->getAnswerEditVars([0,1,0]);
$answerEditVars->{textRows} = 1000;
my (undef, undef, $bareAnswer2) = getBareSkeletons();
$bareAnswer2->{text} = ignore();
cmp_deeply(
    $surveyJSON->answer([0,1,0]),
    $bareAnswer2,
    'getAnswerEditVars: uses a safe copy to build the vars hash'
);

####################################################
#
# getQuestionEditVars
#
####################################################

my @questionTypeVars = map {
    {
        text => $_, selected => ($_ eq 'Multiple Choice' ? 1 : 0),
    }
} $surveyJSON->getValidQuestionTypes();

cmp_deeply(
    $surveyJSON->getQuestionEditVars([3,0]),
    superhashof({
        id           => '3-0',
        displayed_id => '1',
        text         => 'Question 3-0',
        type         => 'question',
        questionType => \@questionTypeVars,
    }),
    'getQuestionEditVars: retrieved correct question'
);

my $questionEditVars = $surveyJSON->getQuestionEditVars([3,0]);
$questionEditVars->{commentCols} = 1000;
my (undef, $bareQuestion2, undef) = getBareSkeletons();
$bareQuestion2->{text} = ignore();
cmp_deeply(
    $surveyJSON->question([3,0]),
    $bareQuestion2,
    'getQuestionEditVars: uses a safe copy to build the vars hash'
);

$surveyJSON->question([3,0])->{questionType} = 'Scale';

@questionTypeVars = map {
    {
        text => $_, selected => ($_ eq 'Scale' ? 1 : 0),
    }
} $surveyJSON->getValidQuestionTypes();

cmp_deeply(
    $surveyJSON->getQuestionEditVars([3,0]),
    superhashof({
        questionType => \@questionTypeVars,
    }),
    'getQuestionEditVars: does correct detection of questionType'
);

$surveyJSON->question([3,0])->{questionType} = 'Multiple Choice';


####################################################
#
# getSectionEditVars
#
####################################################

my @questionsPerPageVars = map {
    {
        index => $_, selected => ($_ == 5 ? 1 : 0),
    }
} 1 .. 20;

cmp_deeply(
    $surveyJSON->getSectionEditVars([3]),
    superhashof({
        id           => '3',
        displayed_id => '4',
        title        => 'Section 3',
        type         => 'section',
        questionsPerPage => \@questionsPerPageVars,
    }),
    'getSectionEditVars: retrieved correct section'
);

my $sectionEditVars = $surveyJSON->getSectionEditVars([3,0]);
$sectionEditVars->{timeLimit} = 1000;
my ($bareSection2, undef, undef) = getBareSkeletons();
$bareSection2->{title}     = ignore();
$bareSection2->{questions} = ignore();
cmp_deeply(
    $surveyJSON->section([3,0]),
    $bareSection2,
    'getSectionEditVars: uses a safe copy to build the vars hash'
);

$surveyJSON->section([3])->{questionsPerPage} = '15';

@questionsPerPageVars = map {
    {
        index => $_, selected => ($_ == 15 ? 1 : 0),
    }
} 1 .. 20;

cmp_deeply(
    $surveyJSON->getSectionEditVars([3]),
    superhashof({
        questionsPerPage => \@questionsPerPageVars,
    }),
    'getSectionEditVars: does correct detection of questionsPerPage'
);

$surveyJSON->section([3])->{questionsPerPage} = 5;

####################################################
#
# getEditVars
#
####################################################

cmp_deeply(
    $surveyJSON->getEditVars([0]),
    superhashof({
        type  => 'section',
        title => 'Section 0',
    }),
    'getEditVars: fetch a section correctly'
);

cmp_deeply(
    $surveyJSON->getEditVars([0,0]),
    superhashof({
        type => 'question',
        text => 'Question 0-0',
    }),
    'getEditVars: fetch a question correctly'
);

cmp_deeply(
    $surveyJSON->getEditVars([0,1,0]),
    superhashof({
        type => 'answer',
        text => 'Answer 0-1-0',
    }),
    'getEditVars: fetch an answer correctly'
);

####################################################
#
# addAnswersToQuestion, getMultiChoiceBundle
#
####################################################

#We'll work exclusively with Question 3-0

my $answerBundle = $surveyJSON->getMultiChoiceBundle('Yes/No');
$surveyJSON->addAnswersToQuestion( [3,0],
    $answerBundle,
);
cmp_deeply(
    $surveyJSON->question([3,0]),
    superhashof({
        answers => [
            superhashof({
                text     => 'Yes',
                verbatim => 0,
                recordedAnswer => $answerBundle->[0]{recordedAnswer},
                value => $answerBundle->[0]{value},
            }),
            superhashof({
                text     => 'No',
                verbatim => 0,
                recordedAnswer => $answerBundle->[1]{recordedAnswer},
                value => $answerBundle->[1]{value},
            }),
        ],
    }),
    'addAnswersToQuestion: Yes/No bundle created' # N.B. This test is dependent on the default values of the Yes/No bundle
);

####################################################
#
# updateQuestionAnswers
#
####################################################

$surveyJSON->updateQuestionAnswers([3,0], 'Some type of test that should never exist');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => '',
        }),
    ],
    'updateQuestionAnswers: Handling undefined question types; no text, no verbatim, and no recorded answer'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Gender');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Male',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        superhashof({
            text     => 'Female',
            verbatim => 0,
            recordedAnswer => 1,
        }),
    ],
    'updateQuestionAnswers: Gender type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Yes/No');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Yes',
            verbatim => 0,
            recordedAnswer => 1,
        }),
        superhashof({
            text     => 'No',
            verbatim => 0,
            recordedAnswer => 0,
        }),
    ],
    'updateQuestionAnswers: Yes/No type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'True/False');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'True',
            verbatim => 0,
            recordedAnswer => 1,
        }),
        superhashof({
            text     => 'False',
            verbatim => 0,
            recordedAnswer => 0,
        }),
    ],
    'updateQuestionAnswers: True/False type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Agree/Disagree');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Strongly disagree',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 5,
        superhashof({
            text     => 'Strongly agree',
            verbatim => 0,
            recordedAnswer => 6,
        }),
    ],
    'updateQuestionAnswers: Agree/Disagree type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Oppose/Support');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Strongly oppose',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 5,
        superhashof({
            text     => 'Strongly support',
            verbatim => 0,
            recordedAnswer => 6,
        }),
    ],
    'updateQuestionAnswers: Agree/Disagree type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Importance');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all important',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely important',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Importance type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Likelihood');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all likely',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely likely',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Likelihood type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Certainty');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all certain',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely certain',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Certainty type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Satisfaction');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all satisfied',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely satisfied',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Satisfaction type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Confidence');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all confident',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely confident',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Confidence type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Effectiveness');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all effective',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely effective',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Effectiveness type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Concern');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all concerned',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely concerned',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Concern type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Risk');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'No risk',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extreme risk',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Risk type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Threat');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'No threat',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extreme threat',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Threat type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Security');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Not at all secure',
            verbatim => 0,
            recordedAnswer => 0,
        }),
        ( superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => ignore(),
        }) )x 9,
        superhashof({
            text     => 'Extremely secure',
            verbatim => 0,
            recordedAnswer => 10,
        }),
    ],
    'updateQuestionAnswers: Security type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Ideology');
my $index = 0;
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        map {
            superhashof({
                text     => $_,
                verbatim => 0,
                recordedAnswer => $index++,
            })
        }
            'Strongly liberal',
            'Liberal',
            'Somewhat liberal',
            'Middle of the road',
            'Slightly conservative',
            'Conservative',
            'Strongly conservative',
    ],
    'updateQuestionAnswers: Ideology type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Race');
$index = 0;
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        map {
            superhashof({
                text     => $_,
                verbatim => $index == 5 ? 1 : 0,
                recordedAnswer => $index++,
            })
        } 'American Indian', 'Asian', 'Black', 'Hispanic', 'White non-Hispanic', 'Something else (verbatim)',
    ],
    'updateQuestionAnswers: Race type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Party');
$index = 0;
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        map {
            superhashof({
                text     => $_,
                verbatim => $index == 3 ? 1 : 0,
                recordedAnswer => $index++,
            })
        } 'Democratic party', 'Republican party (or GOP)', 'Independent party', 'Other party (verbatim)',
    ],
    'updateQuestionAnswers: Party type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Education');
$index = 0;
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        map {
            superhashof({
                text     => $_,
                verbatim => $index == 7 ? 1 : 0,
                recordedAnswer => $index++,
            })
        }
            'Elementary or some high school',
            'High school/GED',
            'Some college/vocational school',
            'College graduate',
            'Some graduate work',
            'Master\'s degree',
            'Doctorate (of any type)',
            'Other degree (verbatim)'
    ],
    'updateQuestionAnswers: Education type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Email');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Email:',
            verbatim => 0,
            recordedAnswer => '',
        }),
    ],
    'updateQuestionAnswers: Email type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Phone Number');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Phone Number:',
            verbatim => 0,
            recordedAnswer => '',
        }),
    ],
    'updateQuestionAnswers: Phone Number type'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Text Date');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Date:',
            verbatim => 0,
            recordedAnswer => '',
        }),
    ],
    'updateQuestionAnswers: Text Date'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Currency');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        superhashof({
            text     => 'Currency Amount:',
            verbatim => 0,
            recordedAnswer => '',
        }),
    ],
    'updateQuestionAnswers: Currency'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Date Range');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        (superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => '',
        })) x 2,
    ],
    'updateQuestionAnswers: Date Range'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Multi Slider - Allocate');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        (superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => '',
        })) x 2,
    ],
    'updateQuestionAnswers: Multi Slider - Allocate'
);

$surveyJSON->updateQuestionAnswers([3,0], 'Dual Slider - Range');
cmp_deeply(
    $surveyJSON->question([3,0])->{answers},
    [
        (superhashof({
            text     => '',
            verbatim => 0,
            recordedAnswer => '',
        })) x 2,
    ],
    'updateQuestionAnswers: Dual Slider - Range'
);

####################################################
#
# questions
#
####################################################
{
    my $s = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, '{}');
    # Add a new section
    my $address = $s->newObject([]);
    cmp_deeply($s->questions, [], 'Initially no questions');
    # Add a question to first section 
    $address = $s->newObject([0]);
    is(scalar @{$s->questions}, 1, '..now 1 question');
    is(scalar @{$s->questions([0])}, 1, '..in the first section');
    cmp_deeply($s->questions([2]), [], '..and none in the second section (which doesnt even exist)');

    # Add a question to second section 
    $address = $s->newObject([1]);
    is(scalar @{$s->questions}, 2, '..now 2 question2');
    is(scalar @{$s->questions([0])}, 1, '..1 in the first section');
    is(scalar @{$s->questions([1])}, 1, '..1 in the second section');
}

####################################################
#
# totalSections, totalQuestions, totalAnswers
#
####################################################
{
    my $s = WebGUI::Asset::Wobject::Survey::SurveyJSON->new($session, '{}');
    is($s->totalSections, 1, 'a');
    is($s->totalQuestions, 0, 'a');
    is($s->totalAnswers, 0, 'a');
    
    # Add a new section
    my $address = $s->newObject([]);
    is($s->totalSections, 2, 'Now there are 2 sections');
    is($s->totalQuestions, 0, '..but still no questions');
    is($s->totalAnswers, 0, '..and no answers');
    
    # Add a question to first section 
    $address = $s->newObject([0]);
    is($s->totalSections, 2, 'Still 2 sections');
    is($s->totalQuestions, 1, '..and now 1 question');
    is($s->totalQuestions([0]), 1, '..in the intended section');
    is($s->totalAnswers, 0, '..but still no answers');
    
    # Add a question to second section 
    $address = $s->newObject([1]);
    is($s->totalSections, 2, 'Still 2 sections');
    is($s->totalQuestions, 2, '..and now 2 questions overall');
    is($s->totalQuestions([0]), 1, '..one in the first section');
    is($s->totalQuestions([1]), 1, '..and one in the second section');
    is($s->totalAnswers, 0, '..but still no answers');
    
    # Add another question to second section 
    $address = $s->newObject([1]);
    is($s->totalSections, 2, 'Still 2 sections');
    is($s->totalQuestions, 3, '..and now 3 questions overall');
    is($s->totalQuestions([0]), 1, '..one in the first section');
    is($s->totalQuestions([1]), 2, '..and two in the second section');
    is($s->totalAnswers, 0, '..but still no answers');
    
    # Add an answer to second section, first question
    $address = $s->newObject([1,0]);
    is($s->totalSections, 2, 'Still 2 sections');
    is($s->totalQuestions, 3, '..and 3 questions');
    is($s->totalAnswers, 1, '..and now 1 answer overall');
    is($s->totalAnswers([0,0]), 0, '..0 in first question');
    is($s->totalAnswers([1,0]), 1, '..1 in second question');
    is($s->totalAnswers([1,1]), 0, '..0 in third question');
    
    # Add an answer to second section, second question
    $address = $s->newObject([1,1]);
    is($s->totalSections, 2, 'Still 2 sections');
    is($s->totalQuestions, 3, '..and 3 questions');
    is($s->totalAnswers, 2, '..and now 2 answer overall');
    is($s->totalAnswers([0,0]), 0, '..0 in first question');
    is($s->totalAnswers([1,0]), 1, '..1 in second question');
    is($s->totalAnswers([1,1]), 1, '..1 in third question');
    
    # Add a second answer to second section, second question
    $address = $s->newObject([1,1]);
    is($s->totalSections, 2, 'Still 2 sections');
    is($s->totalQuestions, 3, '..and 3 questions');
    is($s->totalAnswers, 3, '..and now 3 answer overall');
    is($s->totalAnswers([0,0]), 0, '..0 in first question');
    is($s->totalAnswers([1,0]), 1, '..1 in second question');
    is($s->totalAnswers([1,1]), 2, '..2 in third question');
}

####################################################
#
# log
#
####################################################

isa_ok($surveyJSON->session, 'WebGUI::Session', 'session() accessor works');

}

####################################################
#
# Utility test routines
#
####################################################

# Go through a JSON survey type data structure and just grab some unique
# elements

sub summarizeSectionSkeleton {
    my ($skeleton) = @_;
    my $summary = [];
    foreach my $section (@{ $skeleton->{_sections} }) {
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
           gotoExpression         => '',
           timeLimit              => 0,
           type                   => 'section',
           questions              => [],
           logical                => 0,
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
           goto                   => '',
           gotoExpression         => '',
        },
        {
           text                   => '',
           verbatim               => 0,
           textCols               => 10,
           textRows               => 5,
           goto                   => '',
           gotoExpression         => '',
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
