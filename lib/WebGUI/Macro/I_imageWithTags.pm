package WebGUI::Macro::I_imageWithTags;

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
		my $tag = '<img src="'.$collateral->getURL.'" '.$collateral->get("parameters");
		unless ($tag =~ /alt\=/i) {
			$tag .= ' alt="'.$collateral->get("name").'"';
		}
		$tag .= ' />'; 
		return $tag;
	} else {
		return "";
	}
}


1;


