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
use WebGUI::Macro;
use WebGUI::Macro::Shared;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        while ($output =~ /\^M(.*?)\;/) {
                @param = WebGUI::Macro::getParams($1);
                $temp = '<span class="verticalMenu">';
                if ($param[0] ne "") {
                        $temp .= traversePageTree($session{page}{pageId},0,$param[0]);
                } else {
                        $temp .= traversePageTree($session{page}{pageId},0,1);
                }
                $temp .= '</span>';
                $output =~ s/\^M(.*?)\;/$temp/;
        }
        #---everything below this line will go away in a later rev.
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

