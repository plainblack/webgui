package WebGUI::Macro::Splat_random;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @param);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[0] ne "") {
        	$temp = round(rand()*$1);
        } else {
        	$temp = round(rand()*1000000000);
        }
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output,$temp);
        $output = $_[0];
        $output =~ s/\^\*\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^\*\;/_replacement()/ge;
	return $output;
}



1;
