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
		testValue => 'what do you want?',
		expected  => undef,
		comment   => 'not an email address'
	},
];

my $formType = 'text';
my $formClass = 'WebGUI::Form::Email';

my $numTests = 12 + scalar @{ $testBlock } + 1;

diag("Planning on running $numTests tests\n");

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
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestEmail', 'Checking input name');
is($input->type, $formType, 'Checking input type');
is($input->value, 'me@nowhere.com', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');
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
$input = $inputs[0];
is($input->name, 'email2', 'Checking input name');
is($input->value, 'Some & text in " here', 'Checking default value');
is($input->{size}, 25, 'Checking size param, set');
is($input->{maxlength}, 200, 'Checking maxlength param, set');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, 'email', $testBlock);
