package WebGUI::Macro::LoginToggle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
       my (@param, $temp, $login, $logout);
       @param = WebGUI::Macro::getParams($_[0]);
       if ($session{user}{userId} == 1) {
		if ($param[0] eq "linkonly") {
			return WebGUI::URL::page('op=displayLogin');
		}
              	$login = $param[0] || WebGUI::International::get(716);
               	$temp = '<a class="loginToggleLink" href="'.WebGUI::URL::page('op=displayLogin').'">'.$login.'</a>';
       } else {
		if ($param[0] eq "linkonly") {
			return WebGUI::URL::page('op=logout');
		}
               	$logout = $param[1] || WebGUI::International::get(717);
               	$temp = '<a class="loginToggleLink" href="'.WebGUI::URL::page('op=logout').'">'.$logout.'</a>';
       }
       return $temp;
}


1;

