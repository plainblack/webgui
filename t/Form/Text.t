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
use WebGUI::Form::Text;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Text form elements work

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
		expected  => "some user valuewithwhitespace",
		comment   => 'Embedded whitespace is stripped',
	},
	{
		key => 'Text3',
		testValue => 'conCatenatedText',
		expected  => 'EQUAL',
		comment   => 'single word',
	},
	{
		key => 'Text4',
		testValue => '0leadingzero',
		expected  => 'EQUAL',
		comment   => 'leading zero',
	},
];

my $formType = 'text';

my $numTests = 11 + scalar @{ $testBlock } + 9;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Text->new($session, {
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
is($input->name, 'TestText', 'Checking input name');
is($input->type, $formType, 'Checking input type');
is($input->value, 'Some text in here', 'Checking default value');
is($input->{size}, 30, 'Checking size param, default');
is($input->{maxlength}, 255, 'Checking maxlength param, default');

##Form value preprocessing
##Note that HTML::Form will unencode the text for you.

$html = join "\n",
	$header, 
	WebGUI::Form::Text->new($session, {
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

# test that we can process non-POST values correctly
my $cntl = WebGUI::Form::Text->new($session,{ defaultValue => 4242 });
is($cntl->getValue('123-123-1234'), '123-123-1234', 'getValue(valid)');
is($cntl->getValue(0), 0, 'zero');
is($cntl->getValue(''), '', '""');
is($cntl->getValue(undef), 0, 'undef returns 0');
is($session->form->text(undef,'123-123-1234'), '123-123-1234', 'valid');
is($session->form->text(undef,0), 0, 'zero');
is($session->form->text(undef,undef), 0, 'undef returns 0');
is($session->form->text(undef,''), '', '""');

__END__

