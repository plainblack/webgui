package Hourly::DeleteExpiredClipboard;

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
	if ($session{config}{DeleteExpiredClipboard_offset} ne "") {
		my $expireDate = (time()-(86400*$session{config}{DeleteExpiredClipboard_offset}));
		my $sth = WebGUI::SQL->read("select assetId,className from asset where state='clipboard' and lastUpdated <".$expireDate);
		while (my ($id, $class) = $sth->array) {
			my $asset = WebGUI::Asset->newByDynamicClass($id,$class);
			$asset->trash;
		}
		$sth->finish;
	}
}

1;

