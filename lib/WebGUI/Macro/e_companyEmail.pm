package WebGUI::Macro::e_companyEmail;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output);
	$output = $_[0];
  #---company email---
        if ($output =~ /\^e/) {
                $output =~ s/\^e/$session{setting}{companyEmail}/g;
        }
	return $output;
}

1;

