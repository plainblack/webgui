package WebGUI::Template::ThreeOverOne;

our $namespace = "ThreeOverOne";

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
	$output = '<table cellpadding="3" cellspacing="0" border="0" width="100%"><tr>';
	$output .= '<td valign="top" class="content" width="33%">'.${$content}{A}.'</td>';
	$output .= '<td valign="top" class="content" width="34%">'.${$content}{B}.'</td>';
	$output .= '<td valign="top" class="content" width="33%">'.${$content}{C}.'</td>';
	$output .= '</tr><tr><td valign="top" class="content" colspan="3">'.${$content}{D}.'</td></tr>';
	$output .= '</table>';
	return $output;
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(361);
}

#-------------------------------------------------------------------
sub getPositions {
        return WebGUI::Template::calculatePositions('D');
}

1;

