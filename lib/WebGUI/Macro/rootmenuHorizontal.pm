package WebGUI::Macro::rootmenuHorizontal;

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
	my @param = WebGUI::Macro::getParams($_[0]);
	my $tree = WebGUI::Navigation::tree(0,1);
        my $temp = '<span class="horizontalMenu">';
	$temp .= WebGUI::Navigation::drawHorizontal($tree,$param[0]);
        $temp .= '</span>';
	return $temp;
}


1;

