package WebGUI::Macro::URLEncode;

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
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _replacement {
        my (@param);
        @param = WebGUI::Macro::getParams($1);
	return WebGUI::URL::escape($param[0]);
}

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        $output =~ s/\^URLEncode\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;

