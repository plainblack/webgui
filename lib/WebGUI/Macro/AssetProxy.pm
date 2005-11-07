package WebGUI::Macro::AssetProxy;

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
use Time::HiRes;
use WebGUI::Asset;
use WebGUI::ErrorHandler;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my $url = shift;
	my $t = [Time::HiRes::gettimeofday()] if (WebGUI::ErrorHandler::canShowPerformanceIndicators());
	my $asset = WebGUI::Asset->newByUrl($url);
	#Sorry, you cannot proxy the notfound page.
	if (defined $asset && $asset->getId ne $session{setting}{notFoundPage}) {
		$asset->toggleToolbar;
		my $output = $asset->canView ? $asset->view : undef;
		$output .= "AssetProxy:".Time::HiRes::tv_interval($t) if (WebGUI::ErrorHandler::canShowPerformanceIndicators());
		return $output;
	} else {
		return "Invalid Asset URL";
	}
}


1;


