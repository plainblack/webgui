# Tests WebGUI::Flux::Operand::NumericValue
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
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::NumericValue');
$session->user( { userId => 1 } );
my $user   = $session->user();


# TODO: If we need this "Numeric" at all (as distinct from String), which I'm not convinced we do,
# then we should be testing that the returned value is a perl number and not a perl string

{
    # Test the raw output of this Operand via -Operand>evaluateUsing
    my $rule   = WebGUI::Flux::Rule->create($session);
    is( WebGUI::Flux::Operand->evaluateUsing(
            'NumericValue',
            {   rule => $rule,
                args => { value => 3 }
            }
        ),
        3,
        q{3 == 3}
    );
    is( WebGUI::Flux::Operand->evaluateUsing(
            'NumericValue',
            {   rule => $rule,
                args => { value => 123 }
            }
        ),
        '123',
        q{123 == '123'}
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
