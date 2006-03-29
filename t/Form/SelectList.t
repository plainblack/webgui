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

#use Data::Dumper;
#diag(Dumper $form);

my @options = $form->find_input('ListMultiple');

is( scalar(grep {$_->type ne 'option'} @options), 0, 'All inputs are of type option');

my @names = map { $_->name } @options;
cmp_bag( [@names], [ ('ListMultiple')x5 ], 'correct number of names and names');

cmp_bag([ $form->param('ListMultiple') ], [qw(a c e)], 'preselected values');

my @values = map { $_->possible_values } @options;
#cmp_bag([ @values ], [qw(a b c d e), ('')x5], 'list of all options');
