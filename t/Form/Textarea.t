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
use WebGUI::Form::Textarea;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Textarea form elements work

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

my $formType = 'textarea';

my $numTests = 13 + scalar @{ $testBlock } + 1;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Textarea->new($session, {
		name => 'TestText',
		value => 'Some text in here',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestText', 'Checking input name');
is($input->type, $formType, 'Checking input type');
is($input->value, 'Some text in here', 'Checking default value');
is($input->{rows}, 5, 'Default number of rows');
is($input->{cols}, 50, 'Default number of columns');
is($input->{wrap}, 'virtual', 'Default wrap');

$html = join "\n",
	$header, 
	WebGUI::Form::Textarea->new($session, {
		name => 'preTestText',
		value => q!Some & text in " here!,
		rows => 10,
		columns => 80,
		wrap => 'off'
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[0];
is($input->name, 'preTestText', 'Checking input name');
is($input->value, 'Some & text in " here', 'Checking default value');
is($input->{rows}, 10, 'set number of rows');
is($input->{cols}, 80, 'set number of columns');
is($input->{wrap}, 'off', 'set wrap to off');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);
