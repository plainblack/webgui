package WebGUI::Macro::r_printable;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
        my ($temp, @param, $styleId);
        @param = WebGUI::Macro::getParams($_[0]);
	my $append = 'op=makePrintable';
	if ($session{env}{REQUEST_URI} =~ /op\=/) {
		$append = 'op2='.WebGUI::URL::escape($append);
	}
        $temp = WebGUI::URL::append($session{env}{REQUEST_URI},$append);
	if ($param[1] ne "") {
		($styleId) = WebGUI::Template::getIdByName($param[1],"style");
		if ($styleId != 0) {
			$temp = WebGUI::URL::append($temp,'styleId='.$styleId);
		}
	}
	if ($param[0] ne "linkonly") {
		my %var;
		$var{'printable.url'} = $temp;
       		if ($param[0] ne "") {
               		$var{'printable.text'} = $param[0];
       		} else {
               		$var{'printable.text'} = WebGUI::International::get(53);
       		}
         	$temp =  WebGUI::Template::process(WebGUI::Template::getIdByName($param[2],"Macro/r_printable"), "Macro/r_printable", \%var);
	}
	return $temp;
}


1;

