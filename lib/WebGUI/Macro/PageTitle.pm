package WebGUI::Macro::PageTitle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	if (exists $session{asset}) {
		if ($session{form}{op} || $session{form}{func}) {
	        	return '<a href="'.$session{asset}->getUrl.'">'.$session{asset}->get("title").'</a>';
		} else {
			return $session{asset}->get("title");
		}
	}
}


1;

