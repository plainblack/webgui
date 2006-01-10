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
use WebGUI::Session;
use WebGUI::SQL;


my $toVersion = "6.8.5"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

# upgrade functions go here

modifyDataFormSecurity();

finish(); # this line required

#-------------------------------------------------
sub modifyDataFormSecurity {
	print "\tAdding Who Can View Form Entries property to DataForm Wobject.\n" unless ($quiet);
	my $sql = "alter table DataForm add column (groupToViewEntries varchar(22) not null default '7')";
	WebGUI::SQL->write($sql);
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

