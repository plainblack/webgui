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
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Workflow;
use WebGUI::Workflow::Instance;
use JSON;
use Data::Dumper;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 6;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

###############################################################################3
#
# create a workflow instance
#
###############################################################################3

my $wf = WebGUI::Workflow->create(
    $session,
    {
        title => 'WebGUI::Workflow::Instance Test',
        description => 'Description',
        type => 'None'
    }
);
isa_ok($wf, 'WebGUI::Workflow', 'workflow created for test');

# create an instance of $wfId
my $properties = {
    workflowId=>$wf->getId,
    methodName=>"new",
    className=>"None",
    parameters=>'encode me',
};
my $dateUpdated = time();
my $instance = WebGUI::Workflow::Instance->create($session, $properties);
isa_ok($instance, 'WebGUI::Workflow::Instance', 'create: workflow instance');
ok($session->getId, 'getId returns something');
ok($session->id->valid($instance->getId), 'New workflow instance has a valid ID');
is($instance->get('priority'), 2, 'Default instance priority is 2');
cmp_ok(abs ($instance->get('lastUpdate')-$dateUpdated), '<=', 3, 'Date updated field set correctly when instance is created');
diag $instance->get('lastStatus');


#----------------------------------------------------------------------------
# Cleanup
END {
    $wf->delete;  ##Deleting a Workflow deletes its instances, too.
}
