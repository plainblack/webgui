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
	my ($header, $footer, @style, %style);
	if ($session{form}{makePrintable}) {
		%style = WebGUI::SQL->quickHash("select header,footer,styleSheet from style where styleId=3");
		$header = '<html><!-- WebGUI '.$session{wg}{version}.' -->'."\n";
		$header .= '<head><title>'.$session{page}{title}.'</title>';
		$header .= $style{styleSheet}.'</head>'.$style{header};
		$footer = $style{footer}.'</html>'; 
	} else {
		tie %style, 'Tie::CPHash';
		%style = WebGUI::SQL->quickHash("select header,footer,styleSheet from style where styleId=$session{page}{styleId}");
		$header = $session{setting}{docTypeDec}."\n".'<!-- WebGUI '.$WebGUI::VERSION.' -->
			<html>
			<head>
			<title>';
		if ($session{page}{pageId} == 1) {
			$header .= $session{setting}{companyName}.' - '.$session{page}{title};
		} else {
			$header .= $session{page}{title};
		}
		$header .= '</title>'
			.$style{styleSheet}
			.$session{page}{metaTags};
		if ($session{page}{defaultMetaTags}) {
			$header .= '<meta http-equiv="Keywords" name="Keywords" content="'.$session{page}{title}.', '.$session{setting}{companyName}.'">';
		}
		$header .= '</head>'.$style{header};
		$footer = $style{footer}.'
			</html>';
	}
	$header = WebGUI::Macro::process($header);
	$footer = WebGUI::Macro::process($footer);
	return ($header, $footer);
}




1;
