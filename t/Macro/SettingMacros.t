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

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

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

##Build a reversed hash so we know how to call the macros based on
##their name
my @added_macros = ();
foreach my $macro ( @settingMacros ) {
	$macro->{shortcut} = $macro->{macro};
	push @added_macros,
		WebGUI::Macro_Config::enable_macro($session, $macro->{shortcut}, $macro->{macro});
}

plan tests => scalar @settingMacros;

foreach my $macro ( @settingMacros ) {
	my ($value) = $session->dbSlave->quickArray(
		"select value from settings where name=?", [$macro->{settingKey}]);
	my $macroVal = sprintf "^%s();", $macro->{shortcut};
	WebGUI::Macro::process($session, \$macroVal);
	is($value, $macroVal, sprintf "Testing %s", $macro->{macro});
}

END {
	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}
