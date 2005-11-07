package WebGUI::Macro::D_date;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::DateTime;

#-------------------------------------------------------------------
sub process {
        my (@param, $temp, $time);
        @param = @_;
	$time = $param[1] || time();
	$temp = epochToHuman($time,$param[0]);
	return $temp;
}


1;

