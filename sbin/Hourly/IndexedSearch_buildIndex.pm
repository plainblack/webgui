package Hourly::IndexedSearch_buildIndex; 

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use DBI;
use strict;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Asset::Wobject::IndexedSearch::Search;


#-------------------------------------------------------------------
sub process {
	#disabled until 6.8
	return "";
	my $indexName = 'IndexedSearch_default';
        my $htmlFilter = 'all';
        my $stopList = 'none';
        my $stemmer = 'none';
        my $backend = 'phrase';

	my $verbose = shift;
	my ($dateIndexed) = WebGUI::SQL->quickArray("select max(dateIndexed) from IndexedSearch_docInfo where indexName = ".quote($indexName)); 
	if (WebGUI::DateTime::time()-$dateIndexed < 86400) {
		print " - Recently Indexed: Skipping " if ($verbose);
		return "";
	}	
	print "\n";
	undef $stopList if ($stopList eq 'none');
	undef $stemmer  if ($stemmer eq 'none');
	my $indexInfo = getIndexerParams();
	my $search = WebGUI::Asset::Wobject::IndexedSearch::Search->new($indexName);
	$search->recreate('','',stemmer => $stemmer, stoplist => $stopList, backend => $backend);
	my $startTime = WebGUI::DateTime::time();
	foreach my $asset (keys %{$indexInfo}) { 
print "Doing: $asset\n"; # DEBUG
		my $sth = WebGUI::SQL->read($indexInfo->{$asset}{sql});
		my $total = $sth->rows;
		my $actual = 1;
		while (my %data = $sth->hash) {
			if ($verbose) {
				print "\r\t\tIndexing $asset data ($total items) ...".
				(" " x (30 - (length($asset)) - length("$total"))).
				int(($actual/$total)*100)." %   ";
			}
			my $textToIndex = "";
			foreach my $field (@{$indexInfo->{$asset}{fieldsToIndex}}) {
				if($field =~ /^\s*select/i) {
					my $sql = eval 'sprintf("%s","'.$field.'")';
					$textToIndex .= join("\n", WebGUI::SQL->buildArray($sql));
				} else {
					$textToIndex .= $data{$field}."\n";
				}
			}
			$textToIndex = WebGUI::HTML::filter($textToIndex,$htmlFilter);
			my $url = eval $indexInfo->{$asset}{url};
			my $headerShortcut = eval 'sprintf("%s","'.$indexInfo->{$asset}{headerShortcut}.'")';
			my $bodyShortcut = eval 'sprintf("%s","'.$indexInfo->{$asset}{bodyShortcut}.'")';
			$search->indexDocument({
						text => $textToIndex,
						assetId => $data{assetId},
						groupIdView => $data{groupIdView},
						special_groupIdView => $data{special_groupIdView},
						namespace => $asset,
						location => $url,
						headerShortcut => $headerShortcut,
						bodyShortcut => $bodyShortcut,
						contentType => $indexInfo->{$asset}{contentType},
						ownerId => $data{ownerId}
						});
			$actual++;
		}
	print "\n" if ($verbose && $total);
	}
	print "\t\t".(($search->getDocId -1)." WebGUI items indexed in ".(time() - $startTime)." seconds.\n\t") if ($verbose);
	$search->close;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $now = WebGUI::DateTime::time();
	# don't add indexer parameters here. Rather edit the corresponding file in WebGUI/Asset/Wobject/*.pm
	my %params;
	foreach my $class (@{$session{config}{assets}}) {
                my $load = 'use '.$class;
                eval($load);
		if ($@) {
			WebGUI::ErrorHandler::warn("Couldn't compile ".$class." because ".$@);
		} else {
			my $assetIndexParams = eval{$class->getIndexerParams($now)};
			if (ref $assetIndexParams eq 'HASH') {
				%params = (%params, %{$assetIndexParams});
			}
		}
	}
	#use Data::Dumper ; die Dumper(\%params);
	return \%params;
}

1;
