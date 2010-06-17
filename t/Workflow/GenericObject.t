# Tests WebGUI::Workflow::Instance::GenericObject

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 5;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Workflow::Instance::GenericObject');

my %props = ( a => 1, b => 2, c => 3 );
my $d = WebGUI::Workflow::Instance::GenericObject->new( $session, {%props} );
is( $d->{$_}, $props{$_}, qq{Property "$_" matches} ) for qw(a b);

my $wf = WebGUI::Workflow->create(
    $session,
    {   title       => 'WebGUI::Workflow::Instance Test',
        description => 'Description',
        type        => 'None',
        mode        => 'singleton',
    }
);
WebGUI::Test->workflowsToDelete($wf);
my $instance = WebGUI::Workflow::Instance->create(
    $session,
    {   workflowId => $wf->getId,
        methodName => "new",
        className  => "WebGUI::Workflow::Instance::GenericObject",
        parameters => {%props},
    }
);

my $obj = $instance->getObject;
is( $obj->{$_}, $props{$_}, qq{Property "$_" matches} ) for qw(a b);
