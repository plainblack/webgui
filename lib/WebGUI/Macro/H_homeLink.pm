package WebGUI::Macro::H_homeLink;

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
use WebGUI::Asset::Template;
use WebGUI::International;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my ($label, $templateUrl) = @_;
	my $home = WebGUI::Asset->getDefault;
	if ($label ne "linkonly") {
		my %var;
       		$var{'homelink.url'} = $home->getUrl;
       		if ($label ne "") {
               		$var{'homeLink.text'} = $label;
       		} else {
               		$var{'homeLink.text'} = WebGUI::International::get(47,'Macro_H_homeLink');
       		}
		if ($templateUrl) {
         		return WebGUI::Asset::Template->newByUrl($templateUrl)->process(\%var);
		} else {
         		return WebGUI::Asset::Template->new("PBtmpl0000000000000042")->process(\%var);
		}
	}
	return $home->getUrl;
}


1;

