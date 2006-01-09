package Hourly::CleanLoginHistory;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
	if ($session{config}{CleanLoginHistory_ageToDelete}) {
		WebGUI::SQL->write("delete from userLoginLog 
			where timeStamp < ".(time()-(86400*$session{config}{CleanLoginHistory_ageToDelete})));
	}
}

1;

