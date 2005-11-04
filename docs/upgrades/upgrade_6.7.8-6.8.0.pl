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
# MUST DO: any dates in WebGUI greater than epoch 2^32 must be reduced, because
# the new DateTime system uses Params::Validate, which will only validate integers
# up to 2^32 as SCALARs. :(
removeUnneededFiles();
finish();

#-------------------------------------------------
sub addTimeZonesToUserPreferences {
	print "\tDropping time offsets in favor of time zones.\n" unless ($quiet);
	WebGUI::SQL->write("delete from userProfileData where fieldName='timeOffset'");
	WebGUI::SQL->write("update userProfileField set dataValues='', fieldName='timeZone', dataType='timeZone', dataDefault=".quote("['America/Chicago']")." where fieldName='timeOffset'");
	WebGUI::SQL->write("insert into userProfileData values ('1','timeZone','America/Chicago')");
}

sub removeUnneededFiles {
	print "\tRemoving files that are no longer needed.\n" unless ($quiet);
	unlink("../../www/env.pl");
	unlink("../../www/index.fpl");
	unlink("../../www/index.pl");
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

