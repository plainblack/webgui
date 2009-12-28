package WebGUI::Macro::RandomAssetProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
	my $i18n = WebGUI::International->new($session,'Macro_RandomAssetProxy');
	my $asset = WebGUI::Asset->newByUrl($session, $url);
	if (defined $asset) {
		my $children = $asset->getLineage(["children"]);
		#randomize;
		my $randomAssetId = $children->[int(rand(scalar(@{$children})))];	
		my $randomAsset = WebGUI::Asset->newById($session,$randomAssetId);
		if (defined $randomAsset) {
			if ($randomAsset->canView) {
				$randomAsset->toggleToolbar;
				$randomAsset->prepareView;
				return $randomAsset->view;
			}
			return undef;
		} else {
			return $i18n->get('childless');
		}
	} else {
		return $i18n->get('invalid url');
	}
}


1;


