package WebGUI::Macro::Splat_random;

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
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
        my ($temp, @param);
        @param = @_;
        if ($param[0] ne "") {
        	$temp = round(rand()*$param[0]);
        } else {
        	$temp = round(rand()*1000000000);
        }
	return $temp;
}




1;
