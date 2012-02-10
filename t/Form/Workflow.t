#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Form::Workflow;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that SelectBox form elements work

use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

# put your tests here

plan tests => 5;

my $plugin = WebGUI::Form::Workflow->new($session,{
    name         => 'Workflowage',
    none         => 1,
    noneLabel    => 'none',
    #defaultValue => 'pbworkflow000000000006',
    defaultValue => '',
    type         => 'WebGUI::VersionTag',
    value        => '',
});

is $plugin->getOriginalValue, '', 'value set to empty string';
is $plugin->getDefaultValue, '', 'default value set to a valid workflow';

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
    $plugin->toHtml;
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my $form = $forms[0];
#use Data::Dumper;
my @inputs = $form->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');

my $input = $form->find_input('Workflowage');
is($form->param('Workflowage'), '', 'Empty string is the default');


###Test Form Output parsing
#
#WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);
#
## test that we can process non-POST values correctly
#my $cntl = WebGUI::Form::SelectBox->new($session,{ defaultValue => 4242 });
#is($cntl->getValue('text'), 'text', 'getValue(text)');
#is($cntl->getValue(42), 42, 'getValue(int)');
#is($cntl->getValue(0), 0, 'zero');
#is($cntl->getValue(''), '', '""');
#is($cntl->getValue(1,2,3), 1, 'list returns first item');
#is($session->form->selectBox(undef,'text'), 'text', 'text');
#is($session->form->selectBox(undef,42), 42, 'int');
#is($session->form->selectBox(undef,0), 0, 'zero');
#is($session->form->selectBox(undef,undef), 0, 'undef returns 0');
#is($session->form->selectBox(undef,''), '', '""');
#is($session->form->selectBox(undef,1,2,3), 1, 'list returns first item');


