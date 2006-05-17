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


my $toVersion = "6.99.1"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

fixTypos($session);
updateTemplates();
csFixes();

finish($session); # this line required

#-------------------------------------------------
sub csFixes {
        print "\tFixing CS stuff.\n" unless ($quiet);
	$session->db->write("alter table Collaboration add column autoSubscribeToThread int not null default 1");
        $session->db->write("alter table Collaboration add column requireSubscriptionForEmailPosting int not null default 1");
}

#-------------------------------------------------
sub updateTemplates {
        print "\tFixing template problems\n" unless ($quiet);
	opendir(DIR,"templates-6.99.1");
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $folder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => "7.0.0 New Templates",
		menuTitle => "7.0.0 New Templates",
		url=> "7_0_0_new_templates",
		groupIdView=>"12"
		});
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-6.99.1/".$file);
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
			my $template = $folder->addChild(\%properties, $properties{id});
		} else {
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub fixTypos {
	my $session = shift;
	print "\tFixing typos.\n" unless ($quiet);
	my $activities = $session->config->get("workflowActivities");
	my $versionTag = $activities->{"WebGUI::VersionTag"};
	my @newStuff = ("WebGUI::Workflow::Activity::ExportVersionTagToHtml");
	foreach my $value (@{$versionTag}) {
		push(@newStuff, $value);
	}
	$activities->{"WebGUI::VersionTag"} = \@newStuff;
	$session->config->set("workflowActivities",$activities);
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
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

