# Tests WebGUI::Flux::Operator::IsEqualTo
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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 13;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');

{

    # Numeric operands
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, 23 ), 1, 'identical numeric operands' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, 66 ), 0, 'different numeric operands' );

    # String operands
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', "a", "a" ), 1, 'identical string operands' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', "a", "az" ), 0, 'different string operands' );
    
    # Mixed Numeric/String operands
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '23' ), 1, 'identical mixed string/numeric operands' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '24' ), 0, 'different mixed string/numeric operands' );
    
    # Whitespace that should be automatically trimmed
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '23 ' ), 1, 'identical mixed string/numeric operands with whitespace' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, ' 23' ), 1, 'identical mixed string/numeric operands with whitespace' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '24 ' ), 0, 'different mixed string/numeric operands with whitespace' );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, ' 24' ), 0, 'different mixed string/numeric operands with whitespace' );
    
    # Garbage strings
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '23abc' ), 0, q{23 == "23abc"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, 'abc23' ), 0, q{23 == "abc23"} );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
