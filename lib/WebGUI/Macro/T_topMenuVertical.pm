package WebGUI::Macro::T_topMenuVertical;

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

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @param, $tree);
        @param = WebGUI::Macro::getParams($_[0]);
        $temp = '<span class="verticalMenu">';
        if ($param[0] ne "") {
                $tree = WebGUI::Navigation::tree(1,$param[0]);
        } else {
                $tree = WebGUI::Navigation::tree(1,1);
        }
        $temp .= WebGUI::Navigation::drawVertical($tree);
        $temp .= '</span>';
        return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output,$temp);
        $output = $_[0];
        $output =~ s/\^T\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^T\;/_replacement()/ge;
	return $output;
}

1;

