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
use WebGUI::Form::SelectList;
use WebGUI::Session;
use HTML::Form;
use Tie::IxHash;
use WebGUI::Form_Checking;

#The goal of this test is to verify that SelectList form elements work

use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

# put your tests here

my %testBlock;

tie %testBlock, 'Tie::IxHash';

%testBlock = (
	#INT1 => [ '-123456',  'EQUAL', 'valid, negative integer'],
	#INT2 => [ '+123456',  0, 'reject explicitly positive integer'],
);

my $formClass = 'WebGUI::Form::SelectList';
my $formType = 'SelectList';

my $numTests = 5 + scalar keys %testBlock;

diag("Planning on running $numTests tests\n");

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'ListMultiple',
		options => { a=>'a', b=>'b', c=>'c', d=>'d', e=>'e' },
		value => [ qw(a c e)],
		sortByValue => 1,
	})->toHtml,
	$footer;

diag($html);

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

#use Data::Dumper;
#diag(Dumper \@forms);

my $form = $forms[0];
my @inputs = $form->inputs;
is(scalar @inputs, 5, 'The form has 5 inputs');

#Basic tests

my @names = $form->param();
is (scalar @names, 1, 'Only 1 name');
is (scalar(grep {$_ ne 'ListMultiple'} @names), 0, 'All names are ListMultiple');

my $input = $form->find_input("ListMultiple");
is($input->type, 'option', 'Checking input type');
diag(join ":", $form->find_input("ListMultiple")->possible_values());
#cmp_bag([ $form->find_input("ListMultiple")->possible_values() ], [qw(a b c d e)], 'all options are present');
#cmp_bag([ $input->value ], [qw(a c e)], 'preselected values');


