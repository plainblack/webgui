package WebGUI::Macro::h;

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
  #---3 level menu (vertical)---
        if ($output =~ /\^h/) {
                $temp = '<span class="verticalMenu">';
        	$temp .= traversePageTree(1,0,3);
        	$temp .= '</span>';
                $output =~ s/\^h/$temp/g;
        }
	return $output;
}

1;

