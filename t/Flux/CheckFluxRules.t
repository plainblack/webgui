# Tests WebGUI::Workflow::Activity::CheckFluxRules
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux;
use WebGUI::Flux::Rule;
use WebGUI::Workflow;
use WebGUI::Group;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
WebGUI::Error->Trace(1); # Turn on tracing of uncaught Exception::Class exceptions

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Workflow::Activity::CheckFluxRules');

# Start with a clean slate
$session->db->write('delete from fluxRule');
$session->db->write('delete from fluxRuleUserData');
$session->db->write('delete from fluxExpression');

# Test Group
my $group = WebGUI::Group->new( $session, 'new' );
my $user1 = WebGUI::User->new( $session, 'new' );
my $user2 = WebGUI::User->new( $session, 'new' );
$group->addUsers([$user1->userId(), $user2->userId()]);

# Workflow and Activity
my $workflow = WebGUI::Workflow->create(
    $session,
    {   title       => 'Flux Test Workflow',
        description => 'Flux Test Workflow',
        enabled     => 1,
    }
);
my $activity = WebGUI::Workflow::Activity::CheckFluxRules->create( $session, $workflow->getId() );
$activity->set( 'groupId', $group->getId() );

{
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->addExpression( # Add an expression that will fail, kaaboom!
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "apples"}',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "oranges"}',
            operator     => 'IsEqualTo',
        }
    );
    is( $session->db->quickScalar(
            'select count(*) from fluxRuleUserData where fluxRuleId = ?',
            [ $rule->getId() ]
        ),
        0,
        'Initially no fluxRuleUserData row'
    );
    $activity->execute();
    is( $session->db->quickScalar(
            'select count(*) from fluxRuleUserData where fluxRuleId = ?',
            [ $rule->getId() ]
        ),
        3,
        'Afterwards, 3 fluxRuleUserData rows (2 test users + admin)'
    );
}

# TODO: Once we have a user-profile based Operand, do more detailed checking of users post-activity execution

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxRuleUserData');
    $session->db->write('delete from fluxExpression');
    $activity->delete() if $activity;
    $workflow->delete() if $workflow;
    $user1->delete() if $user1;
    $user2->delete() if $user2;
    $group->delete() if $group;
}
