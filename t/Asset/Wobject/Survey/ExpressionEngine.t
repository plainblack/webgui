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
use Tie::IxHash;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 60;
plan tests => $tests + 1;

#----------------------------------------------------------------------------
# put your tests here

my $usedOk = use_ok('WebGUI::Asset::Wobject::Survey::ExpressionEngine');
my ($user, $survey, $versionTag);
SKIP: {

    skip $tests, "Unable to load ExpressionEngine" unless $usedOk;

    my $e = "WebGUI::Asset::Wobject::Survey::ExpressionEngine";

    WebGUI::Test->originalConfig('enableSurveyExpressionEngine');
    $session->config->set( 'enableSurveyExpressionEngine', 0 );
    is( $e->run( $session, 'jump { 1 } target' ),
        undef, "Nothing happens unless we turn on enableSurveyExpressionEngine in config" );
    $session->config->set( 'enableSurveyExpressionEngine', 1 );
    cmp_deeply( $e->run( $session, 'jump { 1 } target' ), { jump => 'target', tags => {} }, "..now we're in business!" );

    my %values = (
        n  => 5,
        s1 => 'my string',
        multi => [ 'answer1', 'answer2' ],
    );

    my %scores = (
        n1 => 1,
        n2 => 2,
    );

    # These should all jump to 'target'
    my @should_jump = (
        q{jump { 1 } target},
        q{jump { return 1 } target},
        q{jump { "string" } target},
        q{jump { value(n) == 5 } target},
        q{jump { value(n) > 0 } target},
        q{jump { value(s1) eq "my string" } target},
        q{jump { value(s1) =~ m/my/ } target},
        q{jump { value(n) == 4 or value(n) == 5 } target},
        q{jump { value(n) == 5 && value(n) > 0 } target},
        q{jump { (value(n) > 1 ? 10 : 11) == 10 } target},
        q{jump { $a=1; $a++; $a++; $a *= 2; $a == 6 } target},
        q{jump { @a = (1..10); $a[0] == 1 && @a == 10 } target},               # arrays
        q{jump { if (value(n) == 5) { 1 } else { 0 } } target},                # if statement
        q{jump { $q2 = 3; $avg = (value(n) + $q2) / 2; $avg == 4 } target},    # look ma, averages!
        q{jump { $q2 = 3; avg(value(n), $q2) == 4 } target},                   # look ma, built-in avg sub!
        q{jump { round(3.456) == 3 && round(3.456, 2) == 3.46 } target},       # rounding
        q{jump { value(n) == 5 } target; jump { value(n) == 5 } targetX},      # first jump wins
        q{jump { value(n) == 0 } targetX; jump { value(n) == 5 } target},      # false jumps ignored
        q{jump { min(3,5,2) == 2 } target},                                    # List::Util min
        q{jump { sum(value(n),1,1,1) == 8 } target},                           # List::Util sum, etc..
        q{jump { score(n1) == 1 && score(n2) == 2 } target},                   # score() works
        q{jump { answered(n) && !answered(X) } target},                        # answered() works
        q{jump { value(multi) eq 'answer1, answer2' } target},                 # multi-answer question stringifies in scalar context
        q{jump { (value(multi))[1] eq 'answer2' } target},                     # multi-answer question returns list in list context
        q{ sub mySub { return $_[0] + 2 } jump { mySub(1) == 3 } target },     # expressions can define and use subs
        q{ jump { (sort { $a <=> $b } ( 5, 4, 3, 2 ))[1] == 3 } target },      # sorting allowed
    );

    my @should_not_jump = (
        q{},                                                                   # empty
        q{ return },                                                           # empty
        q{1},                                                                  # doesn't call jump
        q{blah-dee-blah-blah},                                                 # rubbish expression
        q{jump {} target},                                                     # empty anon sub to jump
        q{jump { 0 } target},                                                  # false sub to jump
        q{jump { value(n) == 500 } target},
        q{jump { value(s1) eq 'blah' } target},
    );
    
    my @should_fail = (
        q|{|,                                                                  # doesn't compile
        q{jump { time } target},                                               # time and other opcodes not allowed
    );

    # These ones should have 'target' as the jump target
    for my $expr (@should_jump) {
        cmp_deeply( $e->run( $session, $expr, { values => \%values, scores => \%scores, tags => {} } ),
            { jump => 'target', tags => {} }, "\"$expr\" jumps as expected" );
    }
    
    # These ones should come back with an undefined jump target
    for my $expr (@should_not_jump) {
        cmp_deeply( $e->run( $session, $expr, { values => \%values, scores => \%scores, tags => {} } ),
            { jump => undef, tags => {} }, "\"$expr\" does not jump" );
    }

    # These ones should return undef (general failure to run)
    for my $expr (@should_fail) {
        is( $e->run( $session, $expr, { values => \%values, scores => \%scores } ),
           undef,, "\"$expr\" fails as expected" );
    }

    $e->run( $session, q{jump {$x = value(s1); $x = 'X'} target}, { values => \%values } );
    is( $values{s1}, 'my string', "Expression can't modify values" );

    like( $e->run( $session, '{', { validate => 1 } ), qr/Missing right curly/, "Validation option works" );

    # Check validTargets option
    cmp_deeply( $e->run( $session, q{jump {1} target}, { values => \%values, validTargets => { a => 1 } } ),
        { jump => undef, tags => {} }, 'target is not valid' );
    cmp_deeply( $e->run( $session, q{jump {1} target}, { values => \%values, validTargets => { target => 1 } } ),
        { jump => 'target', tags => {} }, '..whereas now it is ok' );
    
    # Try some tagging
    cmp_deeply(
        $e->run( $session, q{}, { values => \%values } ),
        { jump => undef, tags => {} },
        'returns empty hash for tags by default'
    );

    cmp_deeply(
        $e->run( $session, q{}, { values => \%values, tags => { a => 1 } } ),
        { jump => undef, tags => { a => 1 } },
        'existing tag values survive'
    );
    cmp_deeply(
        $e->run( $session, q{ tag(a,2) }, { values => \%values, tags => { a => 1 } } ),
        { jump => undef, tags => { a => 2 } },
        '..but can be changed'
    );
    cmp_deeply(
        $e->run( $session, q{ tag(b) }, { values => \%values, tags => { a => 1 } } ),
        { jump => undef, tags => { a => 1, b => 1 } },
        '..and new values can be set (defaults to 1)'
    );
    cmp_deeply(
        $e->run( $session, q{ jump{ tagged(a) } target }, { values => \%values, tags => { a => 1 } } ),
        { jump => 'target', tags => { a => 1 } },
        '..flag can be checked with tagged()'
    );
    cmp_deeply(
        $e->run( $session, q{ jump{ tagged(a) eq 'abc' } target }, { values => \%values, tags => { a => 'abc' } } ),
        { jump => 'target', tags => { a => 'abc' } },
        '..and any sort of tagged data returned'
    );
    cmp_deeply(
        $e->run( $session, q{ tag(a,xyz); jump{ tagged(a) eq 'xyz' } target }, { values => {a => 'def'}, tags => { a => 'abc' } } ),
        { jump => 'target', tags => { a => 'xyz' } },
        '..overwritten tag data can be used too'
    );
    
    # Try the exitUrl sub
    cmp_deeply(
        $e->run( $session, q{ exitUrl(blah)} ),
        { exitUrl => 'blah', tags => { } },
        'explicit exitUrl works'
    );
    cmp_deeply(
        $e->run( $session, q{ exitUrl()} ),
        { exitUrl => undef, tags => { } },
        '..as does unspecified exitUrl'
    );
    
    # Try the restart sub
    cmp_deeply(
        $e->run( $session, q{ restart} ),
        { restart => 1, tags => { } },
        'restart works'
    );

    # Create a test user
    $user = WebGUI::User->new( $session, 'new' );
    WebGUI::Test->addToCleanup($user);
    
    # Create a Survey
    $versionTag = WebGUI::VersionTag->getWorking($session);
    $survey = WebGUI::Asset->getImportNode($session)->addChild(
        {   className                => 'WebGUI::Asset::Wobject::Survey',
        },
    );
    isa_ok($survey, 'WebGUI::Asset::Wobject::Survey');
    my $url = $survey->get('url');
    my $id = $survey->getId;
    
    $survey->surveyJSON->newObject([]); # s0
    $survey->surveyJSON->newObject([0]); # s0q0
    $survey->surveyJSON->newObject([0,0]); # s0q0a0
    $survey->surveyJSON->newObject([0]); # s0q1
    $survey->surveyJSON->newObject([0,1]); # s0q1a0
    
    $survey->surveyJSON->section([0])->{variable} = 'ext_s0';
    $survey->surveyJSON->question([0,0])->{variable} = 'ext_s0q0';
    $survey->surveyJSON->question([0,1])->{variable} = 'ext_s0q1';
    $survey->surveyJSON->answer([0,0,0])->{recordedAnswer} = 'ext_s0q0a0';
    $survey->surveyJSON->answer([0,0,0])->{value} = 150; # worth 150 points
    $survey->surveyJSON->answer([0,1,0])->{recordedAnswer} = 'ext_s0q1a0';
    $survey->surveyJSON->answer([0,1,0])->{value} = 50; # worth 50 points
    
    my $responseId = $survey->responseId( { userId => $user->userId } );
    
    my $rJSON = $survey->responseJSON(undef, $responseId);
    $rJSON->recordResponses({
        '0-0-0'        => 'My ext_s0q0a0 answer',
        '0-1-0'        => 'My ext_s0q1a0 answer',
    });
    $rJSON->processExpression(q{ tag(ext_tag, 199) });
    
    # Remember to persist our changes..
    $survey->persistSurveyJSON();
    $survey->persistResponseJSON();
    $survey->surveyEnd;
    
    cmp_deeply( $e->run( $session, qq{jump {valueX('$id', ext_s0q0) eq 'ext_s0q0a0'} target}, {userId => $user->userId} ),
        { jump => 'target', tags => {} }, 'external value resolves ok when id used' );
    cmp_deeply( $e->run( $session, qq{jump {valueX('$url', ext_s0q0) eq 'ext_s0q0a0'} target}, {userId => $user->userId} ),
        { jump => 'target', tags => {} }, 'external value resolves ok when url used' );
    cmp_deeply( $e->run( $session, qq{jump {scoreX('$url', ext_s0q0) == 150} target}, {userId => $user->userId} ),
        { jump => 'target', tags => {} }, 'external score resolves ok too' );
    cmp_deeply( $e->run( $session, qq{jump {scoreX('$url', ext_s0) == 200} target}, {userId => $user->userId} ),
        { jump => 'target', tags => {} }, 'external score section totals work too' );
    cmp_deeply( $e->run( $session, qq{jump {taggedX('$url', ext_tag) == 199} target}, {userId => $user->userId} ),
        { jump => 'target', tags => {} }, 'external tag lookups work too' );
    
    # Test for nasty bugs caused by file-scoped lexicals not being properly initialised in L<ExpressionEngine::run>
    {
        # Create a second test user
        my $survey2 = WebGUI::Asset::Wobject::Survey->new($session, $survey->getId);
        my $user2 = WebGUI::User->new( $session, 'new' );
        WebGUI::Test->addToCleanup($user2);
        $session->user({userId => $user2->userId});
        my $responseId2 = $survey2->responseId( { userId => $user2->userId } );
        my $rJSON2 = $survey2->responseJSON(undef, $responseId2);
        $rJSON2->recordResponses({
            '0-0-0'        => 'My ext_s0q0a0 answer',
            '0-1-0'        => 'My ext_s0q1a0 answer',
        });
        $rJSON2->processExpression(q{ tag(ext_tag, 299) });
        # Remember to persist our changes..
        $survey2->persistSurveyJSON();
        $survey2->persistResponseJSON();
        $survey2->surveyEnd;
        
        cmp_deeply( $e->run( $session, qq{jump {taggedX('$url', ext_tag) == 299} target}, {userId => $user2->userId} ),
            { jump => 'target', tags => {} }, 'external tag not cached' );
        
        cmp_deeply( $e->run( $session, qq{jump {taggedX('$url', ext_tag) == 199} target}, {userId => $user->userId} ),
            { jump => 'target', tags => {} }, 'first external tag lookups still works' );
    }
}

#----------------------------------------------------------------------------
# Cleanup
END { 
    $survey->purge if $survey;
    $versionTag->rollback if $versionTag;
}
