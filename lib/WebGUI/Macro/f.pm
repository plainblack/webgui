package WebGUI::Macro::f;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro::Shared;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---full menu (vertical)---
        if ($output =~ /\^f/) {
                $temp = '<span class="verticalMenu">';
        	$temp .= traversePageTree(1,0);
        	$temp .= '</span>';
                $output =~ s/\^f/$temp/g;
	}
	return $output;
}

1;

