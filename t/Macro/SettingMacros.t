#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Macro_Config;

my $session = WebGUI::Test->session;

#This test is to verify bugs with respect to Macros:
# - [ 1364838 ] ^GroupText Macro cannot execute other macros
#
# It also checks some macros which pull data out of the setting table.

my @settingMacros = (
	{
		settingKey => 'companyEmail',
		macro => 'e_companyEmail'
	},
	{
		settingKey => 'companyName',
		macro => 'c_companyName'
	},
	{
		settingKey => 'companyURL',
		macro => 'u_companyUrl'
	},
);

use Test::More; # increment this value for each test you create

##Build a reverse hash of the macro settings in the session var so that
##we can lookup the aliases for each macro.

my %macroNames = reverse %{ $session->config->get('macros') };

my $settingMacros = 0;

foreach my $macro ( @settingMacros ) {
	++$settingMacros;
	if (exists $macroNames{ $macro->{macro} }) {
		$macro->{shortcut} = $macroNames{ $macro->{macro} };
	}
	else {
		Macro_Config::insert_macro($session, $macro->{macro}, $macro->{macro});
		$macro->{shortcut} = $macro->{macro};
	}
}

my $numTests = $settingMacros;

plan tests => $numTests;

foreach my $macro ( @settingMacros ) {
	my ($value) = $session->dbSlave->quickArray(
		sprintf "select value from settings where name=%s",
			$session->db->quote($macro->{settingKey})
	);
	my $macroVal = sprintf "^%s();", $macro->{shortcut};
	WebGUI::Macro::process($session, \$macroVal);
	is($value, $macroVal, sprintf "Testing %s", $macro->{macro});
}
