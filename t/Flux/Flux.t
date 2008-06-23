# Tests WebGUI::Flux
#
# Coverage:
# cover -delete -silent /tmp/fluxcvr && \
# HARNESS_PERL_SWITCHES='-MDevel::Cover=-db,/tmp/fluxcvr,-ignore,.,-select,lib/WebGUI/Flux' \
# prove -r t/Flux && cover /tmp/fluxcvr
#
# Profiling:
# FASTPROF_CONFIG='filename=/tmp/fluxprof' HARNESS_PERL_SWITCHES='-d:FastProf' prove -r t/Flux
# fprofpp -f/tmp/fluxprof -t5

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
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
plan tests => 18;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux');

# Start with a clean slate
$session->db->write('delete from fluxRule');
$session->db->write('delete from fluxRuleUserData');
$session->db->write('delete from fluxExpression');

#######################################################################
#
# getRules
#
#######################################################################
# Errors
{
    eval { my $rule = WebGUI::Flux->getRules(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'takes exception to not giving it a session object' );
    cmp_deeply(
        $e,
        methods(
            error    => 'Need a session.',
            expected => 'WebGUI::Session',
            got      => '',
        ),
        'takes exception to not giving it a session object',
    );
}

# Single Rule
{
    cmp_deeply( WebGUI::Flux->getRules($session), [], 'initially no rules defined' );

    # Create a test Rule (with all defaults)
    my $rule1 = WebGUI::Flux::Rule->create($session);
    cmp_deeply( WebGUI::Flux->getRules($session), [$rule1], 'rule1 is the only rule defined' );
    $rule1->delete();
    undef $rule1;
    cmp_deeply( WebGUI::Flux->getRules($session), [], 'no rules defined after delete' );
}

# Multiple Rules
{
    my $rule1 = WebGUI::Flux::Rule->create($session);
    my $rule2 = WebGUI::Flux::Rule->create($session);
    cmp_deeply( WebGUI::Flux->getRules($session), [ $rule1, $rule2 ], '2 rules defined' );
    $rule1->delete();
    cmp_deeply( WebGUI::Flux->getRules($session), [$rule2], 'rule2 is the only rule after deletion' );
    $rule2->delete();
    cmp_deeply( WebGUI::Flux->getRules($session), [], 'no rules left after second delete' );
}

#######################################################################
#
# getRule
#
#######################################################################
# Errors
{
    eval { my $rule = WebGUI::Flux->getRule(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'takes exception to not giving it a session object' );
    cmp_deeply(
        $e,
        methods(
            error    => 'Need a session.',
            expected => 'WebGUI::Session',
            got      => '',
        ),
        'takes exception to not giving it a session object',
    );
}
{
    eval { my $rule = WebGUI::Flux->getRule($session); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'takes exception to not giving it a fluxRuleId' );
    cmp_deeply(
        $e,
        methods(
            error => 'Need a fluxRuleId.',
            param => undef,
        ),
        'takes exception to not giving it a fluxRuleId object',
    );
}
{
    eval { my $rule = WebGUI::Flux->getRule( $session, 'neverAGUID' ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::ObjectNotFound', 'takes exception to not giving it an existing fluxRuleId' );
    cmp_deeply(
        $e,
        methods(
            error => 'No such Flux Rule.',
            id    => 'neverAGUID',
        ),
        'takes exception to not giving it a rule Id',
    );
}

{
    my $rule1            = WebGUI::Flux::Rule->create($session);
    my $rule1Id          = $rule1->getId();
    my $duplicateOfRule1 = WebGUI::Flux->getRule( $session, $rule1Id );
    cmp_deeply( $duplicateOfRule1, $rule1, 'rule1 is returned' );

    # N.B. WebGUI::Flux uses a simple Rule cache that becomes stale if you delete a Rule, e.g.
    $rule1->delete();
    my $secondDuplicateOfRule1 = WebGUI::Flux->getRule( $session, $rule1Id );    # Stale, should throw exception
    cmp_deeply( $secondDuplicateOfRule1, $rule1, 'rule1 still returned from cache after deletion' );

    # But getRules bypasses cache, e.g.
    cmp_deeply( WebGUI::Flux->getRules($session), [], 'no rules defined after delete' );
}

#######################################################################
#
# getGraph
#
#######################################################################
{
    my $rule1    = WebGUI::Flux::Rule->create($session);
    my $rule1_id = $rule1->getId();
    $rule1->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            name         => 'Test First Thing',
        }
    );
    $rule1->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            name         => 'Test Second Thing',
        }
    );
    $rule1->update( { name => 'Simple Rule', combinedExpression => 'e1 or e2' } );

    my $rule2    = WebGUI::Flux::Rule->create($session);
    my $rule2_id = $rule2->getId();
    $rule2->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$rule1_id"}],
            operand2     => 'TextValue',
            operand2Args => '{"value":  "1"}',
            operator     => 'IsEqualTo',
            name         => 'Check Simple Rule',
        }
    );
    $rule2->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            name         => 'Test Something Else',
        }
    );
    $rule2->update( { name => 'Dependent Rule' } );

    my $rule3 = WebGUI::Flux::Rule->create($session);
    $rule3->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$rule1_id"}],
            operand2     => 'TextValue',
            operand2Args => '{"value":  "1"}',
            operator     => 'IsEqualTo',
            name         => 'Check Simple Rule',
        }
    );
    $rule3->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$rule2_id"}],
            operand2     => 'TextValue',
            operand2Args => '{"value":  "1"}',
            operator     => 'IsEqualTo',
            name         => 'Check Dependent Rule',
        }
    );
    $rule3->update( { name => 'Yet Another Rule' } );
    
    my $rule4 = WebGUI::Flux::Rule->create($session);
    my $rule4_id = $rule4->getId();
    $rule4->update( { name => 'My empty Rule' } );

    my $rule5 = WebGUI::Flux::Rule->create($session);
    $rule5->addExpression( # This time put the FluxRule into operand2
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "1"}',
            operand2     => 'FluxRule',
            operand2Args => qq[{"fluxRuleId":  "$rule4_id"}],
            operator     => 'IsEqualTo',
            name         => 'Check the empty Rule',
        }
    );
    $rule5->update( { name => 'Another Rule' } );

    WebGUI::Flux->generateGraph($session);
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxRuleUserData');
    $session->db->write('delete from fluxExpression');
}
