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

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---date---
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

