# Tests WebGUI::Flux::Operand::FluxRule
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux::Rule;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 8;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::FluxRule');
$session->user( { userId => 1 } );
my $user = $session->user();

{

    # Create a simple rule that evaluates to true
    my $simple_rule    = WebGUI::Flux::Rule->create($session);
    my $simple_rule_id = $simple_rule->getId();
    $simple_rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );

    # Create a rule that is dependent on the simple rule
    my $dependent_rule    = WebGUI::Flux::Rule->create($session);
    my $dependent_rule_id = $dependent_rule->getId();
    $dependent_rule->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$simple_rule_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
        }
    );

    ok( $dependent_rule->evaluateFor( { user => $user, }), q{Dependent rule true} );
    $simple_rule->update( { combinedExpression => 'not E1' } );
    ok( !$dependent_rule->evaluateFor( { user => $user, }), q{Dependent rule false when simple rule toggled} );
    $dependent_rule->update( { combinedExpression => 'not E1' } );
    ok( $dependent_rule->evaluateFor( { user => $user, }), q{Double-negative is true} );

    # make $simple_rule circular by pointing it back at dependent_rule
    $simple_rule->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$dependent_rule_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
        }
    );
    {
        eval { $dependent_rule->evaluateFor( { user => $user, }) };
        my $e = Exception::Class->caught();
        isa_ok(
            $e,
            'WebGUI::Error::Flux::CircularRuleLoopDetected',
            q{evaluateFor takes exception to circular rule}
        );
    }

    # Create a rule that depends on itself
    my $self_circular_rule    = WebGUI::Flux::Rule->create($session);
    my $self_circular_rule_id = $self_circular_rule->getId();
    $self_circular_rule->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$self_circular_rule_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
        }
    );
    {
        eval { $self_circular_rule->evaluateFor( { user => $user, }) };
        my $e = Exception::Class->caught();
        isa_ok(
            $e,
            'WebGUI::Error::Flux::CircularRuleLoopDetected',
            q{evaluateFor takes exception to self circular rule}
        );
    }
}

# Exercise the resolvedRuleCache
{

    # Create a simple rule that evaluates to true
    my $simple_rule    = WebGUI::Flux::Rule->create($session);
    my $simple_rule_id = $simple_rule->getId();
    $simple_rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );

    # Create a rule that is twice-dependent on the simple rule
    my $dependent_rule    = WebGUI::Flux::Rule->create($session);
    my $dependent_rule_id = $dependent_rule->getId();
    $dependent_rule->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$simple_rule_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
        }
    );
    $dependent_rule->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$simple_rule_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
        }
    );

    ok( $dependent_rule->evaluateFor( { user => $user, }), q{Twice-dependent rule true} );
    $dependent_rule->update( { combinedExpression => 'not(not E1 or not E2)' } );
    ok( $dependent_rule->evaluateFor( { user => $user, }), q{Twice-dependent rule works with a cE too} );

    # TODO: improve the above test to check that the resolvedRuleCache was actually used
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
