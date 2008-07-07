# Tests WebGUI::Flux::Operator::MatchesPartialText
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
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => '23', operand2 => 23} ), q{'23' matches partial text 23} );    

    # String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'def'} ), q{'abcdef' matches partial text  'def'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'xyz'} ), q{'abcdef' does not match partial text 'xyz'} );

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
