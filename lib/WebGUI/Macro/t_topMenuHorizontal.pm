package WebGUI::Macro::t_topMenuHorizontal;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
sub _replacement {
        my ($temp, $tree, @param);
	@param = WebGUI::Macro::getParams($_[0]);
	$tree = WebGUI::Navigation::tree(1,1);
        $temp = '<span class="horizontalMenu">';
	$temp .= WebGUI::Navigation::drawHorizontal($tree,$param[0]);
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
	$output =~ s/\^t\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^t\;/_replacement()/ge;
	return $output;
}

1;

