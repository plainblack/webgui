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

use_ok('WebGUI::Flux::Operand::UserProfileField');
my $user = WebGUI::User->new( $session, 'new' );
$user->profileField('firstName', 'Quintus');
$user->profileField('lastName', 'Hortensius');

{

    my $rule    = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'UserProfileField',
            operand1Args => '{"field":  "firstName"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "Quintus"}',
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluateFor( { user => $user, }), q{A Roman is among us} );
    $rule->addExpression(
        {   operand1     => 'UserProfileField',
            operand1Args => '{"field":  "lastName"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "Hortensius"}',
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluateFor( { user => $user, }), q{An orator no less!} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
    $user->delete() if $user;
}
