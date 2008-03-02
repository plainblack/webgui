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

# create a workflow
my $wf = WebGUI::Workflow->create(
    $session,
    {
        title => 'WebGUI::Workflow::Instance Test',
        description => 'Description',
        type => 'None'
    }
);
ok(defined $wf, 'can create workflow');
isa_ok($wf, 'WebGUI::Workflow', 'workflow');

my $wfId = $wf->getId;
ok(defined $wfId, 'workflow has an ID');
ok(defined WebGUI::Workflow->new($session, $wfId), 'workflow can be retrieved');

# create an instance of $wfId
my $properties = {
    #workflowId=>$session->setting->get("runOnAdminCreateUser"),
    workflowId=>$wfId,
    methodName=>"new",
    className=>"None",
    parameters=>'encode me',
    priority=>1
};
my $instance = WebGUI::Workflow::Instance->create($session, $properties);
isa_ok($instance, 'WebGUI::Workflow::Instance', 'workflow instance');

# test JSON encoding
my $encoded_text = JSON->new->pretty->encode({parameters => $properties->{parameters}});
ok($encoded_text, 'received encoded text from JSON');


#----------------------------------------------------------------------------
# Cleanup
END {
    $wf->delete;
}
