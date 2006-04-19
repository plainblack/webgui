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
use WebGUI::Form::Phone;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Phone form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Phone1',
		testValue => '503\n867\n5309',
		expected  => undef,
		comment   => 'newline separation',
	},
	{
		key => 'Phone2',
		testValue => '503 867 5309',
		expected  => 'EQUAL',
		comment   => 'valid: space separation',
	},
	{
		key => 'Phone3',
		testValue => '503.867.5309',
		expected  => 'EQUAL',
		comment   => 'valid: dot separation',
	},
	{
		key => 'Phone4',
		testValue => '503 867 5309 x227',
		expected  => 'EQUAL',
		comment   => 'valid: extension syntax rejectd',
	},
	{
		key => 'Phone5',
		testValue => '()()()',
		expected  => undef,
		comment   => 'invalid: parens only, no digits',
	},
	{
		key => 'Phone6',
		testValue => '------',
		expected  => undef,
		comment   => 'invalid: dashes only, no digits',
	},
	{
		key => 'Phone7',
		testValue => "\n",
		expected  => undef,
		comment   => 'invalid: newline only, no digits',
	},
	{
		key => 'Phone8',
		testValue => '++++',
		expected  => undef,
		comment   => 'invalid, plusses only, no digits',
	},
	{
		key => 'Phone9',
		testValue => '0xx31 3456 1234',
		expected  => 'EQUAL',
		comment   => 'Brazilian long distance',
	},
];

my $formClass = 'WebGUI::Form::Phone';
my $formType = 'Phone';

my $numTests = 11 + scalar @{ $testBlock } + 1;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestPhone',
		value => '(555)867-5309',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestPhone', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, '(555)867-5309', 'Checking default value');
is($input->{size}, 30, 'Default size');
is($input->{maxlength}, 255, 'Default maxlength');

##Test Form Output parsing

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'EuroPhone',
		value => '123.456.7890',
		size => 15,
		maxlength => 20,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
my $input = $inputs[0];
is($input->name, 'EuroPhone', 'Checking input name');
is($input->value, '123.456.7890', 'Checking default value');
is($input->{size}, 15, 'set size');
is($input->{maxlength}, 20, 'set maxlength');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

