package WebGUI::Macro::AdminToggle;

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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _replacement {
	my ($temp);
	if (WebGUI::Privilege::isInGroup(4)) {
		if ($session{var}{adminOn}) {
			$temp = '<a href="'.WebGUI::URL::page('op=switchOffAdmin').'">'.WebGUI::International::get(517).'</a>';
		} else {
			$temp = '<a href="'.WebGUI::URL::page('op=switchOnAdmin').'">'.WebGUI::International::get(516).'</a>';
		}
	}
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^AdminToggle\;/_replacement()/ge;
	return $output;
}

1;


