package WebGUI::Macro::International;

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

#-------------------------------------------------------------------
sub _replacement {
	my (@param);
        @param = WebGUI::Macro::getParams($_[0]);
	return WebGUI::International::get($param[0],$param[1]);
}

#-------------------------------------------------------------------
sub process {
	my ($output);
	$output = $_[0];
        $output =~ s/\^International\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


