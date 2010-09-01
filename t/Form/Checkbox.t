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
use WebGUI::Form::Checkbox;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Checkbox form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'CHECK1',
		testValue => 'string1',
		expected  => 'EQUAL',
		comment   => 'string check'
	},
	{
		key => 'CHECK2',
		testValue => '002300',
		expected  => 'EQUAL',
		comment   => 'valid, leading zeroes'
	},
];

my $formClass = 'WebGUI::Form::Checkbox';
my $formType = 'Checkbox';

my $numTests = 8 + scalar @{ $testBlock } + 3;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'CBox1',
		value => 'Checkme',
		checked => 1,
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 input');

#Basic tests

my $input = $inputs[1];
is($input->name, 'CBox1', 'Checking input name');
is($input->type, 'checkbox', 'Checking input type');
is($input->value, 'Checkme', 'Checking default value');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'cbox2',
		value => '024680',
		checked => 1,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
is( $forms[0]->param('cbox2'), '024680', 'numeric values');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'cbox3',
		value => '    ',
		checked => 1,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
is( $forms[0]->param('cbox3'), '    ', 'WRONG: whitespace value');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'cbox0',
		value => 0,
		checked => 1,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
is( $forms[0]->param('cbox0'), 0, 'zero is a valid value');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

#
# test WebGUI::FormValidator::Checkbox(undef,@values)
#
is(WebGUI::Form::Checkbox->new($session)->getValue('test'), 'test', '$cbox->getValue(arg)');
is($session->form->checkbox(undef,'test'),                          'test', 'WebGUI::FormValidator::checkbox');
