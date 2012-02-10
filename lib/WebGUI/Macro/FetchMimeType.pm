package WebGUI::Macro::FetchMimeType; # edit this line to match your own macro name

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
use LWP::MediaTypes qw(guess_media_type);

=head1 NAME

Package WebGUI::Macro::FetchMimeType

=head1 DESCRIPTION

Macro for determining the MIME type for a file.

=head2 process ( filepath )

Returns the MIME type for a file, as determined by
LWP::MediaTypes::guess_media_type.

=head3 filepath

A path to a file

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my $path = shift;
	return guess_media_type($path);
}

1;


