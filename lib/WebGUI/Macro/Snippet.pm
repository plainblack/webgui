package WebGUI::Macro::Snippet;

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
use Tie::CPHash;
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
	if (my $collateral = WebGUI::Collateral->find($param[0])) {
		my $temp = $collateral->get("parameters");
               	for my $i ( 1 .. $#param ) {
                 	$temp =~ s/\^$i\;/$param[$i]/g;
                }
        	return $temp;
        } else {
                return undef;
        }
}


1;


