package WebGUI::Macro::S_specificMenuVertical;

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
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
        my ($temp, @param, $pageId, $tree);
        @param = WebGUI::Macro::getParams($_[0]);
        ($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='$param[0]'");
        if (defined $pageId) {
        	$temp = '<span class="verticalMenu">';
		if ($param[1] ne "") {
			$tree = WebGUI::Navigation::tree($pageId,$param[1]);
		} else {
			$tree = WebGUI::Navigation::tree($pageId,1);
		}
		$temp .= WebGUI::Navigation::drawVertical($tree);
        	$temp .= '</span>';
        }
	return $temp;
}


1;

