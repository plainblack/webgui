package WebGUI::Macro::Backslash_pageUrl;

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
  #---page url---
        if ($output =~ /\^\\/) {
                $output =~ s/\^\\/$session{page}{url}/g;
        }
	return $output;
}



1;
