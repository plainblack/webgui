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
use WebGUI::Form::SelectBox;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that SelectBox form elements work

use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Box1',
		testValue => [qw/a/],
		expected  => 'a',
		comment   => 'return a scalar',
		dataType   => 'SCALAR',
	},
	{
		key => 'Box2',
		testValue => [qw/ z y x/],
		expected  => 'z',
		comment   => 'first element',
		dataType   => 'SCALAR',
	},
];

my $formClass = 'WebGUI::Form::SelectBox';
my $formType = 'SelectBox';

my $numTests = 8 + scalar @{ $testBlock } + 12;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'ListBox',
		options => { a=>'aa', b=>'bb', c=>'cc', d=>'dd', e=>'ee', ''=>'Empty' },
		value => 'c',
		sortByValue => 1,
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my $form = $forms[0];
#use Data::Dumper;
my @inputs = $form->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

#Basic tests

my $input = $form->find_input('ListBox');
is($input->name, 'ListBox', 'Checking input name');
is($input->type, 'option', 'Checking input type');
is($input->value, 'c', 'Checking default value');
is($input->{size}, 1, 'default size');


$html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'ListBox2',
		options => { a=>'aa', b=>'bb', c=>'cc', d=>'dd', e=>'ee' },
		value => [ qw(a b c) ],
		sortByValue => 1,
		size => 5,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
$form = $forms[0];

my $input = $form->find_input('ListBox2');
is($form->param('ListBox2'), 'a', 'if array passed to value first value is used');
is($input->{size}, 5, 'set size');


##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

# test that we can process non-POST values correctly
my $cntl = WebGUI::Form::SelectBox->new($session,{ defaultValue => 4242 });
is($cntl->getValue('text'), 'text', 'getValue(text)');
is($cntl->getValue(42), 42, 'getValue(int)');
is($cntl->getValue(0), 0, 'zero');
is($cntl->getValue(''), '', '""');
is($cntl->getValue(1,2,3), 1, 'list returns first item');
is($session->form->selectBox(undef,'text'), 'text', 'text');
is($session->form->selectBox(undef,42), 42, 'int');
is($session->form->selectBox(undef,0), 0, 'zero');
is($session->form->selectBox(undef,undef), 0, 'undef returns 0');
is($session->form->selectBox(undef,''), '', '""');
is($session->form->selectBox(undef,1,2,3), 1, 'list returns first item');

