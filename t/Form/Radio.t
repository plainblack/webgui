#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Form::Radio;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Radio form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'RADIO1',
		testValue => 'string1',
		expected  => 'EQUAL',
		comment   => 'string check'
	},
	{
		key => 'RADIO2',
		testValue => '002300',
		expected  => 'EQUAL',
		comment   => 'valid, leading zeroes'
	},
];

my $formClass = 'WebGUI::Form::Radio';
my $formType = 'Radio';

my $numTests = 8 + scalar @{ $testBlock } + 1;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'radio1',
		value => 'Selectify',
		checked => 1,
	})->toHtml,
	$footer;
use Data::Dumper;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests
my $input = $inputs[1];
is($input->name, 'radio1', 'Checking input name');
is($input->type, 'radio', 'Checking input type');
is($input->value, 'Selectify', 'Checking default value');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'radio2',
		value => '024680',
		checked => 1,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
is( $forms[0]->param('radio2'), '024680', 'numeric values');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'radio2',
		value => '    ',
		checked => 1,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
is( $forms[0]->param('radio2'), '    ', 'WRONG: whitespace value');

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'radio3',
		value => 0,
		checked => 1,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
is( $forms[0]->param('radio3'), 0, 'zero is a valid value');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

