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


my $toVersion = "7.1.0"; # make this match what version you're going to
my $quiet; # this line required

my $session = start(); # this line required

recalculateProjectCompletion($session);
updateSqlReportTable($session);
updateProductsTable($session);
makeLdapRecursiveFiltersText($session);
addImageStuffToCs($session);

finish($session); # this line required


#-------------------------------------------------
sub addImageStuffToCs {
	my $session = shift;
	print "\tAdding thumbnail and image sizing to CS.\n" unless $quiet;
	$session->db->write("alter table Collaboration add column thumbnailSize int not null default 0");
	$session->db->write("alter table Collaboration add column maxImageSize int not null default 0");
}


#-------------------------------------------------
sub recalculateProjectCompletion {
	my $session = shift;
	print "\tForcing project completion recalculation.\n" unless $quiet;
	my @assetIds = $session->db->buildArray("SELECT DISTINCT assetId FROM PM_wobject", []);
	foreach my $assetId (@assetIds) {
		my $pm = WebGUI::Asset->newByDynamicClass($session, $assetId);
		my @projectIds = $session->db->buildArray("SELECT projectId FROM PM_project WHERE assetId = ?", [$assetId]);
		foreach my $project (@projectIds) {
			$pm->updateProject($project);
		}
	}
}


sub updateSqlReportTable {
	my $session = shift;
	print "\tUpdating SQLReport table structure.\n" unless ($quiet);
	$session->db->write("alter table `SQLReport` ADD COLUMN ( downloadType varchar(255), downloadFilename varchar(255), downloadTemplateId varchar(22), downloadMimeType varchar(255), downloadUserGroup varchar(22))");
}


sub updateProductsTable {
	my $session	= shift;
	print "\tUpdating products table structure.\n" unless ($quiet);
	$session->db->write("alter table products add column (groupId varchar(22), groupExpiresOffset varchar(16))");
}

sub makeLdapRecursiveFiltersText {
	my $session = shift;
	print "\tMaking LDAP recursive filters text fields.\n" unless $quiet;
	$session->db->write($_) for(<<'EOT',
    ALTER TABLE LDAPLink
  CHANGE COLUMN ldapGlobalRecursiveFilter ldapGlobalRecursiveFilter mediumtext NULL DEFAULT NULL
EOT
				    <<'EOT',
    ALTER TABLE groups
  CHANGE COLUMN ldapRecursiveFilter ldapRecursiveFilter mediumtext NULL DEFAULT NULL
EOT
				   )
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



