package WebGUI::Macro::F;

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
  #---2 level menu (vertical)---
        if ($output =~ /\^F/) {
                $temp = '<span class="verticalMenu">';
        	$temp .= traversePageTree(1,0,2);
        	$temp .= '</span>';
                $output =~ s/\^F/$temp/g;
        }
	return $output;
}

1;

