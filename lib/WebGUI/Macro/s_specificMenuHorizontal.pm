package WebGUI::Macro::s_specificMenuHorizontal;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro::Shared;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @data, $pageTitle, $parentId, $sth, $first);
        $pageTitle = $1;
        $temp = '<span class="horizontalMenu">';
        $first = 1;
        ($parentId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='$pageTitle'");
        $sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId='$parentId' order by sequenceNumber");
        while (@data = $sth->array) {
        	if (WebGUI::Privilege::canViewPage($data[2])) {
                	if ($first) {
                        	$first = 0;
                        } else {
                                $temp .= " &middot; ";
                        }
                        $temp .= '<a class="horizontalMenu" href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a>';
                }
        }
        $sth->finish;
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output,@data, $pageTitle, $parentId, $sth, $first, $temp);
	$output = $_[0];
        $output =~ s/\^s\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^s\;/_replacement()/ge;
	return $output;
}

1;

