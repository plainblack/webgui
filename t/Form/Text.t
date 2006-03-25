#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::HTMLForm;
use WebGUI::Session;
use HTML::Form;
use Test::MockObject;

#The goal of this test is to verify that Text form elements
#work, via HTMLForm.

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $i18n = WebGUI::International->new($session);

# put your tests here

my $numTests = 8;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my $HTMLForm = WebGUI::HTMLForm->new($session);

$HTMLForm->text(
	-name => 'TestText',
	-value => 'Some text in here',
);

my $html = $HTMLForm->print;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

my $input = $inputs[0];
is($input->name, 'TestText', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, 'Some text in here', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');

##Test Form Output parsing

my $request = Test::MockObject->new;
$request->mock('body',
	sub {
		my ($self, $value) = @_;
		my @return = ();
		return 'some user value' if ($value eq 'TestText');
		return "some user value\nwith\r\nwhitespace" if ($value eq 'TestText2');
		return;
	}
);
$session->{_request} = $request;

my $value = $session->form->get('TestText', 'Text');
is($value, 'some user value', 'checking existent form value');
$value = $session->form->get('TestText2', 'Text');
is($value, 'some user valuewithwhitespace', 'checking form postprocessing for whitespace');
