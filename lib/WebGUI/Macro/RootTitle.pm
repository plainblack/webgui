package WebGUI::Macro::RootTitle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Page;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my $root = WebGUI::Page->getWebGUIRoot;
	return $root->get("title");	
}


1;

