package WebGUI::Macro::P_previousMenuVertical;

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
  #---previous menu vertical---
        if ($output =~ /\^P(.*)\^\/P/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree($session{page}{parentId},0,$1);
                $temp .= '</span>';
                $output =~ s/\^P(.*)\^\/P/$temp/g;
        } elsif ($output =~ /\^P/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree($session{page}{parentId},0,1);
                $temp .= '</span>';
                $output =~ s/\^P/$temp/g;
        }
	return $output;
}

1;

