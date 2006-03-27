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
use WebGUI::Form::Url;
use WebGUI::Session;
use HTML::Form;
use Tie::IxHash;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Url form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my %testBlock;

tie %testBlock, 'Tie::IxHash';

%testBlock = (
	Email1 => [ 'mailto:whatever', 'EQUAL', 'mailto processing'],
	Email2 => [ 'me@nowhere.com', 'mailto:me@nowhere.com', 'email address processing'],
	Email3 => [ '/', 'EQUAL', 'Url'],
	Email4 => [ '://', 'EQUAL', 'colon'],
	Email5 => [ '^', 'EQUAL', 'caret'],
	Email6 => [ 'mySite', 'http://mySite', 'bare hostname'],
	Email7 => [ '??**()!!', 'http://??**()!!', 'WRONG: random crap is passed through'],
);

my $formClass = 'WebGUI::Form::Url';

my $numTests = 12 + scalar keys %testBlock;

diag("Planning on running $numTests tests\n");

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
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestUrl', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, 'http://www.webgui.org', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');
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
$input = $inputs[0];
is($input->name, 'preTestUrl', 'Checking input name');
is($input->value, 'http://www.webgui.org?foo=bar&baz=buz', 'Checking default value');
is($input->{size}, 25, 'set size');
is($input->{maxlength}, 1024, 'set maxlength');

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, 'Url', %testBlock);
