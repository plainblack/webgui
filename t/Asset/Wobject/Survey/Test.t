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
plan tests => 94;

my $tp = use_ok('TAP::Parser');
my $tpa = use_ok('TAP::Parser::Aggregator');

#----------------------------------------------------------------------------
# put your tests here
use_ok('WebGUI::Asset::Wobject::Survey::Test');

my $user = WebGUI::User->new( $session, 'new' );
WebGUI::Test->addToCleanup($user);
my $import_node = WebGUI::Asset->getImportNode($session);

$session->config->set('enableSurveyExpressionEngine', 1);

# Create a Survey
my $s = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
isa_ok( $s, 'WebGUI::Asset::Wobject::Survey' );
WebGUI::Test->addToCleanup($s);

my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag);
$s = $s->cloneFromDb;

my $sJSON = $s->getSurveyJSON;

# N.B. Survey starts off with a single empty section (S0)

# Add some sections and questions
$sJSON->newObject( [] ); # S1
$sJSON->newObject( [] ); # S2
$sJSON->newObject( [] ); # S3
$sJSON->newObject( [] ); # S4
$sJSON->newObject( [] ); # S5
$sJSON->newObject( [] ); # S6

# Name the sections
for my $sIndex (0..6) {
    $sJSON->update( [$sIndex], { variable => "S$sIndex" } );
}

# ..and now some questions
$sJSON->newObject( [0] ); # S0Q0
$sJSON->newObject( [1] ); # S1Q0
$sJSON->newObject( [2] ); # S2Q0
$sJSON->newObject( [3] ); # S3Q0
$sJSON->newObject( [3] ); # S3Q1
$sJSON->newObject( [3] ); # S3Q2
$sJSON->newObject( [4] ); # S4Q0
$sJSON->newObject( [5] ); # S5Q0
$sJSON->newObject( [5] ); # S5Q1
$sJSON->newObject( [5] ); # S5Q2

# Name the questions
$sJSON->update( [ 0, 0 ], { variable => 'S0Q0' } );
$sJSON->update( [ 1, 0 ], { variable => 'S1Q0' } );
$sJSON->update( [ 2, 0 ], { variable => 'S2Q0' } );
$sJSON->update( [ 3, 0 ], { variable => 'S3Q0' } );
$sJSON->update( [ 3, 1 ], { variable => 'S3Q1' } );
$sJSON->update( [ 3, 2 ], { variable => 'S3Q2' } );
$sJSON->update( [ 4, 0 ], { variable => 'S4Q0' } );
$sJSON->update( [ 5, 0 ], { variable => 'S5Q0' } );
$sJSON->update( [ 5, 1 ], { variable => 'S5Q1' } );
$sJSON->update( [ 5, 2 ], { variable => 'S5Q2' } );

# Set additional options..
$sJSON->update( [ 0, 0 ], { questionType => 'Yes/No' } ); # S0Q0 is a Yes/No
$sJSON->update( [ 0, 0 ], { gotoExpression => q{ tag('tagged at S0Q0'); } } ); # S0Q0 tagged data

$sJSON->update( [ 1, 0 ], { questionType => 'Yes/No' } ); # S1Q0 is a Yes/No
$sJSON->update( [ 1, 0, 0 ], { goto => 'S3', recordedAnswer => q{} } ); # S1Q0 answer 0 jumps to S3 (set recordedAnswer to '' to detect subtle bug)
$sJSON->update( [ 1, 0, 1 ], { gotoExpression => q{ tag('tagged at S1Q0', 999); }, recordedAnswer => q{} } );# S1Q0 answer 1 tagged numeric data

$sJSON->update( [ 3 ], { gotoExpression => q{ jump { score(S3) == 0 } S5; } } ); # jump to S5 if all 3 questions answered as No
for my $qIndex (0..2) {
    $sJSON->update( [ 3, $qIndex ], { questionType => 'Yes/No', required => 1 } );
    $sJSON->update( [ 3, $qIndex, 1 ], { value => 0 } ); # Set 'No' score to 0
}

$sJSON->update( [ 4, 0 ], { questionType => 'Concern' } );

$sJSON->update( [ 5, 0 ], { questionType => 'Slider', required => 1 } );
$sJSON->update( [ 5, 1 ], { questionType => 'Text', required => 1 } );
$sJSON->update( [ 5, 2 ], { questionType => 'Number', required => 1 } );

$sJSON->update( [ 6 ], { logical => 1, gotoExpression => q{tag('tagged at S6');} } );

# And finally, persist the changes..
$s->persistSurveyJSON;

my $rJSON = $s->responseJSON;

