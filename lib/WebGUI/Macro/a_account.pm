package WebGUI::Macro::a_account;

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
use WebGUI::International;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---account link---
	if ($output =~ /\^a(.*)\^\/a/) {
        	$temp = '<a class="myAccountLink" href="'.$session{page}{url}.'?op=displayAccount">'.$1.'</a>';
                $output =~ s/\^a(.*)\^\/a/$temp/g;
	} elsif ($output =~ /\^a/) {
        	$temp = '<a class="myAccountLink" href="'.$session{page}{url}.'?op=displayAccount">'.WebGUI::International::get(46).'</a>';
        	$output =~ s/\^a/$temp/g;
	}
	return $output;
}

1;

