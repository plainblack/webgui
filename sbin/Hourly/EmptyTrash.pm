package Hourly::EmptyTrash;

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
use WebGUI::Operation::Trash;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
        my @date = WebGUI::DateTime::localtime(WebGUI::DateTime::time());
	if ($date[1] == $session{config}{EmptyTrash_day} && $date[4] == 1) { # only occurs at 1am on the day in question.
		WebGUI::ErrorHandler::audit("emptying system trash");
		WebGUI::Operation::Trash::_recursePageTree(3);
		WebGUI::Operation::Trash::_purgeWobjects(3);

	}
}

1;

