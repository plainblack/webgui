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
use Tie::IxHash;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Phone form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my %testBlock;

tie %testBlock, 'Tie::IxHash';

%testBlock = (
	PHONE1 => [ "503\n867\n5309",  undef, 'newline separation'],
	PHONE2 => [ '503 867 5309',  'EQUAL', 'valid: space separation'],
	PHONE3 => [ '503.867.5309',  'EQUAL', 'valid: dot separation'],
	PHONE4 => [ '503 867 5309 x227',  undef, 'WRONG: extension syntax rejectd'],
	PHONE5 => [ '()()()',  undef, 'invalid: no digits'],
	PHONE6 => [ '------',  undef, 'invalid: no digits'],
	PHONE7 => [ "\n",  undef, 'invalid: no digits'],
	PHONE8 => [ "++++",  undef, 'invalid: no digits'],
);

my $formClass = 'WebGUI::Form::Phone';
my $formType = 'Phone';

my $numTests = 12 + scalar keys %testBlock;

diag("Planning on running $numTests tests\n");

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
is($input->disabled, undef, 'Disabled param not sent to form');
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

WebGUI::Form_Checking::auto_check($session, $formType, %testBlock);

