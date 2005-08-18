package Hourly::TrashExpiredContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my $offset = $session{config}{TrashExpiredContent_offset};
	if ($offset ne "") {
		my $epoch = time()-(86400*$offset);
		my $sth = WebGUI::SQL->read("select asset.assetId,asset.className,max(assetData.revisionDate) from asset left join assetData on
			asset.assetId=assetData.assetId where assetData.endDate<".$epoch." group by assetData.assetId");
		while (my ($assetId, $class, $version) = $sth->array) {
			my $asset = WebGUI::Asset->new($assetId,$class,$version);
			$asset->trash;
		}
		$sth->finish;
	}
}

1;

