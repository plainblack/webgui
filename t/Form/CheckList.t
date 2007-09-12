#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

use Tie::IxHash;

use WebGUI::Test;
use WebGUI::Form;
use WebGUI::Form::CheckList;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

# The goal of this test is to verify that CheckList form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $formClass = 'WebGUI::Form::CheckList';
my $formType = 'Checkbox';

my $numTests = 15;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

tie my %options, 'Tie::IxHash', (
    foo     => "Foo",
    bar     => "Bar",
    baz     => "Baz",
);

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'CList1',
		value => ['foo'],
        options => \%options,
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed to test basic functionality');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 3, 'The form has 3 inputs');

#Basic tests

is($inputs[0]->name, 'CList1', 'Checking input name for checkbox 1');
is($inputs[0]->type, 'checkbox', 'Checking input type for checkbox 1');
is($inputs[0]->value, 'foo', 'Checking default value for checkbox 1');
is($inputs[1]->name, 'CList1', 'Checking input name for checkbox 2');
is($inputs[1]->type, 'checkbox', 'Checking input type for checkbox 2');
is($inputs[1]->value, undef, 'Checking default value for checkbox 2');
is($inputs[2]->name, 'CList1', 'Checking input name for checkbox 3');
is($inputs[2]->type, 'checkbox', 'Checking input type for checkbox 3');
is($inputs[2]->value, undef, 'Checking default value for checkbox 3');



### Test Generation of Select All button
my $html = join "\n",
    $header,
    $formClass->new($session, {
        name            => "CList1",
        value           => ['foo'],
        options         => \%options,
        showSelectAll   => 1,
    })->toHtml,
    $footer;

@forms  = HTML::Form->parse($html, 'http://www.webgui.org');
is(scalar @forms, 1, '1 form was parsed to test showSelectAll');

@inputs = $forms[0]->inputs;
is(scalar @inputs, 4, 'The form has 4 inputs (1 button + 3 checkboxes)');

is($inputs[0]->type, 'button', 'The Select All button is there and before all checkboxes');
is( $inputs[0]->{value},
    WebGUI::International->new($session,"Form_CheckList")->get("selectAll label"), 
    'The value is internationalized'
);
