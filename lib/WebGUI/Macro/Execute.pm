package WebGUI::Macro::Execute;

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

#-------------------------------------------------------------------
sub _replacement {
	my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	if ($param[0] =~ /passwd/ || $param[0] =~ /shadow/ || $param[0] =~ /WebGUI.conf/) {
		$temp = "SECURITY VIOLATION";
	} else {
       		$temp = "<pre>".`$param[0]`."</pre>";
	}
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^Execute\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


