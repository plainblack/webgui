#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Form::DateTime;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Text form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $formType = 'datetime';

my $numTests = 14;

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
is(scalar @inputs, 1, 'The form has 1 input');
#Basic tests
my $input = $inputs[0];

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
$input = $inputs[0];
is($input->name, 'preDateValue', 'Checking input name');
#is($input->value, 1217608466, 'Checking default value');
is($input->{size}, 19, 'Checking size param, set');
is($input->{maxlength}, 19, 'Checking maxlength param, set');

##Test Form Output parsing
#Dates to Epoch
#WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

my $date1 = WebGUI::Form::DateTime->new($session, {'defaultValue' => time()});
$session->user->profileField( 'timeZone' , 'American/Chicago');
is($date1->getValue(1217608466), 1217608466, "Epoch to Epch");
is($date1->getValue('2008-08-01 16:34:26'), $session->datetime->setToEpoch("2008-08-01 16:34:26"), "MySQL to Epoch");

#Dates to MySQL
my $date2 = WebGUI::Form::DateTime->new($session, {'defaultValue' => '2008-08-01 16:34:26'});
is($date2->getValue(1217608466), '2008-08-01 11:34:26', "Epoch to MySQL");
is($date2->getValue('2008-08-01 11:34:26'), '2008-08-01 11:34:26', "MySQL to MySQL");

__END__

