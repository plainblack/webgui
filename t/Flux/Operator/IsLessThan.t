# Tests WebGUI::Flux::Operator::IsLessThan
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
plan tests => 15;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');

{

    # Numeric operands
    ok( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, 24 ), q{23 < 24} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, 23 ), q{23 < 23} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, 22 ), q{23 < 22} );

    # String operands
    ok( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "b", "c" ), q{"a" < "b"} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "b", "b" ), q{"a" < "a"} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "b", "a" ), q{"b" < "a"} );
    ok( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "a", "abc" ), q{"a" < "abc"} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "abc", "a" ), q{"a" < "abc"} );

    # Mixed Numeric/String operands
    ok( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '24' ), q{23 < "24"} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '23' ), q{23 < "23"} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '22' ), q{23 < "22"} );

    # Whitespace that should be automatically trimmed
    ok( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '24 ' ), q{23 < "24 "} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, ' 23' ), q{23 < " 23"} );
    ok( !WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '22 ' ), q{23 < "22 "} );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
