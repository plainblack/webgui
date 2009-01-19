# Tests WebGUI::Flux::Operand::TruthValue
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

use_ok('WebGUI::Flux::Operand::TruthValue');
$session->user( { userId => 1 } );
my $user   = $session->user();


# Not much to test here since TruthValue is really just the same as TextValue
# (the only difference is in the UI which we don't test)

{
    # Test the raw output of this Operand via -Operand>evaluateUsing
    my $rule   = WebGUI::Flux::Rule->create($session);
    ok( WebGUI::Flux::Operand->evaluateUsing(
            'TruthValue',
            {   rule => $rule,
                args => { value => 1 }
            }
        ),
        q{1 is boolean True (n...naw!)}
    );
    ok( !WebGUI::Flux::Operand->evaluateUsing(
            'TruthValue',
            {   rule => $rule,
                args => { value => 0 }
            }
        ),
        q{0 is boolean False (say it ain't so!)}
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
