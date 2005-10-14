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
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my $offset = $session{config}{TrashExpiredContent_offset};
	if ($offset ne "") {
		my $now = time();
		$offset = 86400*$offset;
		my $sth = WebGUI::SQL->read("select asset.assetId, asset.className from assetData left join asset on assetData.assetId=asset.assetId where asset.state='published' and assetData.endDate + $offset < $now");
		while (my ($assetId,$class) = $sth->array) {
			my $asset = WebGUI::Asset->new($assetId,$class);
			$asset->trash if ($asset->get("endDate")+$offset < $now); # verify end date of most recent revision
		}
		$sth->finish;
	}
}

1;

