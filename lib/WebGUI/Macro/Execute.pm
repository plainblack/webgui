package WebGUI::Macro::Execute;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

#-------------------------------------------------------------------
sub process {
        my @param = @_;
	if ($param[0] =~ /passwd/ || $param[0] =~ /shadow/ || $param[0] =~ /\.conf/) {
		return "SECURITY VIOLATION";
	} else {
       		return `$param[0]`;
	}
}

1;


