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

my $numTests = 7 + scalar @{ $testBlock } + 6;


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
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestText', 'Checking input name');
is($input->type, $formType, 'Checking input type');
is($input->value, 'Some text in here', 'Checking default value');

$html = join "\n",
	$header, 
	WebGUI::Form::Textarea->new($session, {
		name => 'preTestText',
		value => q!Some & text in " here!,
		height => 200,
		width => 500,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'preTestText', 'Checking input name');
is($input->value, 'Some & text in " here', 'Checking default value');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

# just testing that getValue works with an argument

my $txt = WebGUI::Form::Textarea->new($session);
is($txt->getValue("some test here"), "some test here", 'getValue(text)');
is($txt->getValue("some \ntest \r\nhere"), "some \ntest \r\nhere", 'getValue(newlines)');

is($session->form->textarea(undef,"some test here"), "some test here", 'session->form->textarea(undef,text)');
is($session->form->textarea(undef,"some \ntest \r\nhere"), "some \ntest \r\nhere", 'session->form->textarea(undef,newlines)');

###################################################################
#
# getValueAsHtml
#
###################################################################

$txt = WebGUI::Form::Textarea->new($session, { value => "line1\nline2\nline3", });
is($txt->getValueAsHtml, "line1<br />\nline2<br />\nline3", 'getValueAsHtml translates newlines into break tags');


__END__

