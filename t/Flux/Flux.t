# Tests WebGUI::Flux
#
# Coverage:
# cover -delete -silent /tmp/fluxcvr && HARNESS_PERL_SWITCHES='-MDevel::Cover=-db,/tmp/fluxcvr,-ignore,.,-select,lib/WebGUI/Flux' prove -r t/Flux && cover /tmp/fluxcvr
#
# Profiling:
# FASTPROF_CONFIG='filename=/tmp/fluxprof' HARNESS_PERL_SWITCHES='-d:FastProf' prove -r t/Flux
# fprofpp -f/tmp/fluxprof -t5
#
# HARNESS_PERL_SWITCHES='-d:NYTProf' prove -r t/Flux

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Test::Exception;
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
plan tests => 24;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux');
$session->user( { userId => 3 } );
my $user   = $session->user();
my $userId = $user->userId();

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
    throws_ok { WebGUI::Flux->getRules() } 'WebGUI::Error::InvalidParam',
        'takes exception to not giving it a session object';
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
    throws_ok { WebGUI::Flux->getRule() } 'WebGUI::Error::InvalidParam',
        'takes exception to not giving it a session object';
    throws_ok { WebGUI::Flux->getRule($session) } 'WebGUI::Error::InvalidParam',
        'takes exception to not giving it a fluxRuleId';
    throws_ok { WebGUI::Flux->getRule( $session, 'neverAGUID' ) } 'WebGUI::Error::ObjectNotFound',
        'takes exception to not giving it an existing fluxRuleId';
}

# getRule
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
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
            name         => 'Test First Thing',
        }
    );
    $rule1->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "boring dry everyday value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "super lucky crazy value"}',
            name         => 'Test Second Thing',
        }
    );
    $rule1->update( { name => 'Simple Rule', combinedExpression => 'not e1 or e2' } );

    my $rule2    = WebGUI::Flux::Rule->create($session);
    my $rule2_id = $rule2->getId();
    $rule2->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$rule1_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
            name         => 'Check Simple Rule',
        }
    );
    $rule2->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
            name         => 'Test Something Else',
        }
    );
    $rule2->update( { name => 'Dependent Rule' } );

    my $rule3 = WebGUI::Flux::Rule->create($session);
    $rule3->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$rule1_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
            name         => 'Check Simple Rule',
        }
    );
    $rule3->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$rule2_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
            name         => 'Check Dependent Rule',
        }
    );
    $rule3->update( { name => 'Yet Another Rule' } );

    my $rule4    = WebGUI::Flux::Rule->create($session);
    my $rule4_id = $rule4->getId();
    $rule4->update( { name => 'My empty Rule' } );

    my $rule5 = WebGUI::Flux::Rule->create($session);
    $rule5->addExpression(    # This time put the FluxRule into operand2
        {   operand1     => 'TruthValue',
            operand1Args => '{"value":  "1"}',
            operator     => 'IsEqualTo',
            operand2     => 'FluxRule',
            operand2Args => qq[{"fluxRuleId":  "$rule4_id"}],
            name         => 'Check the empty Rule',
        }
    );
    $rule5->update( { name => 'Another Rule' } );

    WebGUI::Flux->generateGraph($session);
}

#######################################################################
#
# evaluateFor()
#
#######################################################################
# Errors
{
    throws_ok { WebGUI::Flux->evaluateFor() } 'WebGUI::Error::InvalidParam', 'takes exception to zero arguments';
    throws_ok {
        WebGUI::Flux->evaluateFor( { user => 1, fluxRuleId => 1 } );
    }
    'WebGUI::Error::InvalidParam', 'takes exception to invalid user';
    is(WebGUI::Flux->evaluateFor( { user => $user, fluxRuleId => "notAFluxRuleId" } ), 0, 'Invalid fluxRuleId returns false');
}
{
    my $rule    = WebGUI::Flux::Rule->create($session);
    ok(WebGUI::Flux->evaluateFor( { user => $user, fluxRuleId => $rule->getId } ), 'Empty rule evaluates to true');
}

#######################################################################
#
# getStickies
#
#######################################################################
# Errors
{
    throws_ok { WebGUI::Flux->getStickies() } 'WebGUI::Error::InvalidParam',
        'takes exception to not giving it any named params';
    throws_ok { WebGUI::Flux->getStickies( { user => 1, fluxRuleIds => [] } ) } 'WebGUI::Error::InvalidParam',
        'takes exception to not giving it an invalid user object';
}
{
    my @stickies = WebGUI::Flux->getStickies( { user => $user, fluxRuleIds => [] } );
    cmp_deeply( \@stickies, [], 'nothing returned for empty array of fluxRuleIds' );

    my $rule1 = WebGUI::Flux::Rule->create( $session, { sticky => 1 } );
    my $rule2 = WebGUI::Flux::Rule->create( $session, { sticky => 1 } );
    my $ids = [ $rule1->getId, $rule2->getId ];
    @stickies = WebGUI::Flux->getStickies( { user => $user, fluxRuleIds => $ids } );
    cmp_deeply( \@stickies, [], 'no sticky hits for user yet' );

    $rule1->evaluateFor( { user => $user } );
    @stickies = WebGUI::Flux->getStickies( { user => $user, fluxRuleIds => $ids } );
    cmp_deeply( \@stickies, [ $rule1->getId ], 'one sticky hit for user' );

    $rule2->evaluateFor( { user => $user } );
    @stickies = WebGUI::Flux->getStickies( { user => $user, fluxRuleIds => $ids } );
    cmp_deeply( \@stickies, [ $rule1->getId, $rule2->getId ], '2 sticky hits for user' );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule') unless $ENV{FLUX_NO_CLEANUP};
    $session->db->write('delete from fluxRuleUserData');
    $session->db->write('delete from fluxExpression') unless $ENV{FLUX_NO_CLEANUP};
}
