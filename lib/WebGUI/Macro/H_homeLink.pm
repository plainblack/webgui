package WebGUI::Macro::H_homeLink;

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

#-------------------------------------------------------------------
sub _replacement {
        my (@param, $temp);
        @param = WebGUI::Macro::getParams($1);
        $temp = '<a class="homeLink" href="'.$session{env}{SCRIPT_NAME}.'/home">';
        if ($param[0] ne "") {
		$temp .= $param[0];
        } else {
        	$temp .= WebGUI::International::get(47);
        }
        $temp .= '</a>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        $output =~ s/\^H\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^H\;/_replacement()/ge;
        #---everything below this line will go away in a later rev.
        if ($output =~ /\^H(.*)\^\/H/) {
                $temp = '<a class="homeLink" href="'.$session{env}{SCRIPT_NAME}.'/home">'.$1.'</a>';
                $output =~ s/\^H(.*)\^\/H/$temp/g;
        } elsif ($output =~ /\^H/) {
        	$temp = '<a class="homeLink" href="'.$session{env}{SCRIPT_NAME}.'/home">'.WebGUI::International::get(47).'</a>';
        	$output =~ s/\^H/$temp/g;
	}
	return $output;
}

1;

