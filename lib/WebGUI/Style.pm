package WebGUI::Style;

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
use Tie::CPHash;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub getStyle {
	my ($header, $footer, @style, %style, $styleId);
	tie %style, 'Tie::CPHash';
	if ($session{form}{makePrintable}) {
		$styleId = $session{form}{style} || 3;
		%style = WebGUI::SQL->quickHash("select header,footer,styleSheet from style where styleId=$styleId");
		$header = '<html><!-- WebGUI '.$session{wg}{version}.' -->'."\n";
		$header .= '<head><title>'.$session{page}{title}.' - '.$session{setting}{companyName}.'</title>';
		$header .= $style{styleSheet}.'</head>'.$style{header};
		$footer = $style{footer}.'</html>'; 
	} else {
		tie %style, 'Tie::CPHash';
		%style = WebGUI::SQL->quickHash("select header,footer,styleSheet from style where styleId=$session{page}{styleId}");
		$header = $session{setting}{docTypeDec}."\n".'<!-- WebGUI '.$WebGUI::VERSION.' -->
			<html>
			<head>
			<title>';
		$header .= $session{page}{title}.' - '.$session{setting}{companyName};
		$header .= '</title><link REL="icon" HREF="'.$session{setting}{lib}.'/favicon.png" TYPE="image/png">'
			.$style{styleSheet}
			.$session{page}{metaTags};
		if ($session{var}{adminOn}) {
			# This "triple incantation" panders to the delicate tastes of various browsers for reliable cache suppression.
			$header .= '<META HTTP-EQUIV="Pragma" CONTENT="no-cache">';
			$header .= '<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate, max_age=0">';
			$header .= '<META HTTP-EQUIV="Expires" CONTENT="0">';
		}
		if ($session{page}{defaultMetaTags}) {
			$header .= '<meta http-equiv="Keywords" name="Keywords" content="'.
				$session{page}{title}.', '.$session{setting}{companyName}.'">';
			$header .= '<meta http-equiv="Description" name="Description" content="'.
				$session{page}{synopsis}.'">';

		}
		$header .= '</head>'.$style{header};
		$footer = $style{footer}.' </html>';
	}
	$header = WebGUI::Macro::process($header);
	$footer = WebGUI::Macro::process($footer);
	return ($header, $footer);
}




1;
