package WebGUI::Macro::r_printable;

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        while ($output =~ /\^r(.*?)\;/) {
                @param = WebGUI::Macro::getParams($1);
                $temp = appendToUrl($session{env}{REQUEST_URI},'makePrintable=1');
		$temp = '<a class="makePrintableLink" href="'.$temp.'">';
                if ($param[0] ne "") {
                        $temp .= $param[0];
                } else {
                        $temp .= WebGUI::International::get(53);
                }
		$temp .= '</a>';
                $output =~ s/\^r(.*?)\;/$temp/;
        }
        #---everything below this line will go away in a later rev.
        if ($output =~ /\^r(.*)\^\/r/) {
                $temp = appendToUrl($session{env}{REQUEST_URI},'makePrintable=1');
                $temp = '<a class="makePrintableLink" href="'.$temp.'">'.$1.'</a>';
                $output =~ s/\^r(.*)\^\/r/$temp/g;
        } elsif ($output =~ /\^r/) {
                $temp = appendToUrl($session{env}{REQUEST_URI},'makePrintable=1');
		$temp = '<a class="makePrintableLink" href="'.$temp.'">';
		$temp .= WebGUI::International::get(53); 
		$temp .= '</a>';
                $output =~ s/\^r/$temp/g;
        }
	return $output;
}

1;

