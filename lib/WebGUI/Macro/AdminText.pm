package WebGUI::Macro::AdminText;

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
use WebGUI::Session;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp,@param);
        @param = WebGUI::Macro::getParams(shift);
        if ($session{var}{adminOn}) {
                $temp = $param[0];
        } else {
                $temp = "";
        }
        return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output) = @_;
	$output =~ s/\^AdminText\((.*?)\)\;/$1/ge;
        return $output;
}

1;

