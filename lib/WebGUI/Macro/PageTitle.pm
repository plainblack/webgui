package WebGUI::Macro::PageTitle;

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
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	if ($session{form}{op} || $session{form}{func}) {
        	return '<a href="'.WebGUI::URL::page().'">'.$session{page}{title}.'</a>';
	} else {
		return $session{page}{title};
	}
}


1;

