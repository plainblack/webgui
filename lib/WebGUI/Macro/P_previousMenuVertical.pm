package WebGUI::Macro::P_previousMenuVertical;

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
use WebGUI::Macro;
use WebGUI::Navigation;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my ($temp, @param, $tree);
        @param = WebGUI::Macro::getParams($_[0]);
        $temp = '<span class="verticalMenu">';
        if ($param[0] ne "") {
        	$tree = WebGUI::Navigation::tree($session{page}{parentId},$param[0]);
        } else {
                $tree = WebGUI::Navigation::tree($session{page}{parentId},1);
        }
	$temp .= WebGUI::Navigation::drawVertical($tree);
        $temp .= '</span>';
	return $temp;
}


1;

