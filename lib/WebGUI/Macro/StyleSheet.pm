package WebGUI::Macro::StyleSheet;

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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Style;

#-------------------------------------------------------------------
sub process {
	my ($file) = WebGUI::Macro::getParams(shift);
	WebGUI::Style::setLink($file,{
		type=>'text/css',
		rel=>'stylesheet'
		});
	return "";
}

1;


