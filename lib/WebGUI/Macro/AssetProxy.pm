package WebGUI::Macro::AssetProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Time::HiRes;
use WebGUI::Asset;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::AssetProxy

=head1 DESCRIPTION

Macro for displaying the output of an Asset in another location.

=head2 process ( url | assetId, [ type ] )

=head3 url | assetId

My specify either the asset url or the asset id. If no Asset with that URL or id can be found, an internationalized error message will be returned instead.

No editing controls (toolbar) will be displayed in the Asset output, even if Admin is turned on.

The Not Found Page may not be Asset Proxied.

=head3 type

Defaults to 'url'. But if you want to use an assetId as the first parameter, then this parameter must be 'assetId'.

=cut

#-------------------------------------------------------------------
sub process {
    my ($session, $identifier, $type) = @_;
	my $t = ($session->errorHandler->canShowPerformanceIndicators()) ? [Time::HiRes::gettimeofday()] : undef;
	my $asset;
    if ($type eq 'assetId') {
        $asset = WebGUI::Asset->newByDynamicClass($session, $identifier);
    }
    else {
        $asset = WebGUI::Asset->newByUrl($session,$identifier);
    }
	#Sorry, you cannot proxy the notfound page.
	if (defined $asset && $asset->getId ne $session->setting->get("notFoundPage")) {
		if ($asset->canView) {
			$asset->toggleToolbar;
			$asset->prepareView;
			my $output = $asset->view;
			$output .= "AssetProxy:".Time::HiRes::tv_interval($t) if ($session->errorHandler->canShowPerformanceIndicators());
			return $output;
		}
		return undef;
	} 
    else {
		my $i18n = WebGUI::International->new($session, 'Macro_AssetProxy');
		return $i18n->get('invalid url');
	}
}


1;


