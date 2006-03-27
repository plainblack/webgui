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
use WebGUI::Form::Hidden;
use WebGUI::Session;
use HTML::Form;
use Tie::IxHash;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Zipcode form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my %testBlock;

tie %testBlock, 'Tie::IxHash';

%testBlock = (
	HIDDEN1 => [ 'ABCDEzyxwv', 'EQUAL', 'alpha'],
	HIDDEN2 => [ '02468', 'EQUAL', 'numeric'],
	HIDDEN3 => [ 'NO WHERE', 'EQUAL', 'alpha space'],
	HIDDEN4 => [ '-.&*(', 'EQUAL', 'punctuation'],
	HIDDEN5 => [ " \t\n\tdata", 'EQUAL', 'white space'],
);

my $formClass = 'WebGUI::Form::Hidden';

my $numTests = 6 + scalar keys %testBlock;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestHidden',
		value => 'hiddenData',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestHidden', 'Checking input name');
is($input->type, 'hidden', 'Checking input type');
is($input->value, 'hiddenData', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');

##no need for secondary checking for now

##Test Form Output parsing

WebGUI::Form_Checking::auto_check($session, 'Hidden', %testBlock);
