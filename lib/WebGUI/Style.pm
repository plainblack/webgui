package WebGUI::Style;

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
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub getStyle {
	my ($header, $footer, @style, %style);
	%style = WebGUI::SQL->quickHash("select header,footer,styleSheet from style where styleId=$session{page}{styleId}",$session{dbh});
	$header = '<html>
		<head>
		<title>'.$session{page}{title}.'</title>'.$style{styleSheet}.$session{page}{metaTags}.'
		<script language="JavaScript" src="'.$session{setting}{lib}.'/WebGUI.js"></script>
		</head>
		<!-- WebGUI '.$session{wg}{version}.' -->
		'.$style{header};
	$footer = $style{footer};
	$header = WebGUI::Macro::process($header);
	$footer = WebGUI::Macro::process($footer);
	return ($header, $footer);
}





1;
