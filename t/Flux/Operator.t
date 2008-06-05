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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 7;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');

{
    eval { WebGUI::Flux::Operator->compareUsing(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParamCount', 'compareUsing takes exception to wrong number of args' );
    cmp_deeply(
        $e,
        methods(
            description => 'Wrong number of params supplied.',
            expected    => 4,
            got         => 1,
        ),
        'compareUsing takes exception to wrong number of args',
    );
}
{
    eval { WebGUI::Flux::Operator->compareUsing('IsQuantumSuperpositionOf', 'a', 'b'); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Flux::OperatorEvalFailed', 'compareUsing takes exception to invalid Operator' );
    cmp_deeply(
        $e,
        methods(
            error => re(qr/^Unable to run compare on WebGUI::Flux::Operator::IsQuantumSuperpositionOf:/),
            operator => 'IsQuantumSuperpositionOf',
        ),
        'compareUsing takes exception to invalid Operator',
    );
}

{

    # Try out compareUsing(), using IsEqualTo as our guinea pig
    ok( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 'cat', 'cat' ), 'identical operands' );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 'cat', 'dog'), 'different operands' );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
