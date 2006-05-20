#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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


my $toVersion = "0.0.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
updateTT();

finish($session); # this line required


##-------------------------------------------------
#sub exampleFunction {
#	my $session = shift;
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
	my $session = WebGUI::Session->open("../..",$configFile);
	$session->user({userId=>3});
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Upgrade to ".$toVersion});
	$session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
	return $session;
}

#-------------------------------------------------
sub updateTT {
   my $tableList = [
            "create table TT_projectTasks (
                taskId varchar(22) binary not null,
                projectId varchar(22) binary not null,
                taskName varchar(255) not null,
                primary key (taskId)
            )",
			"alter table TT_timeEntry modify taskId varchar(22) binary not null",
			"alter table TT_projectList drop column taskList",
			"create table TT_report (
			   reportId varchar(22) binary not null,
			   assetId varchar(22) not null,
			   startDate varchar(10) not null,
			   endDate varchar(10) not null,
			   reportComplete integer not null default 0,
			   resourceId varchar(22) binary not null,
			   creationDate bigint not null,
			   createdBy varchar(22) binary not null,
			   lastUpdatedBy varchar(22) binary not null,
			   lastUpdateDate bigint not null
			)",
			"alter table TT_timeEntry add reportId varchar(22) binary not null",
			"alter table TT_timeEntry modify taskDate varchar(10) not null",
			"alter table TT_timeEntry drop column assetId",
			"alter table TT_timeEntry drop column resourceId",
			"alter table TT_timeEntry drop column completed",
			"alter table TT_timeEntry drop column creationDate",
			"alter table TT_timeEntry drop column createdBy",
			"alter table TT_timeEntry drop column lastUpdatedBy",
			"alter table TT_timeEntry drop column lastUpdateDate"
          ];

   print "\tUpdating the Time Tracking System.\n" unless ($quiet);
   foreach (@{$tableList}) {
      $session->db->write($_);
   }

}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

