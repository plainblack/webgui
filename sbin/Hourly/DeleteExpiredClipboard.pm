package Hourly::DeleteExpiredClipboard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	if ($session{config}{DeleteExpiredClipboard_offset} ne "") {
		my $expireDate = (time()-(86400*$session{config}{DeleteExpiredClipboard_offset}));

		WebGUI::ErrorHandler::audit("moving expired clipboard items to trash");

		WebGUI::SQL->write("update page set parentId=3, bufferPrevId=2, bufferDate=" .time()
				." where parentId=2 and bufferDate < ". $expireDate );

		WebGUI::SQL->write("update wobject set pageId=3, bufferPrevId=2, bufferDate=" .time()
				." where pageId=2 and bufferDate < ". $expireDate );
	}
}

1;

