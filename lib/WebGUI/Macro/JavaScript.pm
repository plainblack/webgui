package WebGUI::Macro::JavaScript;

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
use WebGUI::Style;

#-------------------------------------------------------------------
sub process {
	my ($script) = WebGUI::Macro::getParams(shift);
	WebGUI::Style::setScript($script,{type=>'text/javascript'});
	return "";
}

1;


