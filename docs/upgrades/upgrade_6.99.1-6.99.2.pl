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


my $toVersion = "6.99.2"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
updateTT();

finish($session); # this line required


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
	updateTemplates($session);
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

#-------------------------------------------------
sub updateTemplates {
	my $session = shift;
	return undef unless (-d "templates-".$toVersion);
        print "\tUpdating templates.\n" unless ($quiet);
	opendir(DIR,"templates-".$toVersion);
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $newFolder = undef;
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-".$toVersion."/".$file);
		my $first = 1;
		my $create = 0;
		my $head = 0;
		my %properties = (className=>"WebGUI::Asset::Template");
		while (my $line = <FILE>) {
			if ($first) {
				$line =~ m/^\#(.*)$/;
				$properties{id} = $1;
				$first = 0;
			} elsif ($line =~ m/^\#create$/) {
				$create = 1;
			} elsif ($line =~ m/^\#(.*):(.*)$/) {
				$properties{$1} = $2;
			} elsif ($line =~ m/^~~~$/) {
				$head = 1;
			} elsif ($head) {
				$properties{headBlock} .= $line;
			} else {
				$properties{template} .= $line;	
			}
		}
		close(FILE);
		if ($create) {
			$newFolder = createNewTemplatesFolder($importNode) unless (defined $newFolder);
			my $template = $newFolder->addChild(\%properties, $properties{id});
		} else {
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub createNewTemplatesFolder {
	my $importNode = shift;
	my $newFolder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => $toVersion." New Templates",
		menuTitle => $toVersion." New Templates",
		url=> $toVersion."_new_templates",
		groupIdView=>"12"
		});
	return $newFolder;
}


