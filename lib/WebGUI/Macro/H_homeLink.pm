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
use WebGUI::Asset::Template;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
        my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	if ($session{setting}{defaultPage} eq $session{page}{pageId}) {
		$temp = $session{page}{urlizedTitle};
	} else {
		($temp) = WebGUI::SQL->quickArray("select url from asset where assetId=".quote($session{setting}{defaultPage}),WebGUI::SQL->getSlave);
	}
	$temp = WebGUI::URL::gateway($temp);
	if ($param[0] ne "linkonly") {
		my %var;
       		$var{'homelink.url'} = $temp;
       		if ($param[0] ne "") {
               		$var{'homeLink.text'} = $param[0];
       		} else {
               		$var{'homeLink.text'} = WebGUI::International::get(47);
       		}
		if (defined $param[1]) {
        		$temp =  WebGUI::Asset::Template->newByUrl($param[1])->process(\%var);
		} else {
			$temp = WebGUI::Asset::Template->new("PBtmpl0000000000000042")->process(\%var);
		}
	}
	return $temp;
}


1;

