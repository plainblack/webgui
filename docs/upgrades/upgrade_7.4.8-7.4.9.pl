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
use WebGUI::ProfileField;

my $toVersion = "7.4.9"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

removeOrphanedGroupings($session); # upgrade functions go here
fixDashboardContentPositions($session);
fixPosts($session);

finish($session); # this line required



#-------------------------------------------------
sub removeOrphanedGroupings {
	my $session = shift;
	print "\tCleaning up stale groupings.\n" unless ($quiet);
	$session->db->write("delete from groupGroupings where inGroup not in (select distinct groupId from groups)");
	$session->db->write("delete from groupings where groupId not in (select distinct groupId from groups)");
}


#-------------------------------------------------
sub fixPosts {
	my $session = shift;
    my $db = $session->db;
	print "\tRemoving unneeded fields from Posts.\n" unless ($quiet);
    $db->write("alter table Post drop column dateSubmitted");
    $db->write("alter table Post drop column dateUpdated");
    $db->write("update Collaboration set sortBy='assetData.revisionDate' where sortBy='dateUpdated'");
    $db->write("update Collaboration set sortBy='creationDate' where sortBy='dateSubmitted'");
}

#-------------------------------------------------
sub fixDashboardContentPositions {
	my $session = shift;
    my $db = $session->db;
	print "\tFixing broken dashboard content positions.\n" unless ($quiet);
    foreach my $dashboardId ($db->quickArray("select assetId from asset where className='WebGUI::Asset::Wobject::Dashboard'")) {
        my $newContentPositionId = "contentPositions".$dashboardId;
        $newContentPositionId =~ s/-/_/g;
        my $newField = WebGUI::ProfileField->create($session, $newContentPositionId, {
		    label=>'\'Dashboard User Preference - Content Positions\'',
		    visible=>0,
		    protected=>1,
		    editable=>0,
		    required=>0,
		    fieldType=>'textarea'
            });
        my $oldContentPositionId = $dashboardId."contentPositions";
        my $userPositioning = $db->read("select userId, " . $db->dbh->quote_identifier($oldContentPositionId) . " from userProfileData");
        while (my ($userId, $positions) = $userPositioning->array) {
            $db->write("update userProfileData set $newContentPositionId = ? where userId=?", [$positions, $userId]); 
        }
        my $oldField = WebGUI::ProfileField->new($session, $oldContentPositionId);
        if (defined $oldField) {
            $oldField->delete;
        }
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



