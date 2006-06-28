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
use WebGUI::Config;
use WebGUI::Session;
use WebGUI::Search;
use WebGUI::Search::Index;
use Time::HiRes;

$|=1;
my $search = "";
my $help = 0;
my $indexsite = 0;
my $configFile = "";
my $indexAll = "";
my $updatesite = 0;

GetOptions(
	'indexall'=>\$indexAll,
	'configFile=s'=>\$configFile,
	'search=s'=>\$search,
	'help'=>\$help,
	'indexsite'=>\$indexsite,
	'updatesite'=>\$updatesite
	);

if ($configFile) {
	my $session = WebGUI::Session->open("..", $configFile);
	if ($indexsite) {
		reindexSite($session);
	} elsif ($updatesite) {
		updateSite($session);
	} elsif ($search) {
		searchSite($session, $search);
	} else {
		displayHelp();
	}
	$session->var->end;
	$session->close;
} elsif ($indexAll) {
	reindexAllSites();
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

	--indexall		Reindexes all the sites. Note that this can take
				many hours and will affect the performance of the
				server during the indexing process.

	--indexsite *		Reindexes the entire site. Note that depending
				upon the amount of content you have, it may take
				hours to index a site and server performance will
				suffer somewhat during the indexing process.

	--search= *		Searches the site for a keyword or phrase and
				returns the results.

	--updatesite *		Indexes content that has not be indexed, but does not
				index content that has been indexed. This is useful
				if the --indexsite option had to be stopped part way
				through.

	* This option requires the --configFile option.

STOP
}


#-------------------------------------------------------------------
sub reindexAllSites {
	my $configs = WebGUI::Config->readAllConfigs("..");
	foreach my $site (keys %{$configs}) {
		print "Indexing ".$site."...\n";
		my $session = WebGUI::Session->open("..",$site);
		reindexSite($session);
		$session->var->end;
		$session->close;
		print "Finished indexing ".$site.".\n";
	}
}


#-------------------------------------------------------------------
sub reindexSite {
	my $session = shift;
	my $siteTime = [Time::HiRes::gettimeofday()];
	my $rs = $session->db->read("select assetId, className from asset where state='published'");
	my @searchableAssetIds;	
	while (my ($id, $class) = $rs->array) {
		my $asset = WebGUI::Asset->new($session,$id,$class);
		if (defined $asset && $asset->get("state") eq "published" && ($asset->get("status") eq "approved" || $asset->get("status") eq "archived")) {
			print $asset->getId."\t".$asset->getTitle."\t";
			my $t = [Time::HiRes::gettimeofday()];
			$asset->indexContent;
			print "(".Time::HiRes::tv_interval($t).")\n";
			push (@searchableAssetIds, $id);
		}
	}
	
	# delete indexes of assets that are no longer searchable
	my $list = $session->db->quoteAndJoin(\@searchableAssetIds) if scalar(@searchableAssetIds);
	$session->db->write("delete from assetIndex where assetId not in (".$list.")") if $list;
	print "\nSite indexing took ".Time::HiRes::tv_interval($siteTime)." seconds.\n";
}

#-------------------------------------------------------------------
sub searchSite {
	my $session = shift;
	my $keywords = shift;
	my $t = [Time::HiRes::gettimeofday()];
	my $search = WebGUI::Search->new($session, 0);
	$search->search({keywords=>$keywords});
	my $rs = $search->getResultSet;	
	while (my $data = $rs->hashRef) {
		print $data->{assetId}."\t".$data->{title}."\n"; 
	}
	print "\nSearch took ".Time::HiRes::tv_interval($t)." seconds.\n";
}

#-------------------------------------------------------------------
sub updateSite {
	my $session = shift;
	my $siteTime = [Time::HiRes::gettimeofday()];
	my $rs = $session->db->read("select assetId, className from asset where state='published'");
	my @searchableAssetIds;	
	while (my ($id, $class) = $rs->array) {
		my ($done) = $session->db->quickArray("select count(*) from assetIndex where assetId=?",[$id]);
		next if $done;
		my $asset = WebGUI::Asset->new($session,$id,$class);
		if (defined $asset && $asset->get("status") eq "approved" || defined $asset && $asset->get("status") eq "archived") {
			print $asset->getId."\t".$asset->getTitle."\t";
			my $t = [Time::HiRes::gettimeofday()];
			$asset->indexContent;
			print "(".Time::HiRes::tv_interval($t).")\n";
			push(@searchableAssetIds, $id);
		}
	}
	
	# delete indexes of assets that are no longer searchable
	my $list = $session->db->quoteAndJoin(\@searchableAssetIds) if scalar(@searchableAssetIds);
	$session->db->write("delete from assetIndex where assetId not in (".$list.")") if $list;
	print "\nSite indexing took ".Time::HiRes::tv_interval($siteTime)." seconds.\n";
}

