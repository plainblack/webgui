# Tests WebGUI::Flux::Operator::IsLessThanOrEqualTo
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
plan tests => 18;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);
{

    # Numeric operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 21, operand2 => 23} ), q{21 <= 23} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 123, operand2 => 66} ), q{123 <= 66} );

    # String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 'a', operand2 => 'a'} ), q{'a' <= 'a'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 'z', operand2 => 'a'} ), q{'z' <= 'a'} );

    # Mixed Numeric/String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 23, operand2 => '123'} ), q{23 <= '123'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 28, operand2 => '24'} ), q{28 <= '24'} );

    # Whitespace that should be automatically trimmed
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 23, operand2 => '23 '} ), q{23 <= '23 '} );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 23, operand2 => ' 23'} ), q{23 <= ' 23'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 28, operand2 => '24 '} ), q{28 <= '24 '} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 28, operand2 => ' 24'} ), q{28 <= ' 24'} );

    # Garbage strings
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 23, operand2 => '19abc'} ), q{23 <= '19abc'} );
    
    # undefs
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => undef, operand2 => '5'} ), q{undef >= 5} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 5, operand2 => undef} ), q{5 >= undef} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => undef, operand2 => undef} ), q{undef >= undef} );    
    
    # empty strings
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => '', operand2 => '5'} ), q{'' >= 5} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => 5, operand2 => ''} ), q{5 >= ''} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsLessThanOrEqualTo', {rule => $rule, operand1 => '', operand2 => ''} ), q{'' >= ''} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
