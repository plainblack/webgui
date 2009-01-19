# Tests WebGUI::Flux::Operator::IsGreaterThan
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
plan tests => 19;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);
{

    # Numeric operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 24, operand2 => 23} ), q{24 > 23} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 23, operand2 => 150} ), q{23 > 150} );

    # String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 'b', operand2 => 'a'} ), q{'b' > 'a'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 'a', operand2 => 'x'} ), q{'a' > 'x'} );

    # Mixed Numeric/String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 123, operand2 => '23'} ), q{123 > '23'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 23, operand2 => '123'} ), q{23 > '123'} );

    # Whitespace that should be automatically trimmed
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 25, operand2 => '23 '} ), q{25 > '23 '} );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 25, operand2 => ' 23'} ), q{25 > ' 23'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 23, operand2 => '24 '} ), q{23 > '24 '} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 23, operand2 => ' 24'} ), q{23 > ' 24'} );

    # Garbage strings
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 23, operand2 => '23abc'} ), q{23 > '23abc'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 23, operand2 => 'abc23'} ), q{23 > 'abc23'} );
    
    # undefs
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => undef, operand2 => '5'} ), q{undef >= 5} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 5, operand2 => undef} ), q{5 >= undef} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => undef, operand2 => undef} ), q{undef >= undef} );
    
    # empty strings
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => '', operand2 => '5'} ), q{'' >= 5} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => 5, operand2 => ''} ), q{5 >= ''} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsGreaterThan', {rule => $rule, operand1 => '', operand2 => ''} ), q{'' >= ''} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
