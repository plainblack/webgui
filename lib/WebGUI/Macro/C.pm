package WebGUI::Macro::C;

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
use Tie::CPHash;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _recurseCrumbTrail {
        my ($sth, %data, $output);
        tie %data, 'Tie::CPHash';
        %data = WebGUI::SQL->quickHash("select pageId,parentId,title,urlizedTitle from page where pageId=$_[0]",$session
{dbh});
        if ($data{pageId} > 1) {
                $output .= _recurseCrumbTrail($data{parentId});
        }
        if ($data{title} ne "") {
                $output .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data{urlizedTitle}.'">'.$data{title}.'</a> &gt; '
;
        }
        return $output;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---crumb trail---
	if ($output =~ /\^C/) {
        	$temp = '<span class="crumbTrail">'._recurseCrumbTrail($session{page}{parentId}).'<a href="'.$session{page}{url}.'">'.$session{page}{title}.'</a></span>';
        	$output =~ s/\^C/$temp/g;
	}
	return $output;
}

1;

