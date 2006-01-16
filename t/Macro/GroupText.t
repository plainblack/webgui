#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use Data::Dumper;
# ---- END DO NOT EDIT ----

my $session = initialize();  # this line is required

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

##Build a reverse hash of the macro settings in the session var so that
##we can lookup the aliases for each macro.

my %macroNames = reverse %{ $session->config->get('macros') };

my $settingMacros = 0;

foreach my $macro ( @settingMacros ) {
	++$settingMacros;
	if (exists $macroNames{ $macro->{macro} }) {
		$macro->{shortcut} = $macroNames{ $macro->{macro} };
		$macro->{skip} = 0;
	}
	else {
		$macro->{skip} = 1;
	}
}

use Test::More; # increment this value for each test you create

my $numTests = 6 + $settingMacros;

plan tests => $numTests;

diag("Planning on running $numTests tests\n");

my $macroText = "^GroupText(3,local,foreigner);";
my $AdminText = "^AdminText(admin);";
my $output;

$output = $macroText;
WebGUI::Macro::process($session, \$output);
is($output, 'foreigner', 'GroupText, user not in group');

$output = $adminText;
WebGUI::Macro::process($session, \$output);
is($output, '', 'AdminText, user not in group');

$output = $macroText;
$session->user({userId => 3});
WebGUI::Macro::process($session, \$output);
is($output, 'local', 'GroupText, user in group');

$output = $adminText;
WebGUI::Macro::process($session, \$output);
is($output, 'admin', 'AdminText, user is admin');

my $apText = "^AssetProxy(getting_started);";
WebGUI::Macro::process($session, \$apText);
my $apPass = like($output, qr/If you're reading this/, 'AssetProxy functional check');

SKIP: {
	skip("AssetProxy isn't working",1) unless $apPass;
	$macroText = "^GroupText(3,^AssetProxy(getting_started);,foreigner)";
	$output = $macroText;
	WebGUI::Macro::process($session, \$output);
	like($output, qr/If you're reading this/, 'GroupText, nesting, in group');
}


diag("Begin setting macro tests");

foreach my $macro ( @settingMacros ) {
	SKIP: {
		skip("Unable to lookup macro: $macro->{macro}",1) if $macro->{skip};
		my ($value) = $session->dbSlave->quickArray(
			sprintf "select value from settings where name=%s",
				$session->db->quote($macro->{settingKey})
		);
		my $macroVal = sprintf "^%s();", $macro->{shortcut};
		WebGUI::Macro::process($session, \$macroVal);
		is($value, $macroVal, sprintf "Testing %s", $macro->{macro});
	}
}

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

