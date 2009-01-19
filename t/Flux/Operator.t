# Tests the WebGUI::Flux::Operator base class
#
#

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
use Test::Exception;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 6;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule = WebGUI::Flux::Rule->create($session);

# Errors
{
    throws_ok { WebGUI::Flux::Operator->evaluateUsing() } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to wrong number of args';
    throws_ok {
        WebGUI::Flux::Operator->evaluateUsing( 'IsQuantumSuperpositionOf',
            { rule => $rule, operand1 => 'a', operand2 => 'b' } );
    }
    'WebGUI::Error::Pluggable::LoadFailed', 'evaluateUsing takes exception to invalid Operator';
    throws_ok {
        WebGUI::Flux::Operator->evaluateUsing( 'IsEqualTo',
            { rule => 'j00rule!', operand1 => 'a', operand2 => 'b' } );
    }
    'WebGUI::Error::InvalidParam', 'evaluateUsing takes exception to invalid rule';
}
{

    # Try out evaluateUsing(), using IsEqualTo as our guinea pig
    ok( WebGUI::Flux::Operator->evaluateUsing(
            'IsEqualTo', { rule => $rule, operand1 => 'cat', operand2 => 'cat' }
        ),
        'identical operands'
    );
    ok( !WebGUI::Flux::Operator->evaluateUsing(
            'IsEqualTo', { rule => $rule, operand1 => 'cat', operand2 => 'dog' }
        ),
        'different operands'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
