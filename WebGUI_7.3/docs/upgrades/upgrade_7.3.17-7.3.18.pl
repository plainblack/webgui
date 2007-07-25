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


my $toVersion = "7.3.18"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

fixEmsBadges($session);

finish($session); # this line required


#-------------------------------------------------
sub fixEmsBadges {
	my $session = shift;
	print "\tAttaching EMS Badges to their EMS.\n" unless ($quiet);
    my $db = $session->db;
    # give tables an asset id that should have it
    $db->write("alter table EventManagementSystem_badges add column assetId varchar(22) binary");
    $db->write("alter table EventManagementSystem_prerequisites add column assetId varchar(22) binary");
    $db->write("alter table EventManagementSystem_registrations add column assetId varchar(22) binary");
    my $sth = $db->read("select badgeId,asset.assetId from EventManagementSystem_badges
        left join EventManagementSystem_registrations using (badgeId) left join EventManagementSystem_products using
        (productId) left join asset on (asset.assetId=EventManagementSystem_products.assetId);");
    while (my ($badgeId, $assetId) = $sth->array) {
        $db->write("update EventManagementSystem_badges set assetId=? where badgeId=?", [$assetId, $badgeId]);
        $db->write("update EventManagementSystem_registrations set assetId=? where badgeId=?", [$assetId, $badgeId]);
    }
    my $sth = $db->read("select EventManagementSystem_prerequisites.prerequisiteId,
        EventManagementSystem_products.assetId from EventManagementSystem_prerequisites left join
        EventManagementSystem_prerequisiteEvents using (prerequisiteId) left join EventManagementSystem_products on
        (EventManagementSystem_products.productId=EventManagementSystem_prerequisiteEvents.requiredProductId)");
    while (my ($prereqId, $assetId) = $sth->array) {
        $db->write("update EventManagementSystem_prerequisites set assetId=? where prerequisiteId=?", [$prereqId,
            $assetId]); 
    }

    # delete badge data for which there is no asset
    $db->write("delete from EventManagementSystem_badges where assetId is null");
    $db->write("delete from EventManagementSystem_registrations where assetId is null");
    # delete field data for which there is no asset
    my $sth = $db->read("select EventManagementSystem_metaField.fieldId
        from EventManagementSystem_metaField left join asset on
        (EventManagementSystem_metaField.assetId=asset.assetId) where asset.assetId is null");
    while (my ($fieldId) = $sth->array) {
        $db->write("delete from EventManagementSystem_metaData where fieldId=?",[$fieldId]);
        $db->write("delete from EventManagementSystem_metaField where fieldId=?",[$fieldId]);
    }
    # delete prereqs for which there is no asset
    my $sth = $db->read("select EventManagementSystem_prerequisites.prerequisiteId from
        EventManagementSystem_prerequisites left join asset using (assetId) where asset.assetId is null");
    while (my ($id) = $sth->array) {
        $db->write("delete from EventManagementSystem_prerequisites where prerequisiteId=?",[$id]);
        $db->write("delete from EventManagementSystem_prerequisiteEvents where prerequisiteId=?",[$id]);
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



