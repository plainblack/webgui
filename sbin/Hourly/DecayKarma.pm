package Hourly::DecayKarma;

my $minimumKarma = 0; # won't go below this number
my $decayFactor = 1; # amount to remove per hour

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
	WebGUI::SQL->write("update users set karma=karma-$decayFactor where karma>".$minimumKarma);
}

1;

