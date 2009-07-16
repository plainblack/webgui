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
		testValue  => "2008-08-01 16:34:26",
		expected   => $session->datetime->setToEpoch("2008-08-01 16:34:26"),#must call this so that value is appropriate for testers timezone
		comment    => 'MySQL formatted to epoch',
	},
];

my $formType = 'date';

my $numTests = 16 + scalar @{ $testBlock } ;


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
TODO: {
    local $TODO = "Figure out why this is returning a MySQL value instead of an epoch.";
    is($input->value, $defaultTime, "Checking default value");
}
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
TODO: {
    local $TODO = "Figure out why this is returning a MySQL value instead of an epoch.";
    is($input->value, 1217608466, 'Checking default value');
}
is($input->{size}, 10, 'Checking size param, set');
is($input->{maxlength}, 10, 'Checking maxlength param, set');

##Test Form Output parsing
#Dates to Epoch
WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);


#Dates to MySQL
my $date2 = WebGUI::Form::Date->new($session, {'defaultValue' => '2008-08-01 16:34:26'});
is($date2->getValue(1217608466), '2008-08-01 11:34:26', "Epoch to MySQL");
is($date2->getValue('2008-08-01 11:34:26'), '2008-08-01 11:34:26', "MySQL to MySQL");

my $date2 = WebGUI::Form::Date->new($session);
is($date2->getValue(1217608466), 1217608466, "Default Epoch to Epoch");
is($date2->getValue('2008-08-01 11:34:26'), 1217608466, "Default MySQL to Epoch");

__END__

