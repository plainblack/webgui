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
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---home link---
        if ($output =~ /\^H(.*)\^\/H/) {
                $temp = '<a href="'.$session{env}{SCRIPT_NAME}.'/home">'.$1.'</a>';
                $output =~ s/\^H(.*)\^\/H/$temp/g;
        } elsif ($output =~ /\^H/) {
        	$temp = '<a href="'.$session{env}{SCRIPT_NAME}.'/home">'.WebGUI::International::get(47).'</a>';
        	$output =~ s/\^H/$temp/g;
	}
	return $output;
}

1;

