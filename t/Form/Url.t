#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Form::Url;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Url form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Url1',
		testValue => 'mailto:whatever',
		expected  => 'EQUAL',
		comment   => 'mailto processing',
	},
	{
		key => 'Url2',
		testValue => 'me@nowhere.com',
		expected  => 'mailto:me@nowhere.com',
		comment   => 'email address processing',
	},
	{
		key => 'Url3',
		testValue => '/',
		expected  => 'EQUAL',
		comment   => 'Bare slash',
	},
	{
		key => 'Url4',
		testValue => '://',
		expected  => 'EQUAL',
		comment   => 'colon slash slash',
	},
	{
		key => 'Url5',
		testValue => '^',
		expected  => 'EQUAL',
		comment   => 'caret',
	},
	{
		key => 'Url6',
		testValue => 'mySite',
		expected  => 'http://mySite',
		comment   => 'bare hostname',
	},
	{
		key => 'Url7',
		testValue => '??**()!!',
		expected  => 'http://??**()!!',
		comment   => 'WRONG: random crap is passed through',
	},
];

my $formClass = 'WebGUI::Form::Url';

my $numTests = 11 + scalar @{ $testBlock } + 15;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestUrl',
		value => 'http://www.webgui.org',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestUrl', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, 'http://www.webgui.org', 'Checking default value');
is($input->{size}, 30, 'Checking size param, default');
is($input->{maxlength}, 2048, 'Checking maxlength param, default');

##Form value preprocessing
##Note that HTML::Form will unencode the text for you.

$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'preTestUrl',
		value => q!http://www.webgui.org?foo=bar&baz=buz!,
		size => 25,
		maxlength => 1024,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'preTestUrl', 'Checking input name');
is($input->value, 'http://www.webgui.org?foo=bar&baz=buz', 'Checking default value');
is($input->{size}, 25, 'set size');
is($input->{maxlength}, 1024, 'set maxlength');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, 'Url', $testBlock);

# test that we can process non-POST values correctly
my $cntl = WebGUI::Form::Url->new($session,{ defaultValue => 4242 });
is($cntl->getValue('mailto:whatever'), 'mailto:whatever', 'mailto processing');
is($cntl->getValue('me@nowhere.com'), 'mailto:me@nowhere.com', 'email address processing');
is($cntl->getValue('/'), '/', '/');
is($cntl->getValue('://'), '://', '://');
is($cntl->getValue('^'), '^', '^');
is($cntl->getValue('mySite'), 'http://mySite', 'http://mySite');
is($cntl->getValue('??**()!!'), 'http://??**()!!', 'random crap is passed through');

is($session->form->url(undef,'mailto:whatever'), 'mailto:whatever', 'mailto processing');
is($session->form->url(undef,'me@nowhere.com'), 'mailto:me@nowhere.com', 'email address processing');
is($session->form->url(undef,'/'), '/', '/');
is($session->form->url(undef,'://'), '://', '://');
is($session->form->url(undef,'^'), '^', '^');
is($session->form->url(undef,'mySite'), 'http://mySite', 'http://mySite');
is($session->form->url(undef,'??**()!!'), 'http://??**()!!', 'random crap is passed through');

__END__

