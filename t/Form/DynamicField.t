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
use WebGUI::Form::FieldType;
use WebGUI::Session;

#The goal of this test is to verify that Email form elements work.
#The Email form accepts and validates an email address.

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $formClass = 'WebGUI::Form::DynamicField';

my $numTests = 1;

plan tests => $numTests;

my $form = WebGUI::Form::DynamicField->new($session,
    fieldType => 'FormTest',
);

note "Test loading a Form from a location outside of /data/WebGUI/lib/WebGUI";
isa_ok($form, 'WebGUI::Form::FormTest');
