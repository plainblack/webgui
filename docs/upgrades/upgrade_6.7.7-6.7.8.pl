use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.8";
my $configFile;
my $quiet;

start();
protectUserProfileFields();
finish();

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
sub protectUserProfileFields {
	WebGUI::SQL->write("update userProfileField set protected=1 where fieldName in ('discussionLayout','INBOXNotifications','alias','signature','publicProfile','publicEmail','toolbar')");
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

