# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

use Test::MockObject;
my $mockSpectre = Test::MockObject->new();
$mockSpectre->fake_module('WebGUI::Workflow::Spectre');
$mockSpectre->fake_new('WebGUI::Workflow::Spectre');
my @spectreGuts = ();
$mockSpectre->mock('notify', sub{
    my ($message, $data) = @_;
    push @spectreGuts, [$message, $data];
});

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

plan tests => 11;        # Increment this number for each test you create

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

$instance->set({ 'parameters' => {session => 1}, });
$otherInstance = WebGUI::Workflow::Instance->create($session, {workflowId => $wf->getId, parameters => { session => 1,} });
is($otherInstance, undef, 'create: another singleton instance can not be created if it the same parameters as a currently existing instance');
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
#  set
#
###############################################################################


#----------------------------------------------------------------------------
# Cleanup
END {
    $wf->delete;  ##Deleting a Workflow deletes its instances, too.
}
