package WebGUI::Macro::t_topMenuHorizontal;

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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
  #---top menu horizontal---
	if ($output =~ /\^t/) {
        	$temp = '<span class="horizontalMenu">';
		$first = 1;
        	$sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId=1 order by sequenceNumber",$session{dbh});
        	while (@data = $sth->array) {
			if (WebGUI::Privilege::canViewPage($data[2])) {
				if ($first) {
					$first = 0;
				} else {
					$temp .= " &middot; ";
				}
                		$temp .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a>';
			}
        	}
        	$sth->finish;
        	$temp .= '</span>';
		$output =~ s/\^t/$temp/g;
	}
	return $output;
}

1;

