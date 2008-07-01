# Tests WebGUI::Flux::Operand::TextValue
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
plan tests => 4;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::TextValue');
$session->user( { userId => 1 } );
my $user   = $session->user();


{
    # Test the raw output of this Operand via -Operand>evaluateUsing
    my $rule   = WebGUI::Flux::Rule->create($session);
    is( WebGUI::Flux::Operand->evaluateUsing(
            'TextValue',
            {
                rule => $rule,
                args => { value => 'test value' }
            }
        ),
        'test value'
    );
}
{
    # Test through higher-level rule->evaluateFor
    my $rule   = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "test value"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "test value"}',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), q{"test value" == "test value"} );
}
{
    # Repeat with a false expression
    my $rule   = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "applea"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "oranges"}',
        }
    );
    ok( !$rule->evaluateFor( { user => $user, } ), q{"apples" != "oranges"} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
