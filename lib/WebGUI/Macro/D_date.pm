package WebGUI::Macro::D_date;

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
use WebGUI::DateTime;
use WebGUI::Macro;

#-------------------------------------------------------------------
sub process {
        my ($output, $temp, @param);
        $output = $_[0];
        while ($output =~ /\^D(.*?)\;/) {
                @param = WebGUI::Macro::getParams($1);
                if ($param[0] ne "") {
                        $temp = epochToHuman(time(),$param[0]);
                } else {
                        $temp = localtime(time());
                }
                $output =~ s/\^D(.*?)\;/$temp/;
        }
        #---everything below this line will go away in a later rev.
	if ($output =~ /\^D(.*)\^\/D/) {
		$temp = epochToHuman(time(),$1);
		$output =~ s/\^D(.*)\^\/D/$temp/g;
	} elsif ($output =~ /\^D/) {
		$temp = localtime(time);
		$output =~ s/\^D/$temp/g;
	}
	return $output;
}

1;

