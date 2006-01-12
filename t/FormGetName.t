#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Form::FieldType;
use WebGUI::Form::DynamicField;
# ---- END DO NOT EDIT ----

#The goal of this test is to verify that getName works with all Form types.
#getName is now inherited by all Forms and pulls the internationalized ID
#from sub definition.
#It would be nice to have a way to automatically verify that each Form has
#the correct name, but it would have to be table driven.

use Test::More; # increment this value for each test you create

my $numTests = 0;

my $session = initialize();  # this line is required

# put your tests here

diag("Getting the list of all Form types\n");

my $fieldType = WebGUI::Form::FieldType->new();

my @formTypes = @{ $fieldType->{types} };

##We have to remove DynamicField from this list, since when you call new
##it wants to return a type.  We'll check it manually.

$numTests = (2 * scalar @formTypes) + 1;

plan tests => $numTests;

diag("Planning on running $numTests tests\n");

foreach my $formType (sort @formTypes) {
	my $form = WebGUI::Form::DynamicField->new(fieldType => $formType);
	my $ref = (split /::/, ref $form)[-1];
	is($ref, $formType, "checking form type $formType");
	ok($form->getName, sprintf "form getName = %s", $form->getName);
}

my $name = WebGUI::Form::DynamicField->getName();

ok($name, 'did not inherit default form name');

cleanup($session); # this line is required

# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

