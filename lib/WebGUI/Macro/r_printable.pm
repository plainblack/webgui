package WebGUI::Macro::r_printable;

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @param, $styleId);
        @param = WebGUI::Macro::getParams($_[0]);
        $temp = WebGUI::URL::append($session{env}{REQUEST_URI},'makePrintable=1');
	if ($param[1] ne "") {
		($styleId) = WebGUI::SQL->quickArray("select styleId from style where name=".quote($param[1]));
		if ($styleId != 0) {
			$temp = WebGUI::URL::append($temp,'style='.$styleId);
		}
	}
	if ($param[0] ne "linkonly") {
        	$temp = '<a class="makePrintableLink" href="'.$temp.'">';
        	if ($param[0] ne "") {
        		$temp .= $param[0];
        	} else {
                	$temp .= WebGUI::International::get(53);
        	}
        	$temp .= '</a>';
	}
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output, $temp);
        $output = $_[0];
        $output =~ s/\^r\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^r\;/_replacement()/ge;
	return $output;
}

1;

