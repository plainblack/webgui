# Tests CRUD operations on WebGUI::Flux::Rule
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Exception::Class;

use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Flux::Expression;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 39;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Rule');
$session->user( { userId => 1 } );
my $user   = $session->user();
my $userId = $user->userId();

#######################################################################
#
# new
#
#######################################################################

# N.B. Just test for failures here - we test successful retrieval
# later after we've successfully create()'ed a Rule

{
    eval { my $rule = WebGUI::Flux::Rule->new(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object' );
    cmp_deeply(
        $e,
        methods(
            error    => 'Need a session.',
            expected => 'WebGUI::Session',
            got      => q{},
        ),
        'new takes exception to not giving it a session object',
    );
}
{
    eval { my $rule = WebGUI::Flux::Rule->new($session); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a fluxRuleId' );
    cmp_deeply( $e, methods( error => 'Need a fluxRuleId.', ), 'new takes exception to not giving it a rule Id', );
}
{
    eval { my $rule = WebGUI::Flux::Rule->new( $session, 'neverAGUID' ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::ObjectNotFound', 'new takes exception to not giving it an existing fluxRuleId' );
    cmp_deeply(
        $e,
        methods(
            error => 'No such Flux Rule.',
            id    => 'neverAGUID',
        ),
        'new takes exception to not giving it a rule Id',
    );
}

#######################################################################
#
# create
#
#######################################################################
{
    eval { my $rule = WebGUI::Flux::Rule->create(); };
    my $e = Exception::Class->caught();
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
}
{
    eval { my $rule = WebGUI::Flux::Rule->create( $session, 'not a hash ref' ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidNamedParamHashRef', 'create takes exception to an invalid hash ref' );
    cmp_deeply( $e, methods( param => 'not a hash ref', ), 'create takes exception to an invalid hash ref', );
}
{

    # Create Rule with all defaults
    my $rule = WebGUI::Flux::Rule->create($session);
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
}

#######################################################################
#
# getId
#
#######################################################################
{
    my $rule = WebGUI::Flux::Rule->create($session);
    is( $rule->getId, $rule->get('fluxRuleId'), 'getId is a shortcut for ->get' );
}

#######################################################################
#
# addExpression
#
#######################################################################
{
    my $rule = WebGUI::Flux::Rule->create($session);

    # Create Expression
    my $expression = $rule->addExpression(
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    isa_ok( $expression, 'WebGUI::Flux::Expression', 'addExpression returns an object' );
    is( $expression->rule()->getId(), $rule->getId, 'Expression belongs to OUR Rule' );
}

#######################################################################
#
# getExpressiones
#
#######################################################################
{
    my $rule = WebGUI::Flux::Rule->create($session);

    # Create Expression
    my $expression1 = $rule->addExpression(
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    my $expression2 = $rule->addExpression(
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    my @expressions = @{ $rule->getExpressions() };

    cmp_deeply(
        \@expressions,
        [ $expression1, $expression2 ],
        'getExpressiones returns all expression objects for this Rule'
    );
}
#######################################################################
#
# update
#
#######################################################################
{
    my $rule = WebGUI::Flux::Rule->create($session);
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
    my $secondRule = WebGUI::Flux::Rule->create(
        $session,
        {   name   => 'Not Undefined',
            sticky => 1,
        }
    );
    isa_ok( $secondRule, 'WebGUI::Flux::Rule', 'create returns the right kind of object' );
    is( $secondRule->get('name'), 'Not Undefined', 'explicitly set value for name sticks' );
    is( $secondRule->get('sticky'), 1, 'explicitly set value for sticky sticks' );
}

#######################################################################
#
# delete
#
#######################################################################
{

    # Start with a clean slate
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');

    my $rule1 = WebGUI::Flux::Rule->create($session);
    $rule1->addExpression(
        {   name     => 'Rule 1 Expression #1',
            operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    my $rule2 = WebGUI::Flux::Rule->create($session);
    $rule2->addExpression(
        {   name     => 'Rule 2 Expression #1',
            operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    $rule2->addExpression(
        {   name     => 'Rule 2 Expression #2',
            operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    is( $session->db->quickScalar('select count(*) from fluxRule'),       2, '2 Rules to delete' );
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 3, '3 Expressions to delete' );

    # Delete Rule1 and its associated Expressions
    $rule1->delete();
    is( $session->db->quickScalar('select count(*) from fluxRule'),       1, '1 Rules left to delete' );
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 2, '2 Expressions left to delete' );

    $rule2->delete();
    is( $session->db->quickScalar('select count(*) from fluxRule'),       0, 'No Rules left to delete' );
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 0, 'No Expressions left to delete' );
}

#######################################################################
#
# evaluate()
#
#######################################################################
{
    my $rule   = WebGUI::Flux::Rule->create($session);
    my $ruleId = $rule->getId();

    ok( $rule->evaluate( { user => $user } ), 'empty rule allows access by default' );
    is( _secondsFromNow(
            WebGUI::DateTime->new(
                $session->db->quickScalar(
                    'select dateRuleFirstChecked from fluxRuleUserData where fluxRuleId=? and userId=?',
                    [ $ruleId, $userId ]
                )
            )
        ),
        0,
        'dateRuleFirstChecked updated'
    );
    is( _secondsFromNow(
            WebGUI::DateTime->new(
                $session->db->quickScalar(
                    'select dateRuleFirstTrue from fluxRuleUserData where fluxRuleId=? and userId=?',
                    [ $ruleId, $userId ]
                )
            )
        ),
        0,
        'dateRuleFirstTrue updated'
    );
    is( $session->db->quickScalar(
            'select dateRuleFirstFalse from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $ruleId, $userId ]
        ),
        undef,
        'dateRuleFirstFalse not updated'
    );
    # TODO: check access-related fields, once access-related logic implemented

    # Add a single expression to the rule
    $rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluate( { user => $user } ), q{"test value" == "test value"} );

    # add a second expression to the Rule
    $rule->addExpression(
        {   operand1     => 'NumericValue',
            operand1Args => '{"value":  120}',
            operand2     => 'NumericValue',
            operand2Args => '{"value":  121}',
            operator     => 'IsLessThan',
        }
    );
    ok( $rule->evaluate( { user => $user } ), q{120 < 121} );
}

sub _secondsFromNow {
    my $dt = shift;
    return WebGUI::DateTime->now()->subtract_datetime($dt)->in_units('seconds');
}

END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
}
