use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.5";
my $configFile;
my $quiet;

start();

fixSurveyAnswerDefinition();

finish();


#-------------------------------------------------
sub fixSurveyAnswerDefinition {
        print "\tFixing definition of survey answers.\n" unless ($quiet);
	WebGUI::SQL->write("alter table Survey_answer change gotoQuestion gotoQuestion varchar(22) binary");
}




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

