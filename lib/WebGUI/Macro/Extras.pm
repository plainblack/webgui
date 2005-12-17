package WebGUI::Macro::Extras;

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

=head1 NAME

Package WebGUI::Macro::Extras

=head1 DESCRIPTION

Macro for returning the extrasURL set up in the site's WebGUI.conf
file.
=head2 process

Returns the extrasURL.  A trailing slash '/' is appended to the URL.

=cut

#-------------------------------------------------------------------
sub process {
        return $session{config}{extrasURL}."/";
}

1;

