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
use WebGUI::User;
use WebGUI::Session;
use WebGUI::SQL;


my $toVersion = "6.8.8"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

# upgrade functions go here

setAdminFirstDayOfWeek();

finish(); # this line required


#-------------------------------------------------
sub setAdminFirstDayOfWeek {
	print "\tSet the first day of the week profile field for Admin.\n" unless ($quiet);
	my $admin = WebGUI::User->new('3');
	$admin->profileField('firstDayOfWeek',0);
}

##-------------------------------------------------
#sub exampleFunction {
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}



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

