package WebGUI::Macro::FileUrl;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::Storage;

#-------------------------------------------------------------------
sub process {
        my $url = shift;
	my $asset = WebGUI::Asset->newByUrl($url);
	if (defined $asset) {
		my $storage = WebGUI::Storage->get($asset->get("storageId"));
		return $storage->getUrl($asset->get("filename"));
	} else {
		return "Invalid Asset URL";
	}
}


1;


