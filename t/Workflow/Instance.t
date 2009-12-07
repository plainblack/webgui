# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Tests for WebGUI::Workflow::Instance
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Test::Exception;
use Scope::Guard;

use Test::MockObject;
my $mockSpectre = Test::MockObject->new();
my @spectreGuts = ();
$mockSpectre->fake_module('WebGUI::Workflow::Spectre',
'notify', sub{
    my ($message, $data) = @_;
    push @spectreGuts, [$message, $data];
});
$mockSpectre->mock('notify', sub{
    my ($message, $data) = @_;
    push @spectreGuts, [$message, $data];
});
$mockSpectre->fake_new('WebGUI::Workflow::Spectre');

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Workflow;
use WebGUI::Workflow::Instance;
use JSON;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 34;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

###############################################################################
#
# create a workflow instance
#
###############################################################################

my $wf = WebGUI::Workflow->create(
    $session,
    {
        title => 'WebGUI::Workflow::Instance Test',
        description => 'Description',
        type => 'None',
        mode => 'singleton',
    }
);
isa_ok($wf, 'WebGUI::Workflow', 'workflow created for test');
addToCleanup($wf);

# create an instance of $wfId
my $properties = {
    workflowId=>$wf->getId,
};
my $dateUpdated = time();
my $instance = WebGUI::Workflow::Instance->create($session, $properties);
isa_ok($instance, 'WebGUI::Workflow::Instance', 'create: workflow instance');
ok($session->getId, 'getId returns something');
ok($session->id->valid($instance->getId), 'New workflow instance has a valid ID');
is($instance->get('priority'), 2, 'Default instance priority is 2');
cmp_ok(abs ($instance->get('lastUpdate')-$dateUpdated), '<=', 3, 'Date updated field set correctly when instance is created');

##Singleton checks
my $otherInstance = WebGUI::Workflow::Instance->create($session, $properties);
is ($otherInstance, undef, 'create: only allows one instance of a singleton to be created');

WebGUI::Test->interceptLogging;

$instance->set({ 'parameters' => {session => 1}, });
$otherInstance = WebGUI::Workflow::Instance->create($session, {workflowId => $wf->getId, parameters => { session => 1,} });
is($otherInstance, undef, 'create: another singleton instance can not be created if it the same parameters as a currently existing instance');
my $expectedId = $wf->getId;
like($WebGUI::Test::logger_info, qr/An instance of singleton workflow $expectedId already exists/, 'create: Warning logged for trying to make another singleton');

$otherInstance = WebGUI::Workflow::Instance->create($session, {workflowId => $wf->getId, parameters => { session => 2,}});
isnt ($otherInstance, undef, 'create: another singleton instance can be created if it has different parameters');
$otherInstance->delete;

###############################################################################
#
#  getWorkflow
#
###############################################################################

my $instanceWorkflow = $instance->getWorkflow;
is($instanceWorkflow->getId, $wf->getId, 'getWorkflow returns a copy of the workflow for the instance');
is($instanceWorkflow->getId, $wf->getId, 'getWorkflow, caching check');

###############################################################################
#
#  new
#
###############################################################################

$otherInstance = WebGUI::Workflow::Instance->new($session, 'neverAWebGUIId');
is($otherInstance, undef, 'new: non-existant id returns undef');
$otherInstance = WebGUI::Workflow::Instance->new($session, $instance->getId);
isa_ok($otherInstance, 'WebGUI::Workflow::Instance', 'new with a valid id returns an Instance object');
is($otherInstance->getId, $instance->getId, 'new returned the correct instance');
is($otherInstance->{_started}, 1, 'By default, _started = 0');
$otherInstance = WebGUI::Workflow::Instance->new($session, $instance->getId, 1);
is($otherInstance->{_started}, 0, 'By default, _started = 1');

###############################################################################
#
#  set, get
#
###############################################################################

$instance->set({
    priority          => 3,
    lastStatus        => 'undefined',
    workflowId        => 'notAWorkflowId',
    className         => 'WebGUI::Session',
    methodName        => 'open',
    currentActivityId => 'notAnActivityId',
} , 1);
is($instance->get('priority'),           3,                 'set priority');
is($instance->get('lastStatus'),         'undefined',       'set lastStatus');
is($instance->get('workflowId'),         'notAWorkflowId',  'set workflowId');
is($instance->get('className'),          'WebGUI::Session', 'set className');
is($instance->get('methodName'),         'open',            'set methodName');
is($instance->get('currentActivityId'),  'notAnActivityId', 'set currentActivityId');

$instance->set({
    priority          => 0,
    lastStatus        => '',
    workflowId        => '',
} , 1);
is($instance->get('priority'),           3,                 'set priority, is sticky');
is($instance->get('lastStatus'),         'undefined',       'set lastStatus is sticky');
is($instance->get('workflowId'),         'notAWorkflowId',  'set workflowId is sticky');

$instance->set({
    className         => '',
    methodName        => '',
    currentActivityId => 0,
} , 1);
is($instance->get('className'),          '', 'set: className can be cleared');
is($instance->get('methodName'),         '', 'set: methodName can be cleared');
is($instance->get('currentActivityId'),  0,  'set: currentActivityId can be cleared');

my $setTime = time();
$instance->set({priority => 2}, 1);
cmp_ok( abs($instance->get('lastUpdate') - $setTime), '<=', 2, 'set: lastUpdate set correctly');

my $params = [ '.38 revolver', 'oily', 'black and evil'];

$instance->set({parameters => $params},1);
cmp_deeply($instance->get('parameters'), $params, 'set, get with parameter');

my $wf2 = WebGUI::Workflow->create(
    $session,
    {
        title => 'WebGUI::Workflow::Instance Test',
        description => 'Non-singleton test',
        type => 'None',
    }
);
addToCleanup($wf2);

my $wf2Instance = WebGUI::Workflow::Instance->create($session, {workflowId => $wf2->getId});
cmp_deeply($wf2Instance->get('parameters'), {}, 'get returns {} for parameters when there are no parameters stored');

###############################################################################
#
#  getObject
#
###############################################################################

{
    my $return;
    Test::MockObject->fake_module('WebGUI::Test::Workflow::Instance::TestObject',
        new => sub {
            return $return;
        },
    );

    my $wf3 = WebGUI::Workflow->create(
        $session,
        {
            title => 'WebGUI::Workflow::Instance Test',
            description => 'getObject test',
            type => 'WebGUI::Test::Workflow::Instance::TestObject',
        }
    );
    my $wf3guard = Scope::Guard->new(sub {
        $wf3->delete;
    });

    my $wf3Instance = WebGUI::Workflow::Instance->create( $session, {
        workflowId => $wf3->getId,
        className  => 'WebGUI::Test::Workflow::Instance::TestObject',
        methodName => 'new',
    });

    dies_ok { $wf3Instance->getObject } 'getObject throws when instanciation returns undef';

    $return = Test::MockObject->new;
    lives_and {
        is $wf3Instance->getObject, $return;
    } 'getObject is able to retrieve correct object';
}
