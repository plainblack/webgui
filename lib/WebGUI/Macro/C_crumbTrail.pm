package WebGUI::Macro::C_crumbTrail;

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
use Tie::CPHash;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _recurseCrumbTrail {
        my ($sth, %data, $output);
        tie %data, 'Tie::CPHash';
        %data = WebGUI::SQL->quickHash("select pageId,parentId,title,urlizedTitle from page where pageId=$_[0]");
        if ($data{pageId} > 1) {
                $output .= _recurseCrumbTrail($data{parentId});
        }
        if ($data{title} ne "") {
                $output .= '<a class="crumbTrail" href="'.$session{env}{SCRIPT_NAME}.'/'.$data{urlizedTitle}.'">'.$data{title}.'</a> &gt; ';
        }
        return $output;
}

#-------------------------------------------------------------------
sub _replacement {
        my (@param, $temp);
        $temp = '<span class="crumbTrail">'._recurseCrumbTrail($session{page}{parentId}).'<a href="'.$session{page}{url}.'">'.$session{page}{title}.'</a></span>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^C\;/_replacement()/ge;
        #---everything below this line will go away in a later rev.
	if ($output =~ /\^C/) {
        	$temp = '<span class="crumbTrail">'._recurseCrumbTrail($session{page}{parentId}).'<a href="'.$session{page}{url}.'">'.$session{page}{title}.'</a></span>';
        	$output =~ s/\^C/$temp/g;
	}
	return $output;
}

1;

