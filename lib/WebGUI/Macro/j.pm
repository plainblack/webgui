package WebGUI::Macro::j;

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
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---2 level current level menu (vertical)---
        if ($output =~ /\^j/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree($session{page}{pageId},0,2);
                $temp .= '</span>';
                $output =~ s/\^j/$temp/g;
        }
	return $output;
}

1;

