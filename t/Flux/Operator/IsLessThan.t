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
use WebGUI::Flux::Rule;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 15;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);

{

    # Numeric operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => 24} ), q{23 < 24} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => 23} ), q{23 < 23} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => 22} ), q{23 < 22} );

    # String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => "b", operand2 => "c"} ), q{"a" < "b"} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => "b", operand2 => "b"} ), q{"a" < "a"} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => "b", operand2 => "a"} ), q{"b" < "a"} );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => "a", operand2 => "abc"} ), q{"a" < "abc"} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => "abc", operand2 => "a"} ), q{"a" < "abc"} );

    # Mixed Numeric/String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => '24'} ), q{23 < "24"} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => '23'} ), q{23 < "23"} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => '22'} ), q{23 < "22"} );

    # Whitespace that should be automatically trimmed
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => '24 '} ), q{23 < "24 "} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => ' 23'} ), q{23 < " 23"} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThan', {rule => $rule, operand1 => 23, operand2 => '22 '} ), q{23 < "22 "} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}