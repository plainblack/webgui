package WebGUI::Macro::J;

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
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
  #---3 level current level menu (vertical)---
        if ($output =~ /\^J/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree($session{page}{pageId},0,3);
                $temp .= '</span>';
                $output =~ s/\^J/$temp/g;
        }
	return $output;
}

1;

