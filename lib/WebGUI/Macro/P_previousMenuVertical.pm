package WebGUI::Macro::P_previousMenuVertical;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro;
use WebGUI::Macro::Shared;
use WebGUI::Session;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @param);
        @param = WebGUI::Macro::getParams($_[0]);
        $temp = '<span class="verticalMenu">';
        if ($param[0] ne "") {
        	$temp .= traversePageTree($session{page}{parentId},0,$param[0]);
        } else {
                $temp .= traversePageTree($session{page}{parentId},0,1);
        }
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output,$temp);
        $output = $_[0];
        $output =~ s/\^P\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^P\;/_replacement()/ge;
	return $output;
}

1;

