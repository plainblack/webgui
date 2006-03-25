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
use Test::MockObject;

#The goal of this test is to verify that Url form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $numTests = 14;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Text->new($session, {
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

##Test Form Output parsing

my $request = Test::MockObject->new;
$request->mock('body',
	sub {
		my ($self, $value) = @_;
		my @return = ();
		return 'mailto:whatever' if ($value eq 'mailto_test');
		return 'me@nowhere.com' if ($value eq 'address_test');
		return "/" if ($value eq 'leading_slash');
		return "://" if ($value eq 'colon');
		return "^" if ($value eq 'caret');
		return "mySite" if ($value eq 'host');
		return;
	}
);
$session->{_request} = $request;

my $value = $session->form->get('mailto_test', 'Url');
is($value, 'mailto:whatever', 'checking mailto processing');
$value = $session->form->get('address_test', 'Url');
is($value, 'mailto:me@nowhere.com', 'checking email address processing');
$value = $session->form->get('leading_slash', 'Url');
is($value, '/', 'checking leading slash');
$value = $session->form->get('colon', 'Url');
is($value, '://', 'checking colon slash slash');
$value = $session->form->get('caret', 'Url');
is($value, '^', 'checking leading caret');
$value = $session->form->get('host', 'Url');
is($value, 'http://mySite', 'checking host');

##Form value preprocessing
##Note that HTML::Form will unencode the text for you.

$html = join "\n",
	$header, 
	WebGUI::Form::Text->new($session, {
		name => 'preTestUrl',
		value => q!http://www.webgui.org?foo=bar&baz=buz!,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[0];
is($input->name, 'preTestUrl', 'Checking input name');
is($input->value, 'http://www.webgui.org?foo=bar&baz=buz', 'Checking default value');
