package WebGUI::Macro::t_topMenuHorizontal;

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
        my ($temp, $tree, @param);
	@param = WebGUI::Macro::getParams($_[0]);
	my $root = _findRoot($session{page}{pageId});
	$tree = WebGUI::Navigation::tree($root,1);
        $temp = '<span class="horizontalMenu">';
	$temp .= WebGUI::Navigation::drawHorizontal($tree,$param[0]);
        $temp .= '</span>';
	return $temp;
}

sub _findRoot {
        my ($pageId,$parentId) = WebGUI::SQL->quickArray("select pageId,parentId from page where pageId=$_[0]");
        if ($parentId == $_[1]) {
                return $pageId;
        } else {
                return _findRoot($parentId);
        }
}


1;

