package WebGUI::Macro::AssetProxy;

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
use WebGUI::Asset;
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my ($url) = WebGUI::Macro::getParams(shift);
	my $asset = WebGUI::Asset->newByUrl($url);
	if (defined $asset) {
		return $asset->canView ? $asset->view : "";
	} else {
		return "Invalid Asset URL";
	}
}


1;


