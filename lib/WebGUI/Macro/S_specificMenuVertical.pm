package WebGUI::Macro::S_specificMenuVertical;

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
use WebGUI::Macro::Shared;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _replacement {
        my ($temp, @param, @data);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[1] eq "") {
        	$param[1] = 0;
        }
        @data = WebGUI::SQL->quickArray("select pageId,title,urlizedTitle from page where urlizedTitle='$param[0]'",$session{dbh});
        $temp = '<span class="verticalMenu">';
        if (defined $data[0] && WebGUI::Privilege::canViewPage($data[0])) {
        	$temp .= traversePageTree($data[0],1,$param[1]);
        }
        $temp .= '</span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output,$temp, @param, @data);
        $output = $_[0];
        $output =~ s/\^S\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^S\;/_replacement()/ge;
        #---everything below this line will go away in a later rev.
	my ($pageTitle, $depth);
        if ($output =~ /\^S(.*)\^\/S/) {
		($pageTitle,$depth) = split(/,/,$1);
		if ($depth eq "") {
			$depth = 0;
		}
		@data = WebGUI::SQL->quickArray("select pageId,title,urlizedTitle from page where urlizedTitle='$pageTitle'",$session{dbh}); 
                $temp = '<span class="verticalMenu">';
		if (defined $data[0] && WebGUI::Privilege::canViewPage($data[0])) {
                	$temp .= traversePageTree($data[0],1,$depth);
		}
                $temp .= '</span>';
                $output =~ s/\^S(.*)\^\/S/$temp/g;
        }
	return $output;
}

1;

