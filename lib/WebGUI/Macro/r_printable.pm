package WebGUI::Macro::r_printable;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
sub process {
        my ($temp, @param, $styleId);
        @param = WebGUI::Macro::getParams($_[0]);
	my $append = 'op=makePrintable';
	if ($session{env}{REQUEST_URI} =~ /op\=/) {
		$append = 'action2='.WebGUI::URL::escape($append);
	}
        $temp = WebGUI::URL::append($session{env}{REQUEST_URI},$append);
	if ($param[1] ne "") {
		($styleId) = WebGUI::SQL->quickArray("select styleId from style where name=".quote($param[1]),WebGUI::SQL->getSlave);
		if ($styleId != 0) {
			$temp = WebGUI::URL::append($temp,'styleId='.$styleId);
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


1;

