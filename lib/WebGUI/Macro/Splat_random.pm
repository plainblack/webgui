package WebGUI::Macro::Splat_random;

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
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---random number---
        if ($output =~ /\^\*(.*)\^\/\*/) {
                $temp = round(rand()*$1);
                $output =~ s/\^\*(.*)\^\/\*/$temp/g;
        } elsif ($output =~ /\^\*/) {
                $temp = round(rand()*1000000000);
                $output =~ s/\^\*/$temp/g;
        }
	return $output;
}



1;
