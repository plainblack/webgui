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

my $numTests = 23;


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
is(scalar @inputs, 5, 'The form has 5 inputs');

#Basic tests

is($inputs[1]->name, '__CList1_isIn', 'Checking input name for hidden element');
is($inputs[1]->type, 'hidden', 'Checking input type for hidden element');
is($inputs[1]->value, '1', 'Checking default value for hidden element');
is($inputs[2]->name, 'CList1', 'Checking input name for checkbox 1');
is($inputs[2]->type, 'checkbox', 'Checking input type for checkbox 1');
is($inputs[2]->value, 'foo', 'Checking default value for checkbox 1');
is($inputs[3]->name, 'CList1', 'Checking input name for checkbox 2');
is($inputs[3]->type, 'checkbox', 'Checking input type for checkbox 2');
is($inputs[3]->value, undef, 'Checking default value for checkbox 2');
is($inputs[4]->name, 'CList1', 'Checking input name for checkbox 3');
is($inputs[4]->type, 'checkbox', 'Checking input type for checkbox 3');
is($inputs[4]->value, undef, 'Checking default value for checkbox 3');



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
is(scalar @inputs, 6, 'The form has 6 inputs (CSRF, 1 hidden, 1 button, 3 checkboxes)');

is($inputs[2]->type, 'button', 'The Select All button is there and before all checkboxes');
is( $inputs[2]->{value},
    WebGUI::International->new($session,"Form_CheckList")->get("selectAll label"), 
    'The value is internationalized'
);

my $cl = WebGUI::Form::CheckList->new($session, {defaultValue => 'default'});
is($cl->getValue(),'default','Check getvalue with null returns default value'); 
is($cl->getValue("value"), "value", "Check getValue returns a value");
$cl->set('value',"original");
is($cl->getDefaultValue(), "default", "Check getDefaultValue returns the default value");
my $c2 = WebGUI::Form::CheckList->new($session, {defaultValue => 'default'});
is($c2->getOriginalValue(), "default", "Get original value returns the default value");
$c2->set('value',"original");
is($c2->getOriginalValue(), "original", "Get original value return original value");
