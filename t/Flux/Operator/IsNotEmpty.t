# Tests WebGUI::Flux::Operator::IsNotEmpty
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
plan tests => 5;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operator');
my $rule   = WebGUI::Flux::Rule->create($session);
{
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsNotEmpty', {rule => $rule, operand1 => '', operand2 => 23} ), q{''} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsNotEmpty', {rule => $rule, operand1 => undef, operand2 => 66} ), q{undef} );
    ok( WebGUI::Flux::Operator->evaluateUsing( 'IsNotEmpty', {rule => $rule, operand1 => 'a', operand2 => 23} ), q{'a'} );
    ok( !WebGUI::Flux::Operator->evaluateUsing( 'IsNotEmpty', {rule => $rule, operand1 => undef, operand2 => undef} ), q{undef} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
