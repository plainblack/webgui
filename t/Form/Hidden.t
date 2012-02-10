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
use WebGUI::Form::Hidden;
use WebGUI::Session;
use HTML::Form;
use Tie::IxHash;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Zipcode form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Hidden1',
		testValue => 'ABCDEzyxwv',
		expected  => 'EQUAL',
		comment   => 'alpha',
	},
	{
		key => 'Hidden2',
		testValue => '02468',
		expected  => 'EQUAL',
		comment   => 'numeric',
	},
	{
		key => 'Hidden3',
		testValue => 'NO WHERE',
		expected  => 'EQUAL',
		comment   => 'alpha space',
	},
	{
		key => 'Hidden4',
		testValue => '-.&*(',
		expected  => 'EQUAL',
		comment   => 'punctuation',
	},
	{
		key => 'Hidden5',
		testValue => ' \t\n\tdata',
		expected  => 'EQUAL',
		comment   => 'white space',
	},
	{
		key => 'Hidden6',
		testValue => 0,
		expected  => 'EQUAL',
		comment   => 'zero',
	},
];

my $formClass = 'WebGUI::Form::Hidden';

my $numTests = 7 + scalar @{ $testBlock } + 1;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestHidden',
		value => 'hiddenData',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestHidden', 'Checking input name');
is($input->type, 'hidden', 'Checking input type');
is($input->value, 'hiddenData', 'Checking default value');

##no need for secondary checking for now

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'hiddenZero',
		value => 0,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'hiddenZero', 'Checking input name for zero input');
is($input->value, 0,           'Checking value for zero input');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, 'Hidden', $testBlock);
