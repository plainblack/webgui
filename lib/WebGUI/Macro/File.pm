package WebGUI::Macro::File;

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
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
        if (my $collateral = WebGUI::Collateral->find($param[0])) {

                # include default icon unless a second param
                if ( ! $param[1] ) {
                        return '<a href="' . $collateral->getURL .
                                '"><img src="' . $collateral->getIcon .
                                '" align="middle" border="0" /> ' .
                                $collateral->get("name") . '</a>';

                # second param was flag, so no accompanying image
                } else {
                        return '<a href="' . $collateral->getURL .
                                '">' . $collateral->get("name") . '</a>';
                }
        } else {
                return undef;
        }
}

1;


