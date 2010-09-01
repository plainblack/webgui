#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Form;
use WebGUI::Form::Email;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Email form elements work.
#The Email form accepts and validates an email address.

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'EMAIL1',
		testValue => 'me@nowhere.com',
		expected  => 'EQUAL',
		comment   => 'regular email address'
	},
	{
		key => 'EMAIL2',
		testValue => 'i@nowhere.com',
		expected  => 'EQUAL',
		comment   => 'single character email fails'
	},
	{
		key => 'EMAIL3',
		testValue => 'web.gui@nowhere.org',
		expected  => 'EQUAL',
		comment   => 'dotted email address'
	},
	{
		key => 'EMAIL4',
		testValue => 'web-gui@nowhere.org',
		expected  => 'EQUAL',
		comment   => 'dashed email address'
	},
	{
		key => 'EMAIL5',
		testValue => 'web_gui@nowhere.org',
		expected  => 'EQUAL',
		comment   => 'underscore email address'
	},
	{
		key => 'EMAIL6',
		testValue => 'what do you want?',
		expected  => undef,
		comment   => 'not an email address'
	},
];

my $formType = 'text';
my $formClass = 'WebGUI::Form::Email';

my $numTests = 11 + scalar @{ $testBlock } + 5;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestEmail',
		value => 'me@nowhere.com',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestEmail', 'Checking input name');
is($input->type, $formType, 'Checking input type');
is($input->value, 'me@nowhere.com', 'Checking default value');
is($input->{size}, 30, 'Checking size param, default');
is($input->{maxlength}, 255, 'Checking maxlength param, default');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'email2',
		value => q!Some & text in " here!,
		size => 25,
		maxlength => 200,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'email2', 'Checking input name');
is($input->value, 'Some & text in " here', 'Checking default value');
is($input->{size}, 25, 'Checking size param, set');
is($input->{maxlength}, 200, 'Checking maxlength param, set');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, 'email', $testBlock);

# just testing that getValue works with an argument

my $email = WebGUI::Form::Email->new($session);
is($email->getValue('james@plainblack.com'), 'james@plainblack.com', 'getValue(valid) returned a valid email');
is($email->getValue('this*isn"t and@emailaddres,s'), undef, 'getValue(invalid) returned undef instead of an invalid email');
is($session->form->email(undef,'james@plainblack.com'), 'james@plainblack.com', '$form->email(valid) returned a valid email');
is($session->form->email(undef,'this*isn"t and@emailaddres,s'), undef, '$form->email(invalid) returned undef instead of an invalid email');

__END__