cmp_deeply(
    $rJSON->surveyOrder,
    [   [ 0, 0, [ 0, 1 ] ],    # S0Q0 (surveyOrderIndex: 0)
        [ 1, 0, [ 0, 1 ] ],    # S1Q0 (surveyOrderIndex: 1)
        [ 2, 0, [] ],          # S2Q0 (surveyOrderIndex: 2)
        [ 3, 0, [ 0, 1 ] ],    # S3Q0 (surveyOrderIndex: 3)
        [ 3, 1, [ 0, 1 ] ],    # S3Q1 (surveyOrderIndex: 4)
        [ 3, 2, [ 0, 1 ] ],    # S3Q2 (surveyOrderIndex: 5)
        [ 4, 0, [ 0 .. 10 ] ], # S4Q0 (surveyOrderIndex: 6)
        [ 5, 0, [0] ],         # S5Q0 (surveyOrderIndex: 7)
        [ 5, 1, [0] ],         # S5Q0 (surveyOrderIndex: 8)
        [ 5, 2, [0] ],         # S5Q0 (surveyOrderIndex: 9)
        [6],                   # S6   (surveyOrderIndex: 10)
    ],
    'surveyOrder is correct'
);
cmp_deeply(
    $rJSON->surveyOrderIndex, 
    {   
        'S0'   => 0,
        'S0Q0' => 0,
        'S1'   => 1,
        'S1Q0' => 1,
        'S2'   => 2,
        'S2Q0' => 2,
        'S3'   => 3,
        'S3Q0' => 3,
        'S3Q1' => 4,
        'S3Q2' => 5,
        'S4'   => 6,
        'S4Q0' => 6,
        'S5'   => 7,
        'S5Q0' => 7,
        'S5Q1' => 8,
        'S5Q2' => 9,
        'S6'   => 10,
    },
    'surveyOrderIndex correct'
);

my $t1 = WebGUI::Asset::Wobject::Survey::Test->create( $session, { assetId => $s->getId } );
WebGUI::Test->addToCleanup(sub {$t1->delete();});
my $spec;

# No tests
$spec = <<END_SPEC;
[ ]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..0

END_TAP

# Empty defn
$spec = <<END_SPEC;
[ {} ]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..0
Bail Out! Invalid test definition
END_TAP

# Rubbish defn
$spec = <<END_SPEC;
[ { blah: 1 } ]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..0
Bail Out! Invalid test definition
END_TAP

######
# test
######

# No tests
$spec = <<END_SPEC;
[
    {
       "test" : { }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP, fail => 1 } );
1..1
not ok 1 - Nothing to do
END_TAP

# Both answers for S0Q0 jump to the next item, which can be referred to as either S1 or S1Q0
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S0Q0" : "Yes",
            "next" : "S1",
       }
    },
    {
       "test" : {
            "S0Q0" : "No",
            "next" : "S1Q0",
       }
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Checking next on page containing Section S0 Question S0Q0
ok 2 - Checking next on page containing Section S0 Question S0Q0
END_TAP

# deliberately pass in a spec that will fail
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S0Q0" : "Yes",
            "next" : "S2", # wrong target, should fail
       }
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP, fail => 1 } );
1..1
not ok 1 - Checking next on page containing Section S0 Question S0Q0
# Compared next section/question
#    got : 'S1' (<-- a section) and 'S1Q0' (<-- a question)
# expect : 'S2'
END_TAP

# also fails if we don't answer all required questions
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S3Q0" : "Yes",
            "next" : "S4", # fails because we missed S3Q1 and S3Q2
       }
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP, fail => 1 } );
1..1
not ok 1 - Checking next on page containing Section S3 Question S3Q0
# Compared next section/question
#    got : 'S3' (<-- a section) and 'S3Q0' (<-- a question)
# expect : 'S4'
END_TAP

# now try it on a question that has branching, and doesn't start on the first page
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S1Q0" : "Yes",
            "next" : "S3", # a goto jump
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next on page containing Section S1 Question S1Q0
END_TAP

# use our own description
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S1Q0" : "Yes",
            "next" : "S3", # a goto jump
       },
       "name" : "my individual test label"
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - my individual test label
END_TAP

## Use tagged..
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S0Q0" : "Yes",
            "next" : "S1",
            "tagged" : [ "tagged at S0Q0" ],  # and tagged correctly
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and tagged on page containing Section S0 Question S0Q0
END_TAP

# Same but more verbose
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S0Q0" : "Yes",
            "next" : "S1",
            "tagged" : [ { "tagged at S0Q0" : 1 }, ],  # and tagged correctly
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and tagged on page containing Section S0 Question S0Q0
END_TAP

