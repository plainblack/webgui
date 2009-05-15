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
plan tests => 16;

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

# Load bare-bones survey, containing a single section (S0)
$s->surveyJSON_update( [0], { variable => 'S0' } );

# Section 0 has a single question, S0Q0, which is a Yes/No muti-choice
$s->surveyJSON_newObject( [0] );                             # S0Q0
$s->surveyJSON_update( [ 0, 0 ], { variable => 'S0Q0' } );
$s->surveyJSON->updateQuestionAnswers( [ 0, 0 ], 'Yes/No' );

# Add a new section (S1)
$s->surveyJSON_newObject( [] );
$s->surveyJSON_update(    [1], { variable => 'S1' } );
$s->surveyJSON_newObject( [1] );
$s->surveyJSON_newObject( [1] );
$s->surveyJSON_update(    [ 1, 0 ], { variable => 'S1Q0' } );
$s->surveyJSON_update(    [ 1, 1 ], { variable => 'S1Q1' } );

$s->persistSurveyJSON;

cmp_deeply(
    $s->responseJSON->surveyOrder,
    [ [ 0, 0, [ 0, 1 ] ], [ 1, 0, [0] ], [ 1, 1, [0] ] ],
    'At this stage our surveyOrder has 3 items'
);

cmp_deeply(
    $s->responseJSON->surveyOrderIndexByVariableName,
    {   'S0'   => 0,
        'S0Q0' => 0,
        'S1'   => 1,
        'S1Q0' => 1,
        'S1Q1' => 2,
    },
    '..which corresponds to'
);

$t1 = WebGUI::Asset::Wobject::Survey::Test->create( $session, { assetId => $s->getId } );
my ($spec, $tap);

$spec = <<END_SPEC;
[
    {
       test : {
            S0Q0 : 'Yes',
            next : "S1",
       }
    },
    {
       test : {
            S0Q0 : 'No',
            next : "S1",
       }
    }
]
END_SPEC
$tap = <<END_TAP;
1..2
ok 1
ok 2
END_TAP
try_it($t1, $spec, { tap => $tap });

# add a goto into the mix
$s->surveyJSON_update( [ 0, 0, 0 ], { goto => 'S1Q1' } );
# deliberately pass in a spec that will fail
$spec = <<END_SPEC;
[ { test : { 
        S0Q0 : 'Yes',
        next : "S1", # this will fail here, because Yes now jumps to S1Q1
    } 
  },
  { test : { 
        S0Q0 : 'No',
        next : "S1",
    }
} ]
END_SPEC
my $tap2 = <<END_TAP;
1..2
not ok 1 - next S1
# Compared next section/question
#    got : S1Q1 (<-- a question)
# expect : S1
ok 2
END_TAP
try_it($t1, $spec, { tap => $tap2, fail => 1 });

# try now with a spec that will pass
$spec = <<END_SPEC;
[ { test : { 
        S0Q0 : 'Yes',
        next : "S1Q1", # jumps
    } 
  },
  { test : { 
        S0Q0 : 'No',
        next : "S1", # falls through
    }
} ]
END_SPEC
try_it($t1, $spec, { tap => $tap });

# Now use test_mc
$spec = q{ [ { test_mc : [ 'S0Q0', 'S1Q1', 'S1' ] } ] };
try_it($t1, $spec, { tap => $tap });



use TAP::Parser;
sub try_it {
    my ($test, $spec, $opts) = @_;
    chomp($spec);
    
    $test->update( { test => $spec } );
    my $result = $t1->run();
    ok( $result, 'Tests ran ok' );
    
    if (my $tap = $opts->{tap}) {
        chomp($tap);
        is( $result->{tap}, $tap, 'TAP matches' );
    }
    
    my $parser = TAP::Parser->new( $result );
    while (my $r = $parser->next) {
        # we could test extra stuff here, but mainly we just need to make the parser
        # go all the way through so that we can access ->has_problems
    }
    ok(!$parser->has_problems == !$opts->{fail}, ($opts->{fail} ? "Fails" : "Passes") . ' as expected');
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $s->purge() if $s;
    $t1->delete();
}
