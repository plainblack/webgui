package Hourly::GetSyndicatedContent;

use strict;
use warnings;
use WebGUI::SQL;
use WebGUI::Asset::Wobject::SyndicatedContent;

=head2 Hourly::GetSyndicatedContent

Loops through all the URLs in the SyndicatedWobjects and puts them into WebGUI::Cache if they haven't been spidered or if they have expired from the cache. This should reduce HTTP traffic a little, and allow for more granular scheduling of feed downloads in the future.

=cut


#-------------------------------------------------------------------
sub process{

    #In the new Wobject, "rssURL" actually can refer to more than one URL.
    my @syndicatedWobjectURLs = WebGUI::SQL->buildArray("select distinct SyndicatedContent.rssUrl from SyndicatedContent left join asset on SyndicatedContent.assetId=asset.assetId where asset.state='published'");
    foreach my $url(@syndicatedWobjectURLs) {

	#Loop through the SyndicatedWobjects and split all the URLs they are syndicating off into
	#a separate array.
	
	my @urlsToSyndicate = split(/\s+/,$url);
	foreach ((@urlsToSyndicate)) {
	    WebGUI::Asset::Wobject::SyndicatedContent::_get_rss_data($_);
	}
    }
}



1;
