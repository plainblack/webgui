# Tests CRUD operations on WebGUI::Flux::Rule
#
# N.B. Perform Devel::Cover test via:
# cover -delete -silent && perl -MDevel::Cover=-ignore,.,-select,lib/WebGUI/Flux/Rule t/Flux/Rule/Rule.t && cover

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Exception::Class;

use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 26;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Flux::Rule');

SKIP: {

    skip 'Unable to load module WebGUI::Flux::Rule', $tests unless $loaded;
    my $e;
    my $rule;

    #######################################################################
    #
    # new
    #
    #######################################################################

    # N.B. Just test for failures here - we test successful retrieval
    # later after we've successfully create()'ed a Rule

    eval { $rule = WebGUI::Flux::Rule->new(); };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object' );
    cmp_deeply(
        $e,
        methods(
            error    => 'Need a session.',
            expected => 'WebGUI::Session',
            got      => '',
        ),
        'new takes exception to not giving it a session object',
    );

    eval { $rule = WebGUI::Flux::Rule->new($session); };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a fluxRuleId' );
    cmp_deeply( $e, methods( error => 'Need a fluxRuleId.', ), 'new takes exception to not giving it a rule Id', );

    eval { $rule = WebGUI::Flux::Rule->new( $session, 'neverAGUID' ); };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::ObjectNotFound', 'new takes exception to not giving it an existing fluxRuleId' );
    cmp_deeply(
        $e,
        methods(
            error => 'No such Flux Rule.',
            id    => 'neverAGUID',
        ),
        'new takes exception to not giving it a rule Id',
    );

    #######################################################################
    #
    # create
    #
    #######################################################################

    eval { $rule = WebGUI::Flux::Rule->create(); };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it a session object' );
    cmp_deeply(
        $e,
        methods(
            error    => 'Need a session.',
            expected => 'WebGUI::Session',
            got      => '',
        ),
        'create takes exception to not giving it a session object',
    );

    eval { $rule = WebGUI::Flux::Rule->create( $session, "not a hash ref" ); };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'create takes exception to an invalid hash ref' );
    cmp_deeply(
        $e,
        methods( error => 'Invalid hash reference.', ),
        'create takes exception to an invalid hash ref',
    );

    # Create Rule with all defaults
    $rule = WebGUI::Flux::Rule->create($session);
    isa_ok( $rule, 'WebGUI::Flux::Rule', 'create returns the right kind of object' );
    my $ruleCount = $session->db->quickScalar('select count(*) from fluxRule');
    is( $ruleCount, 1, 'only 1 Flux Rule was created' );
    
    # Check Rule properties
    isa_ok( $rule->session, 'WebGUI::Session', 'session method returns a session object' );
    is( $session->getId, $rule->session->getId, 'session method returns OUR session object' );
    ok( $session->id->valid( $rule->getId ), 'create makes a valid GUID style fluxRuleId' );
    
    # Check Rule defaults
    is( $rule->get('name'),   'Undefined', 'default value for name is "Undefined"' );
    is( $rule->get('sticky'), 0,           'default value for sticky is 0' );

    #######################################################################
    #
    # getId
    #
    #######################################################################

    is( $rule->getId, $rule->get('fluxRuleId'), 'getId is a shortcut for ->get' );

    # TODO: Awaiting Flux::Expression implementation

    #    #######################################################################
    #    #
    #    # addExpression
    #    #
    #    #######################################################################
    #
    #    my $expression1 = $rule->addExpression( { label => q{Red's cell} } );
    #    isa_ok( $expression1, 'WebGUI::Flux::Expression', 'addExpression returns an object' );
    #
    #    my $expression2 = $rule->addExpression( { label => q{Norton's office} } );
    #
    #    #######################################################################
    #    #
    #    # getExpressiones
    #    #
    #    #######################################################################
    #
    #    my @expressions = @{ $rule->getExpressiones() };
    #
    #    cmp_deeply(
    #        \@expressions,
    #        [ $expression1, $expression2 ],
    #        'getExpressiones returns all expression objects for this Rule'
    #    );

    #######################################################################
    #
    # update
    #
    #######################################################################

    $rule->update(
        {   name               => 'New Name',
            sticky             => 1,
            combinedExpression => 'abc'
        }
    );

    cmp_deeply(
        $rule->get(),
        superhashof(    # ignore the workflowIds
            {   fluxRuleId         => ignore,
                name               => 'New Name',
                sticky             => 1,
                combinedExpression => 'abc',
            }
        ),
        'update updates the object properties cache'
    );

    my $clonedRule = WebGUI::Flux::Rule->new( $session, $rule->getId );

    cmp_deeply( $clonedRule, $rule, 'update persists to the db, too' );
    
    # Create a Rule with explicit properties (which should get passed to update())
    my $secondRule = WebGUI::Flux::Rule->create($session, {
        name => 'Not Undefined',
        sticky => 1,
    });
    isa_ok( $secondRule, 'WebGUI::Flux::Rule', 'create returns the right kind of object' );
    is( $secondRule->get('name'),   'Not Undefined', 'explicitly set value for name sticks' );
    is( $secondRule->get('sticky'), 1,           'explicitly set value for sticky sticks' );
    
    #######################################################################
    #
    # delete
    #
    #######################################################################

    $ruleCount = $session->db->quickScalar('select count(*) from fluxRule');
    is( $ruleCount, 2, '2 Rules to delete' );
    
    my $expressionCount = $session->db->quickScalar('select count(*) from fluxExpression');
    # TODO: expression_count test once Flux::Expression implemented

    $clonedRule->delete();
    $secondRule->delete();
    $ruleCount = $session->db->quickScalar('select count(*) from fluxRule');
    $expressionCount = $session->db->quickScalar('select count(*) from fluxExpression');

    is( $ruleCount, 0, 'Rule deleted' );
    is( $expressionCount, 0, 'delete also deletes associated expressions' );
    undef $rule;

}

END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
}