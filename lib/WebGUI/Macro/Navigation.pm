package WebGUI::Macro::Navigation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
#use WebGUI::Navigation;

#-------------------------------------------------------------------
sub process {
	return "Nav disabled.";
        my @param = WebGUI::Macro::getParams($_[0]);

	my $identifier = $param[0];
	if ($identifier eq '') {
		return WebGUI::Macro::negate(WebGUI::International::get(35,'Navigation'));
	} else {
		my $navigation = WebGUI::Navigation->new(identifier=>$identifier);
		return $navigation->view;
	}
}


1;


