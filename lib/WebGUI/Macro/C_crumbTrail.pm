package WebGUI::Macro::C_crumbTrail;

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
use Tie::CPHash;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _recurseCrumbTrail {
        my ($sth, %data, $output);
        tie %data, 'Tie::CPHash';
        %data = WebGUI::SQL->quickHash("select pageId,parentId,menuTitle,urlizedTitle from page where pageId=$_[0]");
        if ($data{pageId} > 1) {
                $output .= _recurseCrumbTrail($data{parentId},$_[1]);
        }
        if ($data{menuTitle} ne "") {
		$output .= '<a class="crumbTrail" href="'.WebGUI::URL::gateway($data{urlizedTitle})
			.'">'.$data{menuTitle}.'</a>'.$_[1];
        }
        return $output;
}

#-------------------------------------------------------------------
sub _replacement {
        my (@param, $temp, $delimeter);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[0] eq "") {
                $delimeter = " &gt; ";
        } else {
                $delimeter = " ".$param[0]." ";
        }
        $temp = '<span class="crumbTrail">'._recurseCrumbTrail($session{page}{parentId},$delimeter).
		'<a href="'.WebGUI::URL::page().'">'.$session{page}{menuTitle}.'</a></span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
	$output =~ s/\^C\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^C\;/_replacement()/ge;
	return $output;
}

1;

