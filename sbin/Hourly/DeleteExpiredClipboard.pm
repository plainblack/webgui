package Hourly::DeleteExpiredClipboard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use WebGUI::DateTime;
use WebGUI::Page;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	if ($session{config}{DeleteExpiredClipboard_offset} ne "") {
		my $expireDate = (time()-(86400*$session{config}{DeleteExpiredClipboard_offset}));
		WebGUI::ErrorHandler::audit("moving expired clipboard items to trash");
		my $sth = WebGUI::SQL->read("select pageId from page where parentId=2 and bufferDate <".$expireDate);
		while (my ($pageId) = $sth->array) {
			my $page = WebGUI::Page->new($pageId);
			$page->delete;
		}
		$sth->finish;
		WebGUI::SQL->write("update wobject set pageId=3, bufferPrevId=2, bufferDate=" .WebGUI::DateTime::time()
				." where pageId=2 and bufferDate < ". $expireDate );
	}
}

1;

