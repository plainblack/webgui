package WebGUI::Operation::Admin;

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
use WebGUI::AdminConsole;
use WebGUI::Grouping;
use WebGUI::Session;

#-------------------------------------------------------------------
sub www_adminConsole {
	return "" unless (WebGUI::Grouping::isInGroup(12));
	my $ac = WebGUI::AdminConsole->new;
	return $ac->render;
}

#-------------------------------------------------------------------
sub www_switchOffAdmin {
	return "" unless (WebGUI::Grouping::isInGroup(12));
	WebGUI::Session::switchAdminOff();
	return "";
}

#-------------------------------------------------------------------
sub www_switchOnAdmin {
	return "" unless (WebGUI::Grouping::isInGroup(12));
	WebGUI::Session::switchAdminOn();
	return "";
}


1;
