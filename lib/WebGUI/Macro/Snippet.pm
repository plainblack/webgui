package WebGUI::Macro::Snippet;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	($temp) = WebGUI::SQL->quickArray("select parameters from collateral where name=".quote($param[0]));
	return WebGUI::Macro::process($temp);
}


1;


