package WebGUI::Macro::M_currentMenuVertical;

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
        my ($tree, $temp, @param);
        @param = WebGUI::Macro::getParams($_[0]);
        $temp = '<span class="verticalMenu">';
        if ($param[0] ne "") {
        	$tree = WebGUI::Navigation::tree($session{page}{pageId},$param[0]);
        } else {
        	$tree = WebGUI::Navigation::tree($session{page}{pageId},1);
        }
	$temp .= WebGUI::Navigation::drawVertical($tree);
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        $output =~ s/\^M\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^M\;/_replacement()/ge;
	return $output;
}

1;

