package Hourly::DeleteExpiredTrash;

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
	if ($session{config}{DeleteExpiredTrash_offset} ne "") {
		my (%properties, $base, $extended, $b, $w, $cmd, $purgeDate, $a, $pageId);
		tie %properties, 'Tie::CPHash';

		$purgeDate = (time()-(86400*$session{config}{DeleteExpiredTrash_offset}));

		# Delete wobjects
		$b = WebGUI::SQL->read("select * from wobject where pageId=3 and bufferDate<" . $purgeDate);
		while ($base = $b->hashRef) {
			$extended = WebGUI::SQL->quickHashRef("select * from ".$base->{namespace}."
				where wobjectId=".$base->{wobjectId});
			%properties = (%{$base}, %{$extended});
			$cmd = "WebGUI::Wobject::".$properties{namespace};
			$w = $cmd->new(\%properties);
			WebGUI::ErrorHandler::audit("purging expired wobject ". $base->{wobjectId} ." from trash");
			$w->purge;

		}
		$b->finish;

		# Delete pages and all subpages
		$a = WebGUI::SQL->read("select pageId from page where parentId=3 and bufferDate<" . $purgeDate);
		while (($pageId) = $a->array) {
			WebGUI::ErrorHandler::audit("purging expired page ". $pageId ." from trash");
			WebGUI::Operation::Trash::_recursePageTree($pageId);
			WebGUI::Operation::Trash::_purgeWobjects($pageId);
			WebGUI::SQL->write("delete from page where pageId=$pageId");
		}
		$a->finish;
	}
}

1;

