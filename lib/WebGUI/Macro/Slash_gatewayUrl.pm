package WebGUI::Macro::Slash_gatewayUrl;

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
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	my ($output);
	$output = $_[0];
        $output =~ s/\^\/\;/WebGUI::URL::gateway()/ge;
	return $output;
}



1;

