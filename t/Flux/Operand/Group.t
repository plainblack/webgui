# Tests WebGUI::Flux::Operand::FluxRule
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

use_ok('WebGUI::Flux::Operand::Group');
my $user = WebGUI::User->new( $session, 'new' );
my $group = WebGUI::Group->new( $session, 'new');
my $groupId = $group->getId();

{
    my $rule    = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'Group',
            operand1Args => qq[{"groupId":  "$groupId"}],
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
            operator     => 'IsEqualTo',
        }
    );
    ok( !$rule->evaluateFor( { user => $user, }), q{Mr User is not yet in our group} );
    $user->addToGroups([$groupId]);
    ok( $rule->evaluateFor( { user => $user, }), q{Now he's in!} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
    $user->delete() if $user;
    $group->delete() if $group;
}
