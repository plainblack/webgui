package WebGUI::Macro::p_previousMenuHorizontal;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @data, $sth, $first, @param, $delimeter);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[0] eq "") {
                $delimeter = " &middot; ";
        } else {
                $delimeter = " ".$param[0]." ";
        }
        $temp = '<span class="horizontalMenu">';
        $first = 1;
        $sth = WebGUI::SQL->read("select menuTitle,urlizedTitle,pageId from page where parentId=$session{page}{parentId} order by sequenceNumber");
        while (@data = $sth->array) {
        	if (WebGUI::Privilege::canViewPage($data[2])) {
                	if ($first) {
                        	$first = 0;
                        } else {
                                $temp .= $delimeter;
                        }
                        $temp .= '<a class="horizontalMenu" href="'.WebGUI::URL::gateway($data[1]).'">';
                        if ($session{page}{pageId} == $data[2]) {
                        	$temp .= '<span class="selectedMenuItem">'.$data[0].'</span>';
                        } else {
                                $temp .= $data[0];
                        }
			$temp .= '</a>';
                }
        }
        $sth->finish;
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
	$output =~ s/\^p\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^p\;/_replacement()/ge;
	return $output;
}

1;

