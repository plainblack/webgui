package WebGUI::Macro::D_date;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::DateTime;
use WebGUI::Macro;

#-------------------------------------------------------------------
sub process {
        my (@param, $temp, $time);
        @param = WebGUI::Macro::getParams($_[0]);
	$time = $param[1] || time();
	$temp = epochToHuman($time,$param[0]);
	return $temp;
}


1;

