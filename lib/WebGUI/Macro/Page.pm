package WebGUI::Macro::Page;

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
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	$temp = $session{page}{$param[0]};
	return $temp;
}


1;


