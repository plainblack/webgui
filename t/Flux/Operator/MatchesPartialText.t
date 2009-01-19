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
plan tests => 6;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);
{
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'def'} ), 'Matches at the end of the string' );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'abc'} ), 'Matches at the start of the string' );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'cde'} ), 'Matches in the middle of the string' );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abcdef', operand2 => 'CdE'} ), 'Case-insensitive' );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'MatchesPartialText', {rule => $rule, operand1 => 'abc.[]!@#$%^&*()def', operand2 => '.[]!@#$%^&*()'} ), 'Meta-chars are ok' );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
