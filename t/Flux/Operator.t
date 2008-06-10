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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 7;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule = WebGUI::Flux::Rule->create($session);

{
    eval { WebGUI::Flux::Operator->evaluateUsing(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParamCount', 'evaluateUsing takes exception to wrong number of args' );
    cmp_deeply(
        $e,
        methods(
            expected    => 3,
            got         => 1,
        ),
        'evaluateUsing takes exception to wrong number of args',
    );
}
{
    eval { WebGUI::Flux::Operator->evaluateUsing('IsQuantumSuperpositionOf', {rule => $rule, operand1 => 'a', operand2 => 'b'}); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::LoadFailed', 'evaluateUsing takes exception to invalid Operator' );
    cmp_deeply(
        $e,
        methods(
            error => re(qr/^Could not load WebGUI::Flux::Operator::IsQuantumSuperpositionOf/),
            module => 'WebGUI::Flux::Operator::IsQuantumSuperpositionOf',
        ),
        'evaluateUsing takes exception to invalid Operator',
    );
}

{

    # Try out evaluateUsing(), using IsEqualTo as our guinea pig
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsEqualTo', {rule => $rule, operand1 => 'cat', operand2 => 'cat'} ), 'identical operands' );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsEqualTo', {rule => $rule, operand1 => 'cat', operand2 => 'dog'}), 'different operands' );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
