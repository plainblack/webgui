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
use WebGUI::Operation::Trash;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	WebGUI::Operation::Trash::www_purgeTrashConfirm();
}

1;

