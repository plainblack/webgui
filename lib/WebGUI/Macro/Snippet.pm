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
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my (@param, $temp);
        @param = WebGUI::Macro::getParams($_[0]);
	if (my $collateral = WebGUI::Collateral->find($param[0])) {
	        return $collateral->get("parameters");
        } else {
                return undef;
        }
}


1;


