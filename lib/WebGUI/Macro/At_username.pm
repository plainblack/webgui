package WebGUI::Macro::At_username;

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
        while ($output =~ /\^\@(.*?)\;/) {
                $output =~ s/\^\@(.*?)\;/$session{user}{username}/;
        }
        #---everything below this line will go away in a later rev.
        if ($output =~ /\^\@/) {
                $output =~ s/\^\@/$session{user}{username}/g;
        }
	return $output;
}



1;
