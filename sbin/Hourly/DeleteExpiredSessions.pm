package Hourly::DeleteExpiredSessions;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	WebGUI::SQL->write("delete from userSession where expires<".time(),$_[0]);
}

1;

