package WebGUI::Macro::File;

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
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
	my %var;
        if (my $collateral = WebGUI::Collateral->find($param[0])) {
               $var{'file.url'} = $collateral->getURL;
		$var{'file.icon'} = $collateral->getIcon;
	        $var{'file.name'} = $param[0];
                $var{'file.size'} = $collateral->getSize;
                $var{'file.thumbnail'} = $collateral->getThumbnail;
		return  WebGUI::Template::process(WebGUI::Template::getIdByName($param[1],"Macro/File"),"Macro/File", \%var);
        } else {
                return undef;
        }
}

1;


