package WebGUI::Macro::File;

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
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
	my $collateral = WebGUI::Collateral->find($param[0]);
	return '<a href="'.$collateral->getURL.'"><img src="'.$collateral->getIcon.'" align="middle" border="0" /> '.$collateral->get("name").'</a>'; 
}

1;


