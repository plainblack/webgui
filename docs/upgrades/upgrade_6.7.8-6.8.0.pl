use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.8.0";
my $configFile;
my $quiet;

start();
addTimeZonesToUserPreferences();
finish();

#-------------------------------------------------
sub addTimeZonesToUserPreferences {
	WebGUI::SQL->write("delete from userProfileData where fieldName='timeOffset'");
	WebGUI::SQL->write("update userProfileField set dataValues='', fieldName='timeZone', dataType='timeZone', dataDefault=".quote("['America/Chicago']")." where fieldName='timeOffset'");
}

#--- DO NOT EDIT BELOW THIS LINE

#-------------------------------------------------
sub start {
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

