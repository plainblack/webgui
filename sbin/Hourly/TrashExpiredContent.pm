package Hourly::TrashExpiredContent;

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
	my $offset = $session{config}{TrashExpiredContent_offset};
	if ($offset ne "") {
		my $epoch = time()-(86400*$offset);
		my $sth = WebGUI::SQL->read("select pageId from page where endDate<".$epoch);
		while (my ($pageId) = $sth->array) {
			my $page = WebGUI::Page->new($pageId);
			$page->delete;
		}
		$sth->finish;
		WebGUI::SQL->write("update wobject set pageId=3, endDate=endDate+31536000 where endDate<".$epoch);
	}
}

1;

