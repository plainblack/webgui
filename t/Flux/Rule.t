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
use WebGUI::Workflow;
use WebGUI::Group;
use Test::Exception;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
WebGUI::Error->Trace(1);

#----------------------------------------------------------------------------
# Tests

plan tests => 83;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Rule');
$session->user( { userId => 1 } );
my $user   = $session->user();
my $userId = $user->userId();

# Start with a clean slate
$session->db->write('delete from fluxRule');
$session->db->write('delete from fluxExpression');
$session->db->write('delete from fluxRuleUserData');

#######################################################################
#
# new
#
#######################################################################

# N.B. Just test for failures here - we test successful retrieval
# later after we've successfully create()'ed a Rule

{
    throws_ok { WebGUI::Flux::Rule->new() } 'WebGUI::Error::InvalidParam',
        'new takes exception to not giving it a session object';
    throws_ok { WebGUI::Flux::Rule->new($session) } 'WebGUI::Error::InvalidParam',
        'new takes exception to not giving it a fluxRuleId';
    throws_ok { WebGUI::Flux::Rule->new( $session, 'neverAGUID' ) } 'WebGUI::Error::ObjectNotFound',
        'new takes exception to not giving it an existing fluxRuleId';
}

#######################################################################
#
# create
#
#######################################################################
{
    throws_ok { WebGUI::Flux::Rule->create() } 'WebGUI::Error::InvalidParam',
        'create takes exception to not giving it a session object';
    throws_ok { WebGUI::Flux::Rule->create( $session, 'not a hash ref' ) } 'WebGUI::Error::InvalidParam',
        'create takes exception to an invalid hash ref';
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
{

    # Create Rule with custom fluxRuleId
    my $rule = WebGUI::Flux::Rule->create( $session, { fluxRuleId => 'myChosenFluxRuleId' } );
    isa_ok( $rule, 'WebGUI::Flux::Rule', 'create returns the right kind of object' );
    is( $rule->getId, 'myChosenFluxRuleId', 'with our chosen fluxRuleId' );
    is( WebGUI::Flux->getRule( $session, 'myChosenFluxRuleId' )->getId,
        $rule->getId, 'and we can retreive it via id' );
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
            operator => 'DUMMY_OPERATOR',
            operand2 => 'DUMMY_OPERAND_2',
        }
    );
    isa_ok( $expression, 'WebGUI::Flux::Expression', 'addExpression returns an object' );
    is( $expression->rule()->getId(), $rule->getId, 'Expression belongs to OUR Rule' );
}

#######################################################################
#
# getExpressiones / getExpressionCount
#
#######################################################################
{
    my $rule = WebGUI::Flux::Rule->create($session);

    # Create Expression
    my $expression1 = $rule->addExpression(
        {   operand1 => 'DUMMY_OPERAND_1',
            operator => 'DUMMY_OPERATOR',
            operand2 => 'DUMMY_OPERAND_2',
        }
    );
    my $expression2 = $rule->addExpression(
        {   operand1 => 'DUMMY_OPERAND_1',
            operator => 'DUMMY_OPERATOR',
            operand2 => 'DUMMY_OPERAND_2',
        }
    );
    my @expressions = @{ $rule->getExpressions() };

    cmp_deeply(
        \@expressions,
        [ $expression1, $expression2 ],
        'getExpressiones returns all expression objects for this Rule'
    );

    is( $rule->getExpressionCount(), 2, 'getExpressionCount counts correctly' );
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
            combinedExpression => undef,
        }
    );

    cmp_deeply(
        $rule->get(),
        superhashof(    # ignore the workflowIds
            {   fluxRuleId         => ignore,
                name               => 'New Name',
                sticky             => 1,
                combinedExpression => undef,
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
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );
    my $rule2 = WebGUI::Flux::Rule->create($session);
    $rule2->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );
    $rule2->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );
    is( $session->db->quickScalar('select count(*) from fluxRule'),       2, '2 Rules to delete' );
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 3, '3 Expressions to delete' );

    # Evaluate rule so that fluxRuleUserDate row created
    $rule1->evaluateFor( { user => $user, } );
    is( $session->db->quickScalar(
            'select count(*) from fluxRuleUserData where fluxRuleId = ?',
            [ $rule1->getId() ]
        ),
        1,
        '1 Associated fluxRuleUserData row'
    );

    # Delete Rule1 and its associated Expressions
    $rule1->delete();
    is( $session->db->quickScalar('select count(*) from fluxRule'),       1, '1 Rules left to delete' );
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 2, '2 Expressions left to delete' );
    is( $session->db->quickScalar(
            'select count(*) from fluxRuleUserData where fluxRuleId = ?',
            [ $rule1->getId() ]
        ),
        0,
        'Associated fluxRuleUserData row deleted'
    );

    $rule2->delete();
    is( $session->db->quickScalar('select count(*) from fluxRule'),       0, 'No Rules left to delete' );
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 0, 'No Expressions left to delete' );
}

