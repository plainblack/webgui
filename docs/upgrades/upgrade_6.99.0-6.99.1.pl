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

finish($session); # this line required


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

