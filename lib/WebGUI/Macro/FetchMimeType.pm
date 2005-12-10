package WebGUI::Macro::FetchMimeType; # edit this line to match your own macro name

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
use WebGUI::Session;
use LWP::MediaTypes qw(guess_media_type);

#-------------------------------------------------------------------
sub process {
	my $path = shift;
	return guess_media_type($path);
}

1;