#######################################################################
#
# evaluate() and combinedExpression
#
#######################################################################
{
    my $rule   = WebGUI::Flux::Rule->create($session);
    my $ruleId = $rule->getId();

    ok( $rule->evaluateFor( { user => $user, } ), 'empty rule allows access by default' );
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

    # Add a single expression to the rule
    $rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), q{"test value" == "test value"} );

    # Try out some Combined Expressions
    $rule->update( { combinedExpression => 'E1' } );
    ok( $rule->evaluateFor( { user => $user } ), q{same with explicit combined expression 'E1'} );
    $rule->update( { combinedExpression => 'not E1' } );
    ok( !$rule->evaluateFor( { user => $user } ), q{false with explicit combined expression 'not E1'} );
    $rule->update( { combinedExpression => ' E1 ' } );
    ok( $rule->evaluateFor( { user => $user } ), q{whitespace ok'} );

    # add a second expression to the Rule with a Modifier

    # Create a sample DateTime string, usually this would come from the db
    # and hence always be in UTC
    my $dt = DateTime->new(
        year      => 1984,
        month     => 10,
        day       => 16,
        hour      => 16,
        minute    => 12,
        second    => 47,
        time_zone => 'UTC',
    );
    my $dbDateTime = WebGUI::DateTime->new( $dt->epoch() )->toDatabase();
    $rule->addExpression(
        {   operand1             => 'DateTime',
            operand1Args         => qq[{"value":  "$dbDateTime"}],
            operand1Modifier     => 'DateTimeFormat',
            operand1ModifierArgs => qq[{"pattern": "%x %X", "time_zone": "UTC"}],
            operator             => 'IsEqualTo',
            operand2             => 'TextValue',
            operand2Args         => '{"value":  "Oct 16, 1984 4:12:47 PM"}',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), q{true with two expressions and no cE} );
    $rule->update( { combinedExpression => 'E1 and E2' } );
    ok( $rule->evaluateFor( { user => $user, } ), q{true with explicit combined expression 'E1 and E2'} );
    $rule->update( { combinedExpression => 'not(not E1 or not E2)' } );
    ok( $rule->evaluateFor( { user => $user, } ),
        q{true with explicit combined expression 'not(not E1 or not E2)'} );
    $rule->update( { combinedExpression => '(not E1 or not E2)' } );
    ok( !$rule->evaluateFor( { user => $user, } ),
        q{false with explicit combined expression '(not E1 or not E2)'} );
    $rule->update( { combinedExpression => 'E1' } );
    ok( $rule->evaluateFor( { user => $user, } ), q{true with cE that doesn't mention E2 'E1'} );

    # add a third (false) expression with a combined expression
    $rule->addExpression(
        {   operand1     => 'NumericValue',
            operand1Args => '{"value":  10}',
            operator     => 'IsLessThan',
            operand2     => 'NumericValue',
            operand2Args => '{"value":  5}',
        }
    );
    ok( !$rule->evaluateFor( { user => $user, } ), q{false with no cE bc E3 is false} );
    $rule->update( { combinedExpression => 'E1 AND E2' } );
    ok( $rule->evaluateFor( { user => $user, } ), q{true with cE that doesn't mention E3} );
    $rule->update( { combinedExpression => 'E1 AND E2 AND NOT E3' } );
    ok( $rule->evaluateFor( { user => $user, } ), q{true with cE 'E1 AND E2 AND NOT E3'} );
    $rule->update( { combinedExpression => 'E1 AND E1 AND E1' } );
    ok( $rule->evaluateFor( { user => $user, } ), q{true with cE 'E1 AND E1 AND E1'} );

    # try some invalid combinedExpressions
    $rule->update( { combinedExpression => '(' } );
    throws_ok { $rule->evaluateFor( { user => $user, } ) } 'WebGUI::Error::Flux::InvalidCombinedExpression',
        q{evaluate takes exception to cE '('};

    $rule->update( { combinedExpression => 'E1 E2' } );
    throws_ok { $rule->evaluateFor( { user => $user, } ) } 'WebGUI::Error::Flux::InvalidCombinedExpression',
        q{evaluate takes exception to cE 'E1 E2'};

    $rule->update( { combinedExpression => 'AND' } );
    throws_ok { $rule->evaluateFor( { user => $user, } ) } 'WebGUI::Error::Flux::InvalidCombinedExpression',
        q{evaluate takes exception to cE 'AND'};

    $rule->update( { combinedExpression => 'E1 AND E2 )' } );
    throws_ok { $rule->evaluateFor( { user => $user, } ) } 'WebGUI::Error::Flux::InvalidCombinedExpression',
        q{evaluate takes exception to cE 'E1 AND E2 )'};

}

# Explicitly test for a bug I found during early development: 
# Rule that was initiallly false wouldn't update dateRuleFirstTrue when it became true
{
    my $rule   = WebGUI::Flux::Rule->create($session);
    my $ruleId = $rule->getId();
    $rule->addExpression(
        {   operand1     => 'NumericValue',
            operand1Args => '{"value":  0}',
            operator     => 'IsEqualTo',
            operand2     => 'NumericValue',
            operand2Args => '{"value":  42}',
        }
    );
    ok( !$rule->evaluateFor( { user => $user, } ), q{initially false} );
    ok( $session->db->quickScalar(
            'select dateRuleFirstFalse from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $ruleId, $userId ]
        ),
        'dateRuleFirstFalse set'
    );
    is( $session->db->quickScalar(
            'select dateRuleFirstTrue from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $ruleId, $userId ]
        ),
        undef,
        'dateRuleFirstTrue not set yet'
    );
    $rule->update( { combinedExpression => 'not E1' } );
    ok( $rule->evaluateFor( { user => $user, } ), q{now true} );
    ok( $session->db->quickScalar(
            'select dateRuleFirstFalse from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $ruleId, $userId ]
        ),
        'dateRuleFirstFalse still set'
    );
    ok( $session->db->quickScalar(
            'select dateRuleFirstTrue from fluxRuleUserData where fluxRuleId=? and userId=?',
            [ $ruleId, $userId ]
        ),
        'dateRuleFirstTrue now set'
    );
}

# Workflows
my $test_group = WebGUI::Group->new( $session, 'new' );
my $test_workflow = WebGUI::Workflow->create(
    $session,
    {   title       => 'Flux Test Workflow',
        description => 'Flux Test Workflow',
        enabled     => 1,
    }
);
use WebGUI::Workflow::Activity::AddUserToGroup;
{

    # Use the AddUserToGroup Workflow as a Guinea pig to test onRuleFirstTrueWorkflowId..
    my $activity = WebGUI::Workflow::Activity::AddUserToGroup->create( $session, $test_workflow->getId() );
    $activity->set( 'groupId', $test_group->getId() );
    ok( !$user->isInGroup( $test_group->getId() ), 'User not yet added to group by Workflow' );
    is_deeply( $test_workflow->getInstances, [], 'workflow has no instances (yet)' );

    # Create a rule that will run AddUserToGroup on execution
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->update( { onRuleFirstTrueWorkflowId => $test_workflow->getId() } );
    $rule->evaluateFor( { user => $user, } );
    
    wait_for_workflow($session, $test_workflow->getId());
    $test_group->clearCaches(); # Group modified by spectre so need to re-retreive from db

    # Workflow should have now completed and user should be a member of the new group
    ok( $user->isInGroup( $test_group->getId() ), 'User added to group by Workflow' );

    # Clean up
    $activity->delete();
}
{

    # Try again with onAccessTrueWorkflowId..
    $test_group->delete();
    $test_group = WebGUI::Group->new( $session, 'new' );

    my $activity = WebGUI::Workflow::Activity::AddUserToGroup->create( $session, $test_workflow->getId() );
    $activity->set( 'groupId', $test_group->getId() );
    ok( !$user->isInGroup( $test_group->getId() ), 'User not yet added to group by Workflow' );
    is_deeply( $test_workflow->getInstances, [], 'workflow has no instances (yet)' );

    # Create a rule that will run AddUserToGroup on execution
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->update( { onAccessTrueWorkflowId => $test_workflow->getId() } );
    $rule->evaluateFor( { user => $user, } );
    
    wait_for_workflow($session, $test_workflow->getId());
    $test_group->clearCaches(); # Group modified by spectre so need to re-retreive from db

    # Workflow should have now completed and user should be a member of the new group
    ok( $user->isInGroup( $test_group->getId() ), 'User added to group by Workflow' );

    # Clean up
    $activity->delete();
}
{

    # Try again with onAccessFirstFalseWorkflowId..
    $test_group->delete();
    $test_group = WebGUI::Group->new( $session, 'new' );

    my $activity = WebGUI::Workflow::Activity::AddUserToGroup->create( $session, $test_workflow->getId() );
    $activity->set( 'groupId', $test_group->getId() );
    ok( !$user->isInGroup( $test_group->getId() ), 'User not yet added to group by Workflow' );
    is_deeply( $test_workflow->getInstances, [], 'workflow has no instances (yet)' );

    # Create a rule that will run AddUserToGroup on execution
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(    # Add an expression that will fail, kaaboom!
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "apples"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "oranges"}',
        }
    );
    $rule->update( { onAccessFirstFalseWorkflowId => $test_workflow->getId() } );
    $rule->evaluateFor( { user => $user, } );
    
    wait_for_workflow($session, $test_workflow->getId());
    $test_group->clearCaches(); # Group modified by spectre so need to re-retreive from db

    # Workflow should have now completed and user should be a member of the new group
    ok( $user->isInGroup( $test_group->getId() ), 'User added to group by Workflow' );

    # Clean up
    $activity->delete();
}

#######################################################################
#
# checkCombinedExpression
#
#######################################################################
# Errors
{
    throws_ok { WebGUI::Flux::Rule::checkCombinedExpression() } 'WebGUI::Error::InvalidParam',
        'takes exception to invalid param count';
    throws_ok { WebGUI::Flux::Rule::checkCombinedExpression( 'E0', 0 ) }
    'WebGUI::Error::Flux::InvalidCombinedExpression', q{'E0' is invalid};
    throws_ok { WebGUI::Flux::Rule::checkCombinedExpression( 'E1', 0 ) }
    'WebGUI::Error::Flux::InvalidCombinedExpression', q{'E1' with 0 expressions is invalid};
    throws_ok { WebGUI::Flux::Rule::checkCombinedExpression( 'blah', 0 ) }
    'WebGUI::Error::Flux::InvalidCombinedExpression', q{'blah' is invalid};
    throws_ok { WebGUI::Flux::Rule::checkCombinedExpression( 'ANDNOTOR', 0 ) }
    'WebGUI::Error::Flux::InvalidCombinedExpression', q{'ANDNOTOR' is invalid};
}
{
    ok( WebGUI::Flux::Rule::checkCombinedExpression( q{},         0 ), q{empty expression is valid} );
    ok( WebGUI::Flux::Rule::checkCombinedExpression( 'E1',        1 ), q{'E1' with 1 exp is valid} );
    ok( WebGUI::Flux::Rule::checkCombinedExpression( 'E1 and E2', 2 ), q{'E1 and E2' with 2 exps is valid} );
    ok( WebGUI::Flux::Rule::checkCombinedExpression( 'E1 AND E2', 2 ), q{'E1 AND E2' with 2 exps is valid} );
    ok( WebGUI::Flux::Rule::checkCombinedExpression( '(', 2 ),
        q{'(' is valid (we rely on eval to catch this elsewhere)}
    );
    ok( WebGUI::Flux::Rule::checkCombinedExpression( 'E1 E2', 2 ),
        q{'E1 E2' is valid (we rely on eval to catch this elsewhere)}
    );
}

#######################################################################
#
# _parseCombinedExpression
#
#######################################################################
{
    throws_ok { WebGUI::Flux::Rule::_parseCombinedExpression() } 'WebGUI::Error::InvalidParam',
        'takes exception to invalid param count';

    is( WebGUI::Flux::Rule::_parseCombinedExpression('e1 and e2'),
        '$expressions[1]->evaluate() and $expressions[2]->evaluate()',
        'combined expression parsed correctly into internal form'
    );
}

#-------------------------------------------------------------------
sub _secondsFromNow {
    my $dt = shift;
    return WebGUI::DateTime->now()->subtract_datetime($dt)->in_units('seconds');
}

sub wait_for_workflow {
    my $session = shift;
    my $workflow_id = shift;
    my $wf = WebGUI::Workflow->new($session, $workflow_id);
    my $maxwait = 50;
    my $ctr = 0;
    
    while (my @instances = @{$wf->getInstances()}) {
        my $status = $instances[0]->get('lastStatus') || 'undefined';
        diag("Waiting for workflow: $workflow_id. Status $status. " . ($maxwait - $ctr) . " tries remaining.");
        last if $ctr++ > $maxwait;
        sleep 1;
    }
}

END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
    $test_group->delete()    if $test_group;
    $test_workflow->delete() if $test_workflow;
}
