package WebGUI::URL;

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
use URI::Escape;
use WebGUI::Session;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub append {
	my ($url);
	$url = $_[0];
	if ($url =~ /\?/) {
		$url .= '&'.$_[1];
	} else {
		$url .= '?'.$_[1];
	}
	return $url;
}

#-------------------------------------------------------------------
sub escape {
	return uri_escape($_[0]);
}

#-------------------------------------------------------------------
sub gateway {
        my ($url);
        $url = $session{config}{scripturl}.'/'.$_[0];
	if ($_[1]) {
		$url = append($url,$_[1]);
	}
        if ($session{setting}{preventProxyCache} == 1) {
                $url = append($url,randint(0,1000).';'.time());
        }
        return $url;
}

#-------------------------------------------------------------------
sub page {
	my ($url);
	$url = $session{page}{url};
	if ($_[0]) {
		$url = append($url,$_[0]);
	}
	if ($session{setting}{preventProxyCache} == 1) {
		$url = append($url,randint(0,1000).';'.time());
	}
	return $url;
}

#-------------------------------------------------------------------
sub unescape {
	return uri_unescape($_[0]);
}

#-------------------------------------------------------------------
sub urlize {
	my ($title);
        $title = lc($_[0]);
        $title =~ s/ /_/g;
	$title =~ s/\.$//g;
        $title =~ s/[^a-z0-9\-\.\_]//g;
        return $title;
}


1;
