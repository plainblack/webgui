package Hourly::DeleteExpiredGroupings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
	if ($session{config}{DeleteExpiredGroupings_offset} ne "") {
		WebGUI::SQL->write("delete from groupings where expireDate < "
			.(time()-(86400*$session{config}{DeleteExpiredGroupings_offset})));
	}
}

1;

