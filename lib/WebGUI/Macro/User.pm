package WebGUI::Macro::User;

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

#-------------------------------------------------------------------
sub _replacement {
	my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	$temp = $session{user}{$param[0]};
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^User\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


