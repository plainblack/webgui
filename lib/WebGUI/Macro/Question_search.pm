package WebGUI::Macro::Question_search;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $temp = '<form class="searchBox" method="post" action="'.WebGUI::URL::page().'">';
        $temp .= WebGUI::Form::hidden("op","search");
        $temp .= WebGUI::Form::text("keywords",10,100,$session{form}{keywords});
        $temp .= WebGUI::Form::submit(WebGUI::International::get(364));
        $temp .= '</form>';
        $output =~ s/\^\?\;/$temp/g;
	return $output;
}



1;
