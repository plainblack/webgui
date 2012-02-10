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
use WebGUI::Form::Float;
use WebGUI::Session;
use Tie::IxHash;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Float form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'FLOAT1',
		testValue => '-1.23456',
		expected  => 'EQUAL',
		comment   => 'valid, negative float'
	},
	{
		key => 'FLOAT2',
		testValue => '.23456',
		expected  => 'EQUAL',
		comment   => 'valid, no integer part'
	},
	{
		key => 'FLOAT3',
		testValue => '123456789.',
		expected  => 'EQUAL',
		comment   => 'valid, no fractional part'
	},
	{
		key => 'FLOAT4',
		testValue => '-.123456',
		expected  => 'EQUAL',
		comment   => 'valid, negative, no integer part'
	},
	{
		key => 'FLOAT5',
		testValue => '+123.456',
		expected  => '0',
		comment   => 'invalid, no explicit plus sign'
	},
	{
		key => 'FLOAT6',
		testValue => '123456',
		expected  => 'EQUAL',
		comment   => 'WRONG, no decimal point'
	},
	{
		key => 'FLOAT7',
		testValue => '......',
		expected  => 0,
		comment   => 'invalid, no digits'
	},
	{
		key => 'FLOAT8',
		testValue => '-00789.25',
		expected  => 'EQUAL',
		comment   => 'leading zeroes are okay'
	},
	{
		key => 'FLOAT9',
		testValue => '.123-456',
		expected  => 0,
		comment   => 'invalid, embedded minus sign'
	},
];

my $formClass = 'WebGUI::Form::Float';
my $formType = 'Float';

my $numTests = 11 + scalar @{ $testBlock } + 3;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestFloat',
		value => '12.3456',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestFloat', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, '12.3456', 'Checking default value');
is($input->{size}, 11, 'Default size');
is($input->{maxlength}, 14, 'Default maxlength');

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestFloat2',
		value => '00789.25',
		size => 15,
		maxlength => 20,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
my $input = $inputs[1];
is($input->name, 'TestFloat2', 'Checking input name');
is($input->value, '00789.25', 'Checking default value');
is($input->{size}, 15, 'set size');
is($input->{maxlength}, 20, 'set maxlength');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

# just testing that getValue works with an argument

my $float = WebGUI::Form::Float->new($session);
is($float->getValue('112.233'), 112.233, 'Got a valid float');
is($float->getValue('fred'), 0, 'Returned 0 instead of an invalid float');

__END__