# Also the same (uses hash instead of array)
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S0Q0" : "Yes",
            "next" : "S1",
            "tagged" : { "tagged at S0Q0" : 1 },
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and tagged on page containing Section S0 Question S0Q0
END_TAP

# Use page..
$spec = <<END_SPEC;
[
    {
       "test" : {
           "page" : { "S0Q0" : "Yes" }, # S0Q0 tagged 'tagged at S0Q0'
            "S1Q0" : "No",               
            "next" : "S2",
            "tagged" : [ "tagged at S0Q0" ],  # tagged by page step
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and tagged on page containing Section S1 Question S1Q0
END_TAP

# Use nested page..
$spec = <<END_SPEC;
[
    {
       "test" : {
           "page" : { 
               "page" : { 
                   "S0Q0" : "Yes"            # tagged 'tagged at S0Q0'
               },
               "S1Q0" : "No",                # tagged 'tagged at S1Q0' with value 999
            }, 
            "S2Q0" : null,
            "next" : "S3",
            "tagged" : [ "tagged at S0Q0", { "tagged at S1Q0" : 999 }, ],  # tagged by page step
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and tagged on page containing Section S2 Question S2Q0
END_TAP

# Use the score option
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S3Q0"  : "n",
            "S3Q1"  : "y",
            "S3Q2"  : "y",
            "next"  : "S4",
            "score" : { "S3" : 2 },
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and score on page containing Section S3 Question S3Q0
END_TAP

# Use the setup option
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S1Q0"  : "n",  # sets a tag of its own
            "page" : { S0Q0: "y" }, # make sure this doesn't get overwritten
            "tagged" : [ 'tagged at S0Q0', { 'tagged at S1Q0' : 999 }, "my test tag", { "my data tag": 1.5 } ],
       },
       "setup" : { tag: [ "my test tag", { "my data tag": 1.5 } ] },
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking tagged on page containing Section S1 Question S1Q0
END_TAP

# Complex tag object via setup option
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S1Q0"  : "n",
            "setup" : { tag: { nested: { a: { a: 1 }, b: [ 2 ] } } },
            "tagged" : { nested: { a: { a: 1 }, b: [ 2 ] } },
       },
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking tagged on page containing Section S1 Question S1Q0
END_TAP

# setup can also be specified inside test object
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S1Q0"  : "n",  # sets a tag of its own
            "setup" : { tag: [ "my test tag", { "my data tag": 1.5 } ] },
            "page" : { S0Q0: "y" }, # make sure this doesn't get overwritten
            "tagged" : [ 'tagged at S0Q0', { 'tagged at S1Q0' : 999 }, "my test tag", { "my data tag": 1.5 } ],
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking tagged on page containing Section S1 Question S1Q0
END_TAP

# Check that the tags disappear between tests
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S1Q0"  : "n",  # sets a tag of its own
            "setup" : { tag: [ "my test tag", { "my data tag": 1.5 } ] },
            "page" : { S0Q0: "y" }, # make sure this doesn't get overwritten
            "tagged" : [ 'tagged at S0Q0', { 'tagged at S1Q0' : 999 }, "my test tag", { "my data tag": 1.5 } ],
       }
    },
    {
       "test" : {
            "S1Q0"  : "y",
            "tagged" : [ 'tagged at S0Q0'],
       }
    },
    {
       "test" : {
            "S1Q0"  : "y",
            "tagged" : [ 'tagged at S1Q0',],
       }
    },
    {
       "test" : {
            "S1Q0"  : "y",
            "tagged" : [ "my data tag" ],
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP, fail => 1 } );
1..4
ok 1 - Checking tagged on page containing Section S1 Question S1Q0
not ok 2 - Checking tagged on page containing Section S1 Question S1Q0
# Tag not found: tagged at S0Q0
not ok 3 - Checking tagged on page containing Section S1 Question S1Q0
# Tag not found: tagged at S1Q0
not ok 4 - Checking tagged on page containing Section S1 Question S1Q0
# Tag not found: my data tag
END_TAP

# Slider, Number & Text question types
# And also test the fact that S6 is logical
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S5Q0" : 5, # Slider
            "S5Q1" : 'blah', # Text
            "S5Q2" : 5, # Number
            "next" : "SURVEY_END",
            tagged : [ 'tagged at S6' ],
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Checking next and tagged on page containing Section S5 Question S5Q0
END_TAP

# Fall off the end of the Survey

#########
# test_mc
#########
# Now use test_mc
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S0Q0",  # from S0Q0
            "S1Q0",  # first answer falls through
            "S1",    # second answer falls through to the same place
        ] 
    } 
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Checking next for S0Q0 mc answer 1
ok 2 - Checking next for S0Q0 mc answer 2
END_TAP

