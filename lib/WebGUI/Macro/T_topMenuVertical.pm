package WebGUI::Macro::T_topMenuVertical;

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
use WebGUI::Macro;
use WebGUI::Macro::Shared;

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        while ($output =~ /\^T(.*?)\;/) {
                @param = WebGUI::Macro::getParams($1);
                $temp = '<span class="verticalMenu">';
                if ($param[0] ne "") {
                	$temp .= traversePageTree(1,0,$param[0]);
                } else {
                	$temp .= traversePageTree(1,0,1);
                }
                $temp .= '</span>';
                $output =~ s/\^T(.*?)\;/$temp/;
        }
        #---everything below this line will go away in a later rev.
        if ($output =~ /\^T(.*)\^\/T/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree(1,0,$1);
                $temp .= '</span>';
                $output =~ s/\^T(.*)\^\/T/$temp/g;
        } elsif ($output =~ /\^T/) {
                $temp = '<span class="verticalMenu">';
                $temp .= traversePageTree(1,0,1);
                $temp .= '</span>';
                $output =~ s/\^T/$temp/g;
        }
	return $output;
}

1;

