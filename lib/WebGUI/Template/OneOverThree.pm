package WebGUI::Template::OneOverThree;

our $namespace = "OneOverThree";

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


#-------------------------------------------------------------------
sub generate {
	my ($output, $content);
	$content = $_[0];
	$output = '<table cellpadding="3" cellspacing="0" border="0" width="100%">';
	$output .= '<tr><td valign="top" class="content" colspan="3">';
	$output .= ${$content}{A};
	$output .= '</td></tr><tr>';
	$output .= '<td valign="top" class="content" width="33%">'.${$content}{B}.'</td>';
	$output .= '<td valign="top" class="content" width="34%">'.${$content}{C}.'</td>';
	$output .= '<td valign="top" class="content" width="33%">'.${$content}{D}.'</td>';
	$output .= '</tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(360);
}

#-------------------------------------------------------------------
sub getPositions {
        return WebGUI::Template::calculatePositions('D');
}

1;

