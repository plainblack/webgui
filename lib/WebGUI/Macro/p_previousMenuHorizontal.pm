package WebGUI::Macro::p_previousMenuHorizontal;

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
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, $tree, @param);
        @param = WebGUI::Macro::getParams($_[0]);
	$tree = WebGUI::Navigation::tree($session{page}{parentId},1);
        $temp = '<span class="horizontalMenu">';
	$temp .= WebGUI::Navigation::drawHorizontal($tree,$param[0]);
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
	$output =~ s/\^p\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^p\;/_replacement()/ge;
	return $output;
}

1;

