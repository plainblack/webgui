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


my $toVersion = "7.1.3"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

insertAutomaticLDAPRegistrationSetting($session);
changeGraphConfigColumnType($session);
addIndicies($session);
finish($session); # this line required


#-------------------------------------------------
sub addIndicies {
	my $session = shift;
	print "\tAdding database table indicies to improve performance.\n" unless ($quiet);
	my $db = $session->db;
	$db->write("alter table template add index namespace_showInForms (namespace, showInForms)");	
	$db->write("alter table groups add index groupName (groupName)");	
	$db->write("alter table Product_feature add index assetId (assetId)");	
	$db->write("alter table Product_benefit add index assetId (assetId)");	
	$db->write("alter table Product_specification add index assetId (assetId)");	
	$db->write("alter table DataForm_field add index assetId_tabId (assetId,DataForm_tabId)");	
	$db->write("alter table Post add index threadId_rating (threadId, rating)");	
}

#-------------------------------------------------
sub insertAutomaticLDAPRegistrationSetting {
	my $session = shift;
	print "\tAdding Automatic LDAP Registration setting to database.\n" unless ($quiet);

	my ($hasSetting) = $session->db->quickArray('select name from settings where value=?', ['automaticLDAPRegistration']);

	unless ($hasSetting) {
		$session->db->write('insert into settings (name, value) values (?,?)', ['automaticLDAPRegistration', 0]);
	}
}

#-------------------------------------------------
sub changeGraphConfigColumnType {
	my $session = shift;
	print "\tFixing the the charts in the Poll asset (PLEASE SEE NOTES IN docs/gotcha.txt).\n" unless ($quiet);

	$session->db->write('alter table Poll change column graphConfiguration graphConfiguration blob');
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



