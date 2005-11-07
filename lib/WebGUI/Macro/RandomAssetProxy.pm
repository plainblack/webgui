package WebGUI::Macro::RandomAssetProxy;

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

#-------------------------------------------------------------------
sub process {
        my $url = shift;
	my $asset = WebGUI::Asset->newByUrl($url);
	if (defined $asset) {
		my $children = $asset->getLineage(["children"]);
		#randomize;
		srand;
		my $randomAssetId = $children->[rand(scalar(@{$children}))];	
		my $randomAsset = WebGUI::Asset->newByDynamicClass($randomAssetId);
		if (defined $randomAsset) {
			$randomAsset->toggleToolbar;
			return $randomAsset->canView ? $randomAsset->view() : undef;
		} else {
			return "Asset has no children.";
		}
	} else {
		return "Invalid asset URL.";
	}
}


1;


