#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::Search;
use WebGUI::Search::Index;
use Time::HiRes;

$|=1;
my $search = "";
my $help = 0;
my $indexsite = 0;
my $configFile = "";

GetOptions(
	'configFile=s'=>\$configFile,
	'search=s'=>\$search,
	'help'=>\$help,
	'indexsite'=>\$indexsite
	);

if ($configFile) {
	my $session = WebGUI::Session->open("..", $configFile);
	if ($indexsite) {
		reindexSite($session);
	} elsif ($search) {
		searchSite($session, $search);
	} else {
		displayHelp();
	}
	$session->var->end;
	$session->close;
} else {
	displayHelp();
}

#-------------------------------------------------------------------
sub displayHelp {
	print <<STOP;
perl $0 [ options ]

Options:

	--configFile=		The config file of the site you wish to perform
				an action on.

	--help			Displays this message.

	--indexsite *		Reindexes the entire site. Note that depending
				upon the amount of content you have, it may take
				hours to index a site and server performance will
				suffer somewhat during the indexing process.

	--search= *		Searches the site for a keyword or phrase and
				returns the results.

	* This option requires the --configFile option.

STOP
}


#-------------------------------------------------------------------
sub reindexSite {
	my $session = shift;
	my $siteTime = [Time::HiRes::gettimeofday()];
	my $rs = $session->db->read("select assetId, className from asset where state='published'");	
	while (my ($id, $class) = $rs->array) {
		my $asset = WebGUI::Asset->new($session,$id,$class);
		if (defined $asset && $asset->get("status") eq "approved" || $asset->get("status") eq "archived") {
			print $asset->getId."\t".$asset->getTitle."\t";
			my $t = [Time::HiRes::gettimeofday()];
			$asset->indexContent;
			print "(".Time::HiRes::tv_interval($t).")\n";
		}
	}

	print "\nSite indexing took ".Time::HiRes::tv_interval($siteTime)." seconds.\n";
}

#-------------------------------------------------------------------
sub searchSite {
	my $session = shift;
	my $keywords = shift;
	my $t = [Time::HiRes::gettimeofday()];
	my $search = WebGUI::Search->new($session, 0);
	$search->search("any",$keywords);
	my $rs = $search->getResultSet;	
	while (my $data = $rs->hashRef) {
		print $data->{assetId}."\t".$data->{title}."\n"; 
	}
	print "\nSearch took ".Time::HiRes::tv_interval($t)." seconds.\n";
}


