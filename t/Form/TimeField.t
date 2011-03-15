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
use WebGUI::Form::TimeField;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Text form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
   {
       key => 'Time1',
       testValue => '00:00:10',
       expected  => '10',
       comment   => 'Send it mysql format data, seconds',
   },
   {
       key => 'Time2',
       testValue => '00:10:00',
       expected  => '600',
       comment   => 'Send it mysql format data, minutes',
   },
   {
       key => 'Time3',
       testValue => '10',
       expected  => '10',
       comment   => 'Send it seconds format data',
   },
];

my $formType = 'text'; ##timeField is a text subclass

my $numTests = 40 + scalar @{ $testBlock };

plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	WebGUI::Form::TimeField->new($session, {
		name => 'TestTime',
		value => '00:00:10',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 3, 'The form has 3 inputs.  Field and CSRF');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestTime',  'Checking input name');
is($input->type, $formType,   'Checking input type');
is($input->value, '00:00:10', 'Checking default value');

WebGUI::Form_Checking::auto_check($session, 'TimeField', $testBlock);

# test that we can process non-POST values correctly
my $cntl;
$cntl = WebGUI::Form::TimeField->new($session,{ });
is($cntl->getValue('10'),         '10', 'no default, not mysql mode, all digits');
is($cntl->getValue('00:00:10'),   '10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),     '600', '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'),  '600', '... mysql formatted data, 3 pairs');
is($cntl->getValue('innocent'),  undef, '... wrong data');

$cntl = WebGUI::Form::TimeField->new($session,{ format => 'mysql' });
is($cntl->getValue('10'),        '00:00:10', 'no default, mysql mode, all digits');
is($cntl->getValue('00:00:10'),  '00:00:10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),     '00:10',    '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'),  '00:10:00', '... mysql formatted data, 3 pairs');
is($cntl->getValue('innocent'),  undef,      '... wrong data');

$cntl = WebGUI::Form::TimeField->new($session,{ defaultValue => 0, });
is($cntl->getValue('10'),         '10', '0 default, not mysql mode, all digits');
is($cntl->getValue('00:00:10'),   '10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),     '600', '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'),  '600', '... mysql formatted data, 3 pairs');

$cntl = WebGUI::Form::TimeField->new($session,{ defaultValue => 1, });
is($cntl->getValue('10'),         '10', '1 default, not mysql mode, all digits');
is($cntl->getValue('00:00:10'),   '10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),     '600', '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'),  '600', '... mysql formatted data, 3 pairs');

$cntl = WebGUI::Form::TimeField->new($session,{ defaultValue => '55:55:55', });
is($cntl->getValue('10'),       '00:00:10', 'mysql defaultValue, all digits');
is($cntl->getValue('00:00:10'), '00:00:10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),    '00:10',    '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'), '00:10:00', '... mysql formatted data, 3 pairs');

$cntl = WebGUI::Form::TimeField->new($session,{ defaultValue => 0, format => 'mysql', });
is($cntl->getValue('10'),       '00:00:10', '0 default, mysql mode, all digits');
is($cntl->getValue('00:00:10'), '00:00:10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),    '00:10',    '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'), '00:10:00', '... mysql formatted data, 3 pairs');
is($cntl->getValue('high noon'),     undef, '... mysql formatted data, bad data');

$cntl = WebGUI::Form::TimeField->new($session,{ defaultValue => 1, format => 'mysql', });
is($cntl->getValue('10'),       '00:00:10', '1 default, mysql mode, all digits');
is($cntl->getValue('00:00:10'), '00:00:10', '... mysql formatted data, 3 pairs');
is($cntl->getValue('00:10'),    '00:10',    '... mysql formatted data, 2 pairs');
is($cntl->getValue('00:10:00'), '00:10:00', '... mysql formatted data, 3 pairs');

$cntl->set('value', 10);
is($cntl->getValueAsHtml('10'),         '00:00:10', 'getValueAsHtml, all digits');
$cntl->set('value', '00:10');
is($cntl->getValueAsHtml('00:10'),      '00:10',    '... minutes');
$cntl->set('value', '00:10:00');
is($cntl->getValueAsHtml('00:10:00'),   '00:10:00', 'minutes, with empty seconds');
