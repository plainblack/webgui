package WebGUI::Macro::Carat_carat;

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

sub process {
	my ($output);
	$output = $_[0];
  #---carrot ^---
        if ($output =~ /\^\^/) {
                $output =~ s/\^\^/\^/g;
        }
	return $output;
}



1;
