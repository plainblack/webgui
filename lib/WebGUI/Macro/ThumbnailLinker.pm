package WebGUI::Macro::ThumbnailLinker;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
	if (my $collateral = WebGUI::Collateral->find($param[0])) {
	        my $output = '<a href="'.$collateral->getURL.'"';
	        $output   .= ' target="_blank"' if ($param[1]);
	        $output   .= '><img src="' . $collateral->getThumbnail;
		$output   .= '" border="0"></a><br><b>'.$param[0].'</b><p>';
	        return $output;
        } else {
                return undef;
        }
}


1;


