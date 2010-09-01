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
use WebGUI::Form::Password;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Password form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Text1',
		testValue => 'some user value',
		expected  => 'EQUAL',
		comment   => 'Regular text',
	},
	{
		key => 'Text2',
		testValue => "some user value\nwith\r\nwhitespace",
		expected  => "EQUAL",
		comment   => 'Embedded whitespace is left',
	},
];

my $formType = 'password';
my $formClass = 'WebGUI::Form::Password';

my $numTests = 11 + scalar @{ $testBlock } + 1;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestText',
		value => 'Some text in here',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $inputs[1];
use Data::Dumper;
is($input->name, 'TestText', 'Checking input name');
is($input->type, $formType, 'Checking input type');
is($input->value, 'Some text in here', 'Checking default value');
is($input->{size}, 30, 'Default size');
is($input->{maxlength}, 35, 'Default maxlength');

##Form value preprocessing
##Note that HTML::Form will unencode the text for you.

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'preTestText',
		value => q!Some & text in " here!,
		size => 25,
		maxlength => 200,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'preTestText', 'Checking input name');
is($input->value, 'Some & text in " here', 'Checking default value');
is($input->{size}, 25, 'Checking size param, set');
is($input->{maxlength}, 200, 'Checking maxlength param, set');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);
