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
use WebGUI::Macro;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        while ($output =~ /\^\*(.*?)\;/) {
                @param = WebGUI::Macro::getParams($1);
                if ($param[0] ne "") {
                	$temp = round(rand()*$1);
                } else {
                	$temp = round(rand()*1000000000);
                }
                $output =~ s/\^\*(.*?)\;/$temp/;
        }
        #---everything below this line will go away in a later rev.
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
