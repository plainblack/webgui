package WebGUI::Macro::RootTitle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	if (exists $session{asset}) {
		my $lineage = $session{asset}->get("lineage");
		$lineage = substr($lineage,0,6);
		my $root = WebGUI::Asset->newByLineage($lineage);
		if (defined $root) {
			return $root->get("title");	
		}
	}
	return "";
}


1;

