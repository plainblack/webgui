package WebGUI::Macro::Quote;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	return quote(shift);
	
}


1;

