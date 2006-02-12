#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::SQL;


my $toVersion = "6.8.6"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

# upgrade functions go here

reorderDataFormCollateral();
finish(); # this line required

#-------------------------------------------------
sub reorderDataFormCollateral {
	print "\tFixing DataForm collateral order.\n" unless ($quiet);
	my @dataForms = WebGUI::SQL->buildArray('select assetId from asset where className="WebGUI::Asset::Wobject::DataForm"');
	foreach my $dfId (@dataForms) {
		my $asset = WebGUI::Asset->new($dfId,"WebGUI::Asset::Wobject::DataForm");
		my @tabs = WebGUI::SQL->buildArray("select DataForm_tabId from DataForm_tab where assetId=".quote($dfId)." order by sequenceNumber");
		foreach my $tab (@tabs) {
			$asset->reorderCollateral("DataForm_field","DataForm_fieldId", "DataForm_tabId",$tab);
		}
	}
}

# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	WebGUI::Session::open("../..",$configFile);
	WebGUI::Session::refreshUserInfo(3);
	WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

