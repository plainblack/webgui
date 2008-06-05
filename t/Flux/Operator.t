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
my $tests = 7;
plan tests => $tests;

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
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'compareUsing takes exception to invalid Operator' );
    cmp_deeply(
        $e,
        methods(
            error => 'Invalid WebGUI::Flux::Operator.',
            param => 'IsQuantumSuperpositionOf',
        ),
        'compareUsing takes exception to invalid Operator',
    );
}

{

    # Try out compareUsing(), using IsEqualTo as our guinea pig
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 'cat', 'cat' ), 1, 'identical operands' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 'cat', 'dog'), 0, 'different operands' );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
