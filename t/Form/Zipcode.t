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
use WebGUI::Form::Zipcode;
use WebGUI::Session;
use HTML::Form;
use Test::MockObject;

#The goal of this test is to verify that Zipcode form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $numTests = 11;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Zipcode->new($session, {
		name => 'TestZip',
		value => '97123-ORST',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestZip', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, '97123-ORST', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');

##Test Form Output parsing

my $request = Test::MockObject->new;
$request->mock('body',
	sub {
		my ($self, $value) = @_;
		my @return = ();
		return 'ABCDE' if ($value eq 'alpha');
		return '02468' if ($value eq 'numeric');
		return "NO WHERE" if ($value eq 'alpha space');
		return "-" if ($value eq 'dash');
		return "abcde" if ($value eq 'failure');
		return;
	}
);
$session->{_request} = $request;

my $value = $session->form->get('alpha', 'Zipcode');
is($value, 'ABCDE', 'checking alpha processing');
$value = $session->form->get('numeric', 'Zipcode');
is($value, '02468', 'checking numeric processing');
$value = $session->form->get('alpha space', 'Zipcode');
is($value, 'NO WHERE', 'checking alpha space');
$value = $session->form->get('dash', 'Zipcode');
is($value, '-', 'checking dash');
$value = $session->form->get('failure', 'Zipcode');
is($value, undef, 'checking failure');

##Form value preprocessing.  Zipcode does no preprocessing

