package WebGUI::Macro::M_currentMenuVertical;

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
  #---current menu vertical---
        if ($output =~ /\^M(.*)\^\/M/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree($session{page}{pageId},0,$1);
                $temp .= '</span>';
                $output =~ s/\^M(.*)\^\/M/$temp/g;
        } elsif ($output =~ /\^M/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree($session{page}{pageId},0,1);
                $temp .= '</span>';
                $output =~ s/\^M/$temp/g;
        }
	return $output;
}

1;

