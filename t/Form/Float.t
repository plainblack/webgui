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
use WebGUI::Form::Float;
use WebGUI::Session;
use Tie::IxHash;
use HTML::Form;
use Tie::IxHash;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Float form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my %testBlock;

tie %testBlock, 'Tie::IxHash';

%testBlock = (
	FLOAT1 => [ '-1.23456',   'EQUAL', 'valid, negative float'],
	FLOAT2 => [ '.23456',     'EQUAL', 'valid, no integer part'],
	FLOAT3 => [ '123456789.', 'EQUAL', 'valid, no fractional part'],
	FLOAT4 => [ '-.123456',   'EQUAL', 'valid, negative, no integer part'],
	FLOAT5 => [ '+123.456',    0, 'invalid, no explicit plus sign'],
	FLOAT6 => [ '123456',      'EQUAL', 'WRONG, no decimal point'],
	FLOAT7 => [ '......',      0, 'invalid, no digits'],
	FLOAT8 => [ '-00789.25',   'EQUAL', 'leading zeroes are okay'],
	FLOAT9 => [ '.123-456',    0, 'invalid, embedded minus sign'],
);

my $formClass = 'WebGUI::Form::Float';
my $formType = 'Float';

my $numTests = 12 + scalar keys %testBlock;

diag("Planning on running $numTests tests\n");

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
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestFloat', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, '12.3456', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');
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
my $input = $inputs[0];
is($input->name, 'TestFloat2', 'Checking input name');
is($input->value, '00789.25', 'Checking default value');
is($input->{size}, 15, 'set size');
is($input->{maxlength}, 20, 'set maxlength');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, %testBlock);

