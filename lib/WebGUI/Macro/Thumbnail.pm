package WebGUI::Macro::Thumbnail;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::File::Image;

=head1 NAME

Package WebGUI::Macro::Thumbnail

=head1 DESCRIPTION

Macro for returning a thumbnail to an Image Asset.

=head2 process ( url )

=head3 url

A URL to the Image Asset whose thumbnail you want to display.  If no
Image Asset can be found with that URL, then undef will be returned.

=cut

#-------------------------------------------------------------------
sub process {
    my $session = shift;
    my $url     = shift;
    my $image   = eval { WebGUI::Asset::File::Image->newByUrl($session,$url) };
    if (Exception::Class->caught()) {
        return undef;
    }
    else {
        return $image->getThumbnailUrl;
    }
}


1;


