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
use WebGUI::Form::Email;
use WebGUI::Session;
use HTML::Form;
use Test::MockObject;

#The goal of this test is to verify that Email form elements work.
#The Email form accepts and validates an email address.

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $numTests = 8;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Email->new($session, {
		name => 'TestEmail',
		value => 'me@nowhere.com',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestEmail', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, 'me@nowhere.com', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');

##Test Form Output parsing

my $request = Test::MockObject->new;
$request->mock('body',
	sub {
		my ($self, $value) = @_;
		my @return = ();
		return 'me@nowhere.com' if ($value eq 'TestEmail');
		return "what do you want?" if ($value eq 'TestEmail2');
		return;
	}
);
$session->{_request} = $request;

my $value = $session->form->get('TestEmail', 'Email');
is($value, 'me@nowhere.com', 'checking existent form value');
$value = $session->form->get('TestEmail2', 'Email');
is($value, undef, 'checking form postprocessing for bad email address');

##Email form does no preprocessing of its input

