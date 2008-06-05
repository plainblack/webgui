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
    ok( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, 23 ), q{23 == 23} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, 66 ), q{23 == 66} );

    # String operands
    ok( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 'a', 'a' ), q{'a' == 'a'} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 'a', 'az' ), q{'a' == 'az'} );

    # Mixed Numeric/String operands
    ok( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '23' ), q{23 == '23'} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '24' ), q{23 == '23'} );

    # Whitespace that should be automatically trimmed
    ok( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '23 ' ), q{23 == '23 '} );
    ok( WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, ' 23' ), q{23 == ' 23'} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '24 ' ), q{23 == '24 '} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, ' 24' ), q{23 == ' 24'} );

    # Garbage strings
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, '23abc' ), q{23 == '23abc'} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsEqualTo', 23, 'abc23' ), q{23 == 'abc23'} );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
