package Hourly::DecayKarma;

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
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	if ($session{config}{DecayKarma_minimumKarma} ne "" && $session{config}{DecayKarma_decayFactor}) {
		WebGUI::SQL->write("update users set karma=karma-".$session{config}{DecayKarma_decayFactor}
			." where karma > ".$session{config}{DecayKarma_minimumKarma});
	}
}

1;

