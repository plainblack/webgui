package WebGUI::Macro::GroupText;

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
use WebGUI::Macro;
use WebGUI::SQL;
use WebGUI::Session;
use WebGUI::Privilege;

#-------------------------------------------------------------------
sub process {
	my @param = WebGUI::Macro::getParams($_[0]);
	my ($groupId) = WebGUI::SQL->quickArray("select groupId from groups where groupName=".quote($param[0]));
	$groupId = 3 if ($groupId eq "");
	if (WebGUI::Privilege::isInGroup($groupId)) { 
		return $param[1];
	} else {
		return $param[2];
	}
}


1;

