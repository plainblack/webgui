package WebGUI::Macro::H_homeLink;

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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _replacement {
        my (@param, $temp);
        @param = WebGUI::Macro::getParams($1);
	($temp) = WebGUI::SQL->quickArray("select urlizedTitle from page where pageId=$session{setting}{defaultPage}");
	$temp = WebGUI::URL::gateway($temp);
	if ($param[0] ne "linkonly") {
        	$temp = '<a class="homeLink" href="'.$temp.'">';
        	if ($param[0] ne "") {
			$temp .= $param[0];
        	} else {
        		$temp .= WebGUI::International::get(47);
        	}
        	$temp .= '</a>';
	}
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        $output =~ s/\^H\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^H\;/_replacement()/ge;
	return $output;
}

1;

