package WebGUI::Macro::D_date;

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
use WebGUI::DateTime;
use WebGUI::Macro;

#-------------------------------------------------------------------
sub _replacement {
        my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[0] ne "") {
		$temp = epochToHuman(time(),$param[0]);
        } else {
        	$temp = localtime(time());
        }
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output);
        $output = $_[0];
        $output =~ s/\^D\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^D\;/_replacement()/ge;
	return $output;
}

1;

