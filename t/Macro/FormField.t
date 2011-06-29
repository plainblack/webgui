#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2011 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Macro::AdminBar;
use HTML::TokeParser;
use HTML::Form;
use Tie::IxHash;
use WebGUI::Form_Checking;
use WebGUI::Macro::FormField;

use Test::More; # increment this value for each test you create
use Test::Deep;

use Data::Dumper;

my $session = WebGUI::Test->session;

# taken from t/Form/SelectList.t

my $testBlock = [
	{
		key => 'List1',
		testValue => [qw/a/],
		expected  => 'a',
		comment   => 'single element array, scalar',
		dataType  => 'SCALAR'
	},
	{
		key => 'List2',
		testValue => [qw/a/],
		expected  => 'EQUAL',
		comment   => 'single element array, array',
		dataType  => 'ARRAY'
	},
	{
		key => 'List3',
		testValue => [qw/a b c/],
		expected  => "a\nb\nc",
		comment   => 'multi element array, scalar',
		dataType  => 'SCALAR'
	},
	{
		key => 'List4',
		testValue => [qw/a b c/],
		expected  => 'EQUAL',
		comment   => 'multi element array, array',
		dataType  => 'ARRAY'
	},
];

my $formType = 'SelectList';

my $output;
$output = WebGUI::Macro::FormField::process(
    $session, 'SelectList', 'ListMultiple', [ qw(a c e), ''],   # args to macro
                                                   # args to particular Form subclass
    options => { a=>'aa', b=>'bb', c=>'cc', d=>'dd', e=>'ee', ''=>'Empty' },
    value => [ qw(a c e), ''],
    sortByValue => 1,
);

warn $output;

my $numTests = 11 + scalar @{ $testBlock } + 1;

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n", $header, $output, $footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my $form = $forms[0];
use Data::Dumper; warn Data::Dumper::Dumper $form; # XXX
my @inputs = $form->inputs;
is(scalar @inputs, 8, 'The form has 8 inputs');

#Basic tests

my @options = $form->find_input('ListMultiple');

is( scalar(grep {$_->type ne 'option'} @options), 0, 'All inputs are of type option');

is( scalar(grep {$_->{multiple} ne 'multiple'} @options), 0, 'All inputs have multiple');

my @names = map { $_->name } @options;
cmp_deeply( [@names], bag(('ListMultiple')x6), 'correct number of names and names');

cmp_set([ $form->param('ListMultiple') ], [qw(a c e), ''], 'preselected values in order');

my @values = map { $_->possible_values } @options;
cmp_bag([ @values ], [qw(a b c d e), '', (undef)x6], 'list of all options');

my @value_names = map { $_->value_names } @options;
cmp_bag([ @value_names ], [qw(aa bb cc dd ee Empty), ('off')x6], 'list of all displayed value names');

