package WebGUI::Macro::u_companyUrl;

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
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
        while ($output =~ /\^u(.*?)\;/) {
                $output =~ s/\^u(.*?)\;/$session{setting}{companyURL}/;
        }
        #---everything below this line will go away in a later rev.
        if ($output =~ /\^u/) {
                $output =~ s/\^u/$session{setting}{companyURL}/g;
        }
	return $output;
}

1;

