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
use warnings;
use lib "$FindBin::Bin/../lib"; ##t/lib

use WebGUI::Test;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Macro;

#The goal of this test is to verify all the i18n labels in
#the Admin Console functions

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;

# put your tests here

my %consoleFuncs = %{ $session->config->get("adminConsole") };


$numTests = scalar keys %consoleFuncs;

plan tests => $numTests;

my $i18n = WebGUI::International->new($session);

my ($label, $func);
foreach my $key (keys %consoleFuncs ) {
	my $label = $consoleFuncs{$key}{title};
	WebGUI::Macro::process($session, \$label);
	isnt($label,'', "admin console func $key: ".$consoleFuncs{$key}{title});
}


