package WebGUI::Macro::H_homeLink;

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
        my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	if ($session{setting}{defaultPage} == $session{page}{pageId}) {
		$temp = $session{page}{urlizedTitle};
	} else {
		($temp) = WebGUI::SQL->quickArray("select urlizedTitle from page where pageId=".quote($session{setting}{defaultPage}),WebGUI::SQL->getSlave);
	}
	$temp = WebGUI::URL::gateway($temp);
	if ($param[0] ne "linkonly") {
		my %var;
       		$var{'homelink.url'} = $temp;
       		if ($param[0] ne "") {
               		$var{'homeLink.text'} = $param[0];
       		} else {
               		$var{'homeLink.text'} = WebGUI::International::get(47);
       		}
        	$temp =  WebGUI::Template::process(WebGUI::Template::getIdByName($param[1],"Macro/H_homeLink"), "Macro/H_homeLink", \%var);
	}
	return $temp;
}


1;

