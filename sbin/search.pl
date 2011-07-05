#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict;

use Getopt::Long;
use WebGUI::Paths -inc;
use WebGUI::Asset;
use WebGUI::Config;
use WebGUI::Session;
use WebGUI::Search;
use WebGUI::Search::Index;
use Time::HiRes;
use Pod::Usage;

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

pod2usage( verbose => 2 ) if $help;

if ($configFile) {
	my $session = WebGUI::Session->open($configFile);
	if ($indexsite) {
		reindexSite($session);
	} elsif ($updatesite) {
		updateSite($session);
	} elsif ($search) {
		searchSite($session, $search);
	} else {
		pod2usage();
	}
	$session->var->end;
	$session->close;
} elsif ($indexAll) {
	reindexAllSites();
} else {
	pod2usage();
}

#-------------------------------------------------------------------
sub reindexAllSites {
    my @configs = WebGUI::Paths->siteConfigs;
    foreach my $filename (@configs) {
        my $site = (File::Spec->splitpath($filename))[2];
		print "Indexing ".$site."...\n";
		my $session = WebGUI::Session->open($filename);
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
		my $asset = WebGUI::Asset->newById($session,$id);
                if ( !$asset ) {
                    warn sprintf "- Asset %s (%s) could not be instantiated\n", $id, $class;
                    next;
                }
		if ($asset->get("state") eq "published" && ($asset->get("status") eq "approved" || $asset->get("status") eq "archived")) {
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
		push(@searchableAssetIds, $id);
		my ($done) = $session->db->quickArray("select count(*) from assetIndex where assetId=?",[$id]);
		next if $done;
		my $asset = WebGUI::Asset->newById($session,$id);
		if (defined $asset && $asset->get("status") eq "approved" || defined $asset && $asset->get("status") eq "archived") {
			print $asset->getId."\t".$asset->getTitle."\t";
			my $t = [Time::HiRes::gettimeofday()];
			$asset->indexContent;
			print "(".Time::HiRes::tv_interval($t).")\n";
		}
	}
	
	# delete indexes of assets that are no longer searchable
	my $list = $session->db->quoteAndJoin(\@searchableAssetIds) if scalar(@searchableAssetIds);
	$session->db->write("delete from assetIndex where assetId not in (".$list.")") if $list;
	print "\nSite indexing took ".Time::HiRes::tv_interval($siteTime)." seconds.\n";
}

#-------------------------------------------------
sub readLines {
    my $file = shift;
    my @lines;
    if (open(my $fh, '<', $file)) {
        while (my $line = <$fh>) {
            $line =~ s/#.*//;
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;
            next if !$line;
            push @lines, $line;
        }
        close $fh;
    }
    return @lines;
}

__END__

=head1 NAME

search - Reindex and search a WebGUI site.

=head1 SYNOPSIS

 search --configFile config.conf --indexsite

 search --configFile config.conf --updatesite

 search --configFile config.conf --search text

 search --indexall

 search --help

=head1 DESCRIPTION

This WebGUI utility scripts helps maintaining search indexes on
any site. It can be used to build the index for an entire site,
build the index only for new content, and perform searches.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--indexsite>

Reindexes the entire site specified in the config file. This process
may take a while (even hours) depending on the amount of content the
site has. Server performance will suffer somewhat during the
indexing process. This option requires a B<--configFile> to be
specified.

=item B<--updatesite>

Indexes content that has not be indexed for the site specified in
the config file, keeping the indexes for already indexed content
intact. This is useful if the B<--indexsite> had to be stopped
partway through. This option requires a B<--configFile> to be
specified.

=item B<--search text>

Searches the site specified in the config file for a given keyword or
phrase, returning the results. This option requires a B<--configFile>
to be specified.

=item B<--indexall>

Reindexes B<all> the sites. Note that this can take many hours and
will affect performance of the server during the indexing process.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
