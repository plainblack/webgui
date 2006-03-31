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
use WebGUI::Form_Checking;

#The goal of this test is to verify that Integer form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Int1',
		testValue => '-123456',
		expected  => 'EQUAL',
		comment   => 'valid, negative integer',
	},
	{
		key => 'Int2',
		testValue => '002300',
		expected  => 'EQUAL',
		comment   => 'valid, leading zeroes',
	},
	{
		key => 'Int3',
		testValue => '+123456',
		expected  => 0,
		comment   => 'reject explicitly positive integer',
	},
	{
		key => 'Int4',
		testValue => '123-456.',
		expected  => 0,
		comment   => 'rejects non-sense integer with negative sign',
	},
	{
		key => 'Int5',
		testValue => '123.456',
		expected  => 0,
		comment   => 'rejects float',
	},
];

my $formClass = 'WebGUI::Form::Integer';
my $formType = 'Integer';

my $numTests = 12 + scalar @{ $testBlock } + 1;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
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
is($input->{size}, 11, 'Default size');
is($input->{maxlength}, 11, 'Default maxlength');

##Test Form Output parsing

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestInt2',
		value => '98765',
		size => 15,
		maxlength => 20,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
my $input = $inputs[0];
is($input->name, 'TestInt2', 'Checking input name');
is($input->value, '98765', 'Checking default value');
is($input->{size}, 15, 'set size');
is($input->{maxlength}, 20, 'set maxlength');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

