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
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---remove style for printing link---
        if ($output =~ /\^r(.*)\^\/r/) {
                $temp = $session{env}{REQUEST_URI};
                if ($temp =~ /\?/) {
                        $temp .= '&makePrintable=1';
                } else {
                        $temp .= '?makePrintable=1';
                }
                $temp = '<a href="'.$temp.'">'.$1.'</a>';
                $output =~ s/\^r(.*)\^\/r/$temp/g;
        } elsif ($output =~ /\^r/) {
                $temp = $session{env}{REQUEST_URI};
		if ($temp =~ /\?/) {
			$temp .= '&makePrintable=1';
		} else {
			$temp .= '?makePrintable=1';
		}
		$temp = '<a href="'.$temp.'">';
		$temp .= WebGUI::International::get(53); 
		$temp .= '</a>';
                $output =~ s/\^r/$temp/g;
        }
	return $output;
}

1;

