package WebGUI::Macro::Spacer;

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
use WebGUI::Session;
use WebGUI::Macro;

#-------------------------------------------------------------------

sub process {
        my ($output, @param, $width, $height);
        @param = WebGUI::Macro::getParams($_[0]);
        $width = $param[0] if defined $param[0];
        $height = $param[1] if defined $param[1];
        $output = '<img src="'.$session{config}{extrasURL}.'/spacer.gif"'.(defined $width?' width="'.$width.'"':'').(defined $height?' height="'.$height.'"':'').' border="0">';
        return $output;
}

1;

