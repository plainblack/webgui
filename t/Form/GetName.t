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
use WebGUI::Form::FieldType;
use WebGUI::Form::DynamicField;
use WebGUI::Session;
use Data::Dumper;

#The goal of this test is to verify that getName works with all Form types.
#getName is now inherited by all Forms and pulls the internationalized ID
#from sub definition.
#It would be nice to have a way to automatically verify that each Form has
#the correct name, but it would have to be table driven.

use Test::More; # increment this value for each test you create

my $numTests = 0;

my $session = WebGUI::Test->session;

# put your tests here

my @formTypes = sort keys %{ WebGUI::Form::FieldType->new($session)->getTypes() };

##We have to remove DynamicField from this list, since when you call new
##it wants to return a type.  We'll check it manually.

$numTests = (2 * scalar @formTypes) + 1;

plan tests => $numTests;


foreach my $formType (@formTypes) {
	my $form = WebGUI::Form::DynamicField->new($session, fieldType => $formType);
	my $ref = (split /::/, ref $form)[-1];
	is($ref, $formType, "checking form type $formType");
	ok($form->getName($session), sprintf "form getName = %s", $form->getName($session));
}

my $name = WebGUI::Form::DynamicField->getName($session);

ok($name, 'did not inherit default form name');
