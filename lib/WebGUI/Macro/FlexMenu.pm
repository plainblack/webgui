package WebGUI::Macro::FlexMenu;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::URL;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @param);
        @param = WebGUI::Macro::getParams($_[0]);
        $temp = '<span class="verticalMenu">';
        $temp .= _reversePageTree($session{page}{pageId});
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub _reversePageTree {
        my ($sth, @data, $output, $parentId);
	($parentId) = WebGUI::SQL->quickArray("select parentId from page where pageId='$_[0]'");
        $sth = WebGUI::SQL->read("select pageId,parentId,menuTitle,urlizedTitle from page where parentId=$_[0] order by sequenceNumber");
        while (@data = $sth->array) {
		if (WebGUI::Privilege::canViewPage($data[0])) {
                	$output .= '<a class="verticalMenu" href="'.WebGUI::URL::gateway($data[3]).'">';
			if ($session{page}{pageId} == $data[0]) {
				$output .= '<span class="selectedMenuItem">'.$data[2].'</span>';
			} else {
				$output .= $data[2];
			}
			$output .= '</a><br>';
                	if ($_[1] == $data[0] && $_[2] ne "") {
        			$output .= '<table cellpadding=0 cellspacing=0 border=0 class="verticalMenu"><tr><td class="verticalMenu">&nbsp;&nbsp;&nbsp;</td><td class="verticalMenu">'.$_[2].'</td></tr></table>';
                	}
		}
        }
        $sth->finish;
        if ($parentId > 0) {
                $output = _reversePageTree($parentId,$_[0],$output);
        }
        return $output;
}

#-------------------------------------------------------------------
sub process {
        my ($output,$temp);
        $output = $_[0];
        #$output =~ s/\^FlexMenu\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^FlexMenu\;/_replacement()/ge;
	return $output;
}

1;

