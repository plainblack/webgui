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
use WebGUI::Form;
use WebGUI::Form::Integer;
use WebGUI::Session;
use HTML::Form;
use Test::MockObject;

#The goal of this test is to verify that Integer form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $numTests = 9;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Integer->new($session, {
		name => 'TestInteger',
		value => '123456',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestInteger', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, '123456', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');

##Test Form Output parsing

my $request = Test::MockObject->new;
$request->mock('body',
	sub {
		my ($self, $value) = @_;
		my @return = ();
		return '-123456' if ($value eq 'TestInteger');
		return "+123456" if ($value eq 'TestInteger2');
		return "123-456" if ($value eq 'TestInteger3');
		return;
	}
);
$session->{_request} = $request;

my $value = $session->form->get('TestInteger', 'integer');
is($value, '-123456', 'checking negative integer');
$value = $session->form->get('TestInteger2', 'integer');
is($value, 0, 'checking form rejects explicitly postive integer');
$value = $session->form->get('TestInteger3', 'integer');
is($value, 0, 'checking form rejects non-sense integer');

##Integer Forms have no special value preprocessing,
