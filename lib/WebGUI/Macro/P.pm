package WebGUI::Macro::P;

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
	my ($output, $temp, @data, $sth);
	$output = $_[0];
  #---previous menu vertical---
        if ($output =~ /\^P/) {
                $temp = '<span class="verticalMenu">';
                $sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId=$session{page}{parentId} order by sequenceNumber",$session{dbh});
                while (@data = $sth->array) {
                        if (WebGUI::Privilege::canViewPage($data[2])) {
                                $temp .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a><br>';
                        }
                }
                $sth->finish;
                $temp .= '</span>';
                $output =~ s/\^P/$temp/g;
        }
	return $output;
}

1;

