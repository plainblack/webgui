#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Form::DateTime;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Text form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $formType = 'datetime';

my $numTests = 35;

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));
my $defaultTime = time();

my $html = join "\n",
	$header, 
	WebGUI::Form::DateTime->new($session, {
		name => 'TestDate',
		value => $defaultTime,
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 1 inputs');
#Basic tests
my $input = $inputs[1];

is($input->name, 'TestDate', 'Checking input name');
is($input->type, 'text', 'Checking input type');
#is($input->value, $defaultTime, "Checking default value");
is($input->{size}, 19, 'Checking size param, default');
is($input->{maxlength}, 19, 'Checking maxlength param, default');

##Form value preprocessing
##Note that HTML::Form will unencode the text for you.

$html = join "\n",
	$header, 
	WebGUI::Form::DateTime->new($session, {
		name => 'preDateValue',
		value => 1217608466,
		size => 19,
		maxlength => 19,
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
$input = $inputs[1];
is($input->name, 'preDateValue', 'Checking input name');
#is($input->value, 1217608466, 'Checking default value');
is($input->{size}, 19, 'Checking size param, set');
is($input->{maxlength}, 19, 'Checking maxlength param, set');

#########################################
#
# getValue
#
#########################################

my $date1 = WebGUI::Form::DateTime->new($session, {'defaultValue' => time()});
$session->user->profileField( 'timeZone' , 'America/Chicago');
is($date1->getValue(1217608466),            1217608466, "getValue, defaultValue epoch: Epoch to Epch");
is($date1->getValue('2008-08-01 16:34:26'), 1217626466, "... MySQL to Epoch");
is($date1->getValue(-1),                    -1,         "... negative epoch to epoch");

my $date2 = WebGUI::Form::DateTime->new($session);
is($date2->getValue(1217608466),             1217608466, "getValue, no default: Default Epoch to Epch");
is($date2->getValue('2008-08-01 16:34:26'),  1217626466, "... Default MySQL to Epoch");
is($date2->getValue(-1),                     -1,         "... negative epoch to epoch");

#Dates to MySQL
my $date3 = WebGUI::Form::DateTime->new($session, {'defaultValue' => '2008-08-01 16:34:26'});
is($date3->getValue(1217608466),            '2008-08-01 11:34:26', "getValue, defaultValue is mysql, epoch to mySQL");
is($date3->getValue('2008-08-01 11:34:26'), '2008-08-01 16:34:26', "... MySQL to MySQL");#UTC is 5 hours ahead of Chicago
is($date3->getValue(-1),                    '1969-12-31 17:59:59', "... negative epoch to mysql");

#########################################
#
# getValueAsHtml
#
#########################################

my $bday = WebGUI::Test->webguiBirthday;

$date2 = WebGUI::Form::DateTime->new($session);
is($date2->getValueAsHtml(), $session->datetime->epochToHuman($date2->getDefaultValue,'%z %Z'), "getValueAsHtml: no defaultValue set, no value set, returns now in user's format");

$date2 = WebGUI::Form::DateTime->new($session, {defaultValue => 1217608466});
is($date2->getValueAsHtml(), '8/1/2008 11:34 am', "getValueAsHtml: defaultValue in epoch format, returns now in user's format");
is(
    getValueFromForm($session, $date2->toHtmlAsHidden),
    '2008-08-01 11:34:26',
    "toHtmlAsHidden: defaultValue in mysql format, returns date in mysql format"
);
is(
    getValueFromForm($session, $date2->toHtml),
    '2008-08-01 11:34:26',
    "toHtml: defaultValue in mysql format, returns date in mysql format"
);

$date2 = WebGUI::Form::DateTime->new($session, {defaultValue => -1});
is($date2->getValueAsHtml(), '12/31/1969 5:59 pm', "getValueAsHtml: defaultValue as negative epoch, returns as user's format");
is(
    getValueFromForm($session, $date2->toHtmlAsHidden),
    '1969-12-31 17:59:59',
    "toHtmlAsHidden: defaultValue as negative epoch, returns date/time in mysql format"
);
is(
    getValueFromForm($session, $date2->toHtml),
    '1969-12-31 17:59:59',
    "toHtml: defaultValue in mysql format, returns date in mysql format"
);


$date2 = WebGUI::Form::DateTime->new($session, {defaultValue => '2008-08-01 11:34:26'});
is($date2->getValueAsHtml(), '2008-08-01 06:34:26', "getValueAsHtml: defaultValue in mysql format, returns default value in mysql format");
is(
    getValueFromForm($session, $date2->toHtmlAsHidden),
    '2008-08-01 06:34:26',
    "toHtmlAsHidden: defaultValue in mysql format, returns date in mysql format"
);
is(
    getValueFromForm($session, $date2->toHtml),
    '2008-08-01 06:34:26',
    "toHtml: defaultValue in mysql format, returns date in mysql format"
);


$date2 = WebGUI::Form::DateTime->new($session, {defaultValue => '2008-08-01 11:34:26', value => $bday, });
is($date2->getValueAsHtml(), '8/16/2001 8:00 am', "getValueAsHtml: defaultValue in mysql format, value as epoch returns value in user's format");
is(
    getValueFromForm($session, $date2->toHtmlAsHidden),
    '2001-08-16 08:00:00',
    "toHtmlAsHidden: defaultValue in mysql format, value as epoch returns date in mysql format"
);
is(
    getValueFromForm($session, $date2->toHtml),
    '2001-08-16 08:00:00',
    "toHtml: defaultValue in mysql format, value as epoch returns date in mysql format"
);

$date2 = WebGUI::Form::DateTime->new($session, {defaultValue => '2008-08-01 11:34:26', value => '2001-08-16 13:00:00', });
is($date2->getValueAsHtml(), '2001-08-16 08:00:00', "getValueAsHtml: defaultValue in mysql format, value as mysql returns value in mysql format");
is(
    getValueFromForm($session, $date2->toHtmlAsHidden),
    '2001-08-16 08:00:00',
    "toHtmlAsHidden: defaultValue in mysql format, value as mysql returns date in mysql format, adjusted for time zone"
);
is(
    getValueFromForm($session, $date2->toHtml),
    '2001-08-16 08:00:00',
    "toHtml: defaultValue in mysql format, value as mysql returns date in mysql format, adjusted for time zone"
);
$date2 = WebGUI::Form::DateTime->new($session, {defaultValue => '2008-081-01 11:34:26',});
is(
    getValueFromForm($session, $date2->toHtml),
    '1969-12-31 18:00:00',
    "toHtml: defaultValue in bad mysql format, returns value from epoch 0, adjusted for user time zone"
);

sub getValueFromForm {
    my ($session, $textForm) = @_;
    my ($header, $footer)    = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));
    my @forms = HTML::Form->parse($header.$textForm.$footer, 'http://www.webgui.org');
    my @inputs = $forms[0]->inputs;
    return $inputs[1]->{value};
}
