package WebGUI::Macro::s_specificMenuHorizontal;

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
        my ($temp, $tree, $parentId, @param);
	@param = WebGUI::Macro::getParams($_[0]);
        $temp = '<span class="horizontalMenu">';
        ($parentId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='$param[0]'");
	$tree = WebGUI::Navigation::tree($parentId,1);
	$temp .= WebGUI::Navigation::drawHorizontal($tree,$param[1]);
        $temp .= '</span>';
	return $temp;
}


1;

