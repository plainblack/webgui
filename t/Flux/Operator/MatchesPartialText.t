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
plan tests => 13;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);
{

    # Numeric operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => 23} ), q{23 == 23} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => 66} ), q{23 == 66} );

    # String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'a', operand2 => 'a'} ), q{'a' == 'a'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'a', operand2 => 'az'} ), q{'a' == 'az'} );

    # Mixed Numeric/String operands
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => '23'} ), q{23 == '23'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => '24'} ), q{23 == '23'} );

    # Whitespace that should be automatically trimmed
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => '23 '} ), q{23 == '23 '} );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => ' 23'} ), q{23 == ' 23'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => '24 '} ), q{23 == '24 '} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => ' 24'} ), q{23 == ' 24'} );

    # Garbage strings
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => '23abc'} ), q{23 == '23abc'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 23, operand2 => 'abc23'} ), q{23 == 'abc23'} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
