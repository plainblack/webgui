package Hourly::EmptyTrash;

#-----------------------------------------
# Copyright 2002 Plain Black LLC
#-----------------------------------------
# Before using this software be sure you
# agree to the terms of its license, which
# can be found in docs/ihpkit.pdf of this
# distribution.
#-----------------------------------------
# http://www.plainblack.com
# info@plainblack.com
#-----------------------------------------


use strict;
use WebGUI::DateTime;
use WebGUI::Operation::Trash;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
        my @date = WebGUI::DateTime::localtime();
	if ($date[1] == $session{config}{EmptyTrash_day} && $date[4] == 1) { # only occurs at 1am on the day in question.
		WebGUI::Operation::Trash::www_purgeTrashConfirm();
	}
}

1;

