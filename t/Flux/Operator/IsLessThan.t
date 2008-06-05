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
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, 24 ), 1, q{23 < 24} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, 23 ), 0, q{23 < 23} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, 22 ), 0, q{23 < 22} );
    
    # String operands
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "b", "c" ), 1, q{"a" < "b"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "b", "b" ), 0, q{"a" < "a"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "b", "a" ), 0, q{"b" < "a"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "a", "abc" ), 1, q{"a" < "abc"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', "abc", "a" ), 0, q{"a" < "abc"} );
    
    # Mixed Numeric/String operands
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '24' ), 1, q{23 < "24"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '23' ), 0, q{23 < "23"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '22' ), 0, q{23 < "22"} );
    
    
    # Whitespace that should be automatically trimmed
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '24 ' ), 1, q{23 < "24 "} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, ' 23' ), 0, q{23 < " 23"} );
    is( WebGUI::Flux::Operator->compareUsing( 'IsLessThan', 23, '22 ' ), 0, q{23 < "22 "} );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