# try the same thing, but in a more verbose form
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S0Q0",  # from S0Q0
            { "next" : "S1Q0" },    # first answer falls through
            { "next" : "S1"   },    # second answer falls through to the same place
        ]
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Checking next for S0Q0 mc answer 1
ok 2 - Checking next for S0Q0 mc answer 2
END_TAP

# use the tagged option
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S0Q0",                             # test S0Q0
            {   "next" : "S1Q0",                # first answer falls through
                "tagged" : [ "tagged at S0Q0" ],  # and tagged data
            },    
            { "next" : "S1" },                  # second answer falls through to the same place
        ]
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Checking next and tagged for S0Q0 mc answer 1
ok 2 - Checking next for S0Q0 mc answer 2
END_TAP

# use the setup option
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S0Q0",                             # test S0Q0
            {   "next" : "S1Q0",                # first answer falls through
                "tagged" : [ "tagged at S0Q0", 'blah' ],  # and tagged data
            },    
            { "next" : "S1" },                  # second answer falls through to the same place
        ],
        setup : { tag: [ "blah" ] },
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Checking next and tagged for S0Q0 mc answer 1
ok 2 - Checking next for S0Q0 mc answer 2
END_TAP

# And try one that does branching, and doesn't start on the first page
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S1Q0",                             # test S1Q0
            {   "next" : "S3",                  # first answer jumps
                "tagged" : [ ],                   # nothing gets tagged
            },
            { "next" : "S2" },                  # second answer falls through
        ]
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Checking next and tagged for S1Q0 mc answer 1
ok 2 - Checking next for S1Q0 mc answer 2
END_TAP

#########
# sequence
#########
$spec = <<END_SPEC;
[ 
    { 
        "sequence" : { 
            "S0Q0" : { "recordedAnswer" : "desc"}, # This is a default Yes/No (score all 1)
            "S4Q0" : { "recordedAnswer" : "asc" },                    # Certainty scale, with recordedAnswer 0 .. 11
            "S3Q0" : { "recordedAnswer" : "desc", "score" : "desc" }, # These 3 are yes/no questions where we have
            "S3Q1" : { "recordedAnswer" : "desc", "score" : "desc" }, # ..set the score on the No answer to zero, hence
            "S3Q2" : { "recordedAnswer" : "desc", "score" : "desc" }, # ..they are descending
        }
    },
    { 
        "name" : "Say my name",
        "sequence" : {
            "S3Q2" : { "recordedAnswer" : "desc", "score" : "desc" }, # ..they are descending
        }
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - Valid sequences
ok 2 - Say my name
END_TAP

#########
# defined
#########
$spec = <<END_SPEC;
[ 
    { 
        defined : { 
            S0Q0 : { answer: [ 'value', 'recordedAnswer' ] },
        }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Defined
END_TAP
$spec = <<END_SPEC;
[ 
    { 
        defined : { 
            S0Q0 : { answer: [ 'value', 'recordedAnswer' ] },
            'S1Q.' : { answer: [ 'value', 'recordedAnswer' ] },
        }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP, fail => 1 } );
1..1
not ok 1 - S1Q0 answer number 1 property recordedAnswer not defined
# got: ''
END_TAP

sub try_it {
    my ( $test, $spec, $opts ) = @_;
    chomp($spec);

    $test->update( { test => $spec } );
    my $result = $t1->run();
    ok( $result, 'Tests ran ok' );

    if ( my $tap = $opts->{tap} ) {
        chomp($tap);
        is( $result->{tap}, $tap, 'TAP matches' );
    }

    my $parser = TAP::Parser->new($result);
    while ( my $r = $parser->next ) {

        # we could test extra stuff here, but mainly we just need to make the parser
        # go all the way through so that we can access ->has_problems
    }
    ok( !$parser->has_problems == !$opts->{fail}, ( $opts->{fail} ? "Fails" : "Passes" ) . ' as expected' );
}

###################
# get_differences #
###################
is(WebGUI::Asset::Wobject::Survey::Test::get_differences('a', 'b'), <<END_CMP, 'scalar differences');
   got : 'a'
expect : 'b'
END_CMP

is(WebGUI::Asset::Wobject::Survey::Test::get_differences('a'), <<END_CMP, 'undef differences');
   got : 'a'
expect : ''
END_CMP

is(WebGUI::Asset::Wobject::Survey::Test::get_differences([0..10], [0..9]), 'Array lengths differ', 'array differences');
is(WebGUI::Asset::Wobject::Survey::Test::get_differences({a => 1}, {a => 2}), <<END_CMP, 'hash differences');
Hashes differ on element: a
   got : '1'
expect : '2'
END_CMP

#----------------------------------------------------------------------------
# Cleanup
END {
}
