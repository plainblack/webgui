#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Form;
use WebGUI::Form::Date;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Text form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Date1',
		testValue  => '1217608466',
		expected   => '1217608466',
		comment    => 'epoch to epoch',
	},
	{
		key => 'Date2',
		testValue  => "2008-08-01",
		expected   => $session->datetime->setToEpoch("2008-08-01"),#must call this so that value is appropriate for testers timezone
		comment    => 'MySQL formatted to epoch',
	},
	{
		key => 'Date3',
		testValue  => '-1',
		expected   => '-1',
		comment    => 'negative epoch to negative epoch',
	},
];

my $formType = 'date';

my $numTests = 26 + scalar @{ $testBlock } ;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));
my $defaultTime = time();

my $html = join "\n",
	$header, 
	WebGUI::Form::Date->new($session, {
		name => 'TestDate',
		value => $defaultTime,
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 inputs');
#Basic tests
my $input = $inputs[1];

is($input->name, 'TestDate', 'Checking input name');
is($input->type, 'text', 'Checking input type');
is(
    $input->value,
    WebGUI::DateTime->new($session, $defaultTime)->toMysqlDate,
    "Checking default value"
);
is($input->{size}, 10, 'Checking size param, default');
is($input->{maxlength}, 10, 'Checking maxlength param, default');

##Form value preprocessing
##Note that HTML::Form will unencode the text for you.

$html = join "\n",
	$header, 
	WebGUI::Form::Date->new($session, {
		name => 'preDateValue',
		value => 1217608466,
		size => 10,
		maxlength => 10,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'preDateValue', 'Checking input name');
is($input->{size}, 10, 'Checking size param, set');
is($input->{maxlength}, 10, 'Checking maxlength param, set');

##Test Form Output parsing
#Dates to Epoch
WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);


#Dates to MySQL
my $date2;
$date2 = WebGUI::Form::Date->new($session, {'defaultValue' => '2008-08-01 16:34:26'});
is($date2->getValue(1217608466),   '2008-08-01 11:34:26', "getValue, defaultValue MySQL format: Epoch to MySQL");
is($date2->getValue('2008-08-01'), '2008-08-01', "... MySQL to MySQL");
is($date2->getValue(-1),           '1969-12-31 17:59:59', "... Negative epoch to MySQL");

$date2 = WebGUI::Form::Date->new($session);
is($date2->getValue(1217608466),   1217608466, "getValue, no default: Default Epoch to Epoch");
is($date2->getValue('2008-08-01'), 1217566800, "... Default MySQL to Epoch");
is($date2->getValue(-1),           -1,         "... Default negative epoch to negative epoch");

my $bday = WebGUI::Test->webguiBirthday;

$date2 = WebGUI::Form::Date->new($session);
is($date2->getValueAsHtml(), $session->datetime->epochToHuman($date2->getDefaultValue,'%z'), "getValueAsHtml: no defaultValue set, no value set, returns now in user's format");

$date2 = WebGUI::Form::Date->new($session, {defaultValue => 1217608466});
is($date2->getValueAsHtml(), '8/1/2008', "getValueAsHtml: defaultValue in epoch format, returns now in user's format");
is(
    getValueFromForm($session, $date2->toHtmlAsHidden),
    '2008-08-01',
    "toHtmlAsHidden: defaultValue in epoch format, returns date in mysql format"
);
is(
    getValueFromForm($session, $date2->toHtml),
    '2008-08-01',
    "toHtml: defaultValue in epoch format, returns date in mysql format"
);

$date2 = WebGUI::Form::Date->new($session, {defaultValue => '2008-008-001'});
is(
    getValueFromForm($session, $date2->toHtml),
    '1970-01-01',
    "toHtml: defaultValue in bad mysql format returns date from epoch 0"
);

$date2 = WebGUI::Form::Date->new($session, {defaultValue => -1});
is($date2->getValueAsHtml(), '12/31/1969', "getValueAsHtml: defaultValue as negative epoch, returns in users's format");

$date2 = WebGUI::Form::Date->new($session, {defaultValue => '2008-08-01'});
is($date2->getValueAsHtml(), '2008-08-01', "getValueAsHtml: defaultValue in mysql format, returns default value in mysql format");

$date2 = WebGUI::Form::Date->new($session, {defaultValue => '2008-08-01', value => $bday, });
is($date2->getValueAsHtml(), '8/16/2001', "getValueAsHtml: defaultValue in mysql format, value as epoch returns value in user's format");

$date2 = WebGUI::Form::Date->new($session, {defaultValue => '2008-08-01', value => '2001-08-16', });
is($date2->getValueAsHtml(), '2001-08-16', "getValueAsHtml: defaultValue in mysql format, value as mysql returns value in mysql format");

sub getValueFromForm {
    my ($session, $textForm) = @_;
    my ($header, $footer)    = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));
    my @forms = HTML::Form->parse($header.$textForm.$footer, 'http://www.webgui.org');
    my @inputs = $forms[0]->inputs;
    return $inputs[1]->{value};
}
