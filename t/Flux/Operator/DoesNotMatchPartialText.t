# Tests WebGUI::Flux::Operator::DoesNotMatchPartialText
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

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);
{

    # Numeric operands
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'DoesNotMatchPartialText', {rule => $rule, operand1 => 23, operand2 => 23} ), q{23 does not contain 23} );
  

    # String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'DoesNotMatchPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'wxyz'} ), q{'abcdef' does not contain 'wxyz'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'DoesNotMatchPartialText', {rule => $rule, operand1 => 'sazf', operand2 => 'az'} ), q{'a' does contain 'az'} );


}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
