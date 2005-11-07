package WebGUI::Macro::Thumbnail;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::File::Image;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my $url = shift;
	if (my $image = WebGUI::Asset::File::Image->newByUrl($url)) {
	        return $image->getThumbnailUrl;
        } else {
                return undef;
        }
}


1;


