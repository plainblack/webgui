package WebGUI::Macro::GroupText;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
sub _replacement {
        my ($temp,@param,$groupId);
	@param = WebGUI::Macro::getParams($_[0]);
	($groupId) = WebGUI::SQL->quickArray("select groupId from groups where groupName=".quote($param[0]));
	$groupId = 3 if ($groupId eq "");
	if (WebGUI::Privilege::isInGroup($groupId)) { 
		$temp = $param[1];
	} else {
		$temp = "";
	}
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output) = @_;
	$output =~ s/\^GroupText\((.*?)\)\;/_replacement($1)/ge;
        return $output;
}

1;

