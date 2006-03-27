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
use WebGUI::Form::Float;
use WebGUI::Session;
use Tie::IxHash;
use HTML::Form;
use Test::MockObject;

#The goal of this test is to verify that Float form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my %testBlock;

tie %testBlock, 'Tie::IxHash';

%testBlock = (
	TestInteger  => [ '-1.23456', 1, 'valid, negative float'],
	TestInteger2 => [ '.23456', 1, 'valid, no integer part'],
	TestInteger3 => [ '123456789.', 1, 'valid, no fractional part'],
	TestInteger4 => [ '-.123456', 1, 'valid, negative, no integer part'],
	TestInteger5 => [ '+123.456', 0, 'invalid, no explicit plus sign'],
	TestInteger6 => [ '123456', 1, 'WRONG, no decimal point'],
	TestInteger7 => [ '......', 1, 'WRONG, no digits'],
	TestInteger8 => [ '.123-456', 0, 'invalid, embedded minus sign'],
);

my $numTests = 6 + scalar keys %testBlock;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::Float->new($session, {
		name => 'TestFloat',
		value => '12.3456',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 input');

#Basic tests

my $input = $inputs[0];
is($input->name, 'TestFloat', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is($input->value, '12.3456', 'Checking default value');
is($input->disabled, undef, 'Disabled param not sent to form');

##Test Form Output parsing

my $request = Test::MockObject->new;
$request->mock('body',
	sub {
		my ($self, $value) = @_;
		return $testBlock{$value}->[0] if (exists $testBlock{$value});
		return;
	}
);

$session->{_request} = $request;

foreach my $key (keys %testBlock) {
	my ($testValue, $passes, $comment) = @{ $testBlock{$key} };
	my $value = $session->form->get($key, 'float');
	is($value, ($passes ? $testValue : 0.0), $comment);
}
##Integer Forms have no special value preprocessing,
