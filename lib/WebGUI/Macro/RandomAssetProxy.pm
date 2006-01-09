package WebGUI::Macro::RandomAssetProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::RandomAssetProxy

=head1 DESCRIPTION

Macro for displaying a random asset.

=head2 process ( url )

=head3 url

The URL of an asset from the site.  A random asset will be chosen
from among that asset's children.  Error message will be returned
if no asset exists at that url, or if the asset has no children.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my $url = shift;
	my $asset = WebGUI::Asset->newByUrl($session, $url);
	if (defined $asset) {
		my $children = $asset->getLineage(["children"]);
		#randomize;
		srand;
		my $randomAssetId = $children->[rand(scalar(@{$children}))];	
		my $randomAsset = WebGUI::Asset->newByDynamicClass($session,$randomAssetId);
		if (defined $randomAsset) {
			$randomAsset->toggleToolbar;
			return $randomAsset->canView ? $randomAsset->view() : undef;
		} else {
			return WebGUI::International::get('childless','Macro_RandomAssetProxy');
		}
	} else {
		return WebGUI::International::get('invalid url','Macro_RandomAssetProxy');
	}
}


1;


