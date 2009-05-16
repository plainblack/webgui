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
plan tests => 34;

my ( $s, $t1 );

#----------------------------------------------------------------------------
# put your tests here
use_ok('WebGUI::Asset::Wobject::Survey::Test');

my $user = WebGUI::User->new( $session, 'new' );
WebGUI::Test->usersToDelete($user);
my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
$s = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
isa_ok( $s, 'WebGUI::Asset::Wobject::Survey' );

$s->responseIdCookies(0);

# N.B. Survey starts off with a single empty section (S0)

# Add some sections and questions
$s->surveyJSON_newObject( [] ); # S1
$s->surveyJSON_newObject( [] ); # S2
$s->surveyJSON_newObject( [] ); # S3
$s->surveyJSON_newObject( [] ); # S4

# Name the sections
$s->surveyJSON_update( [0], { variable => 'S0' } );
$s->surveyJSON_update( [1], { variable => 'S1' } );
$s->surveyJSON_update( [2], { variable => 'S2' } );
$s->surveyJSON_update( [3], { variable => 'S3' } );
$s->surveyJSON_update( [4], { variable => 'S4' } );

# ..and now some questions
$s->surveyJSON_newObject( [0] ); # S0Q0
$s->surveyJSON_newObject( [1] ); # S1Q0
$s->surveyJSON_newObject( [2] ); # S2Q0
$s->surveyJSON_newObject( [3] ); # S3Q0
$s->surveyJSON_newObject( [3] ); # S3Q1
$s->surveyJSON_newObject( [4] ); # S4Q0
$s->surveyJSON_newObject( [4] ); # S4Q1

# Name the questions
$s->surveyJSON_update( [ 0, 0 ], { variable => 'S0Q0' } );
$s->surveyJSON_update( [ 1, 0 ], { variable => 'S1Q0' } );
$s->surveyJSON_update( [ 2, 0 ], { variable => 'S2Q0' } );
$s->surveyJSON_update( [ 3, 0 ], { variable => 'S3Q0' } );
$s->surveyJSON_update( [ 3, 1 ], { variable => 'S3Q1' } );
$s->surveyJSON_update( [ 4, 0 ], { variable => 'S4Q0' } );
$s->surveyJSON_update( [ 4, 1 ], { variable => 'S4Q1' } );

# Set additional options..
$s->surveyJSON_update( [ 0, 0 ], { questionType => 'Yes/No' } ); # S0Q0 is a Yes/No
$s->surveyJSON_update( [ 0, 0 ], { gotoExpression => q{ tag('tagged at S0Q0'); } } ); # S0Q0 tags data

$s->surveyJSON_update( [ 1, 0 ], { questionType => 'Yes/No' } ); # S1Q0 is a Yes/No
$s->surveyJSON_update( [ 1, 0, 0 ], { goto => 'S3' } ); # S1Q0 answer 0 jumps to S3
$s->surveyJSON_update( [ 1, 0, 1 ], { gotoExpression => q{ tag('tagged at S1Q0'); } } );# S1Q0 answer 1 tags data

# And finally, persist the changes..
$s->persistSurveyJSON;

cmp_deeply(
    $s->responseJSON->surveyOrder, [
       [ 0, 0, [ 0, 1 ] ],  # S0Q0
       [ 1, 0, [ 0, 1 ] ],  # S1Q0
       [ 2, 0, [] ],     # S2Q0
       [ 3, 0, [] ],     # S3Q0
       [ 3, 1, [] ],     # S3Q1
       [ 4, 0, [] ],     # S4Q0
       [ 4, 1, [] ],     # S4Q1
     ], 'surveyOrder is correct'
);

cmp_deeply(
    $s->responseJSON->surveyOrderIndexByVariableName, 
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
        'S4'   => 5,
        'S4Q0' => 5,
        'S4Q1' => 6,
    },
    'surveyOrderIndexByVariableName correct'
);

$t1 = WebGUI::Asset::Wobject::Survey::Test->create( $session, { assetId => $s->getId } );
my $spec;

######
# test
######

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
ok 1 - Page containing Section S0 Question S0Q0 jumps to S1
ok 2 - Page containing Section S0 Question S0Q0 jumps to S1Q0
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
not ok 1 - Page containing Section S0 Question S0Q0 jumps to S2
# Compared next section/question
#    got : 'S1' (<-- a section) and 'S1Q0' (<-- a question)
# expect : 'S2'
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
ok 1 - Page containing Section S1 Question S1Q0 jumps to S3
END_TAP

# Use tags..
$spec = <<END_SPEC;
[
    {
       "test" : {
            "S0Q0" : "Yes",
            "next" : "S1",
            "tags" : [ "tagged at S0Q0" ],  # and tagged correctly
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Page containing Section S0 Question S0Q0 jumps to S1 and tags data
END_TAP

# Use setup..
$spec = <<END_SPEC;
[
    {
       "test" : {
           "setup" : { "S0Q0" : "Yes" }, # S0Q0 tags 'tagged at S0Q0'
            "S1Q0" : "No",               
            "next" : "S2",
            "tags" : [ "tagged at S0Q0" ],  # tagged by setup step
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Page containing Section S1 Question S1Q0 jumps to S2 and tags data
END_TAP

# Use nested setup..
$spec = <<END_SPEC;
[
    {
       "test" : {
           "setup" : { 
               "setup" : { 
                   "S0Q0" : "Yes"            # tags 'tagged at S0Q0'
               },
               "S1Q0" : "No",                # tags 'tagged at S1Q0'
            }, 
            "S2Q0" : null,
            "next" : "S3",
            "tags" : [ "tagged at S0Q0", "tagged at S1Q0", ],  # tagged by setup step
       }
    },
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..1
ok 1 - Page containing Section S2 Question S2Q0 jumps to S3 and tags data
END_TAP

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
ok 1 - S0Q0 mc answer 1 jumps to S1Q0
ok 2 - S0Q0 mc answer 2 jumps to S1
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
ok 1 - S0Q0 mc answer 1 jumps to S1Q0
ok 2 - S0Q0 mc answer 2 jumps to S1
END_TAP

# use the tags option
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S0Q0",                             # test S0Q0
            {   "next" : "S1Q0",                # first answer falls through
                "tags" : [ "tagged at S0Q0" ],  # and tags data
            },    
            { "next" : "S1" },                  # second answer falls through to the same place
        ]
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - S0Q0 mc answer 1 jumps to S1Q0 and tags correct
ok 2 - S0Q0 mc answer 2 jumps to S1
END_TAP

# And try one that does branching, and doesn't start on the first page
$spec = <<END_SPEC;
[ 
    { 
        "test_mc" : [ 
            "S1Q0",                             # test S1Q0
            {   "next" : "S3",                  # first answer jumps
                "tags" : [ ],                   # nothing gets tagged
            },
            { "next" : "S2" },                  # second answer falls through
        ]
    }
]
END_SPEC
try_it( $t1, $spec, { tap => <<END_TAP } );
1..2
ok 1 - S1Q0 mc answer 1 jumps to S3 and tags correct
ok 2 - S1Q0 mc answer 2 jumps to S2
END_TAP

use TAP::Parser;

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

#----------------------------------------------------------------------------
# Cleanup
END {
    $s->purge() if $s;
    $t1->delete() if $t1;
}
