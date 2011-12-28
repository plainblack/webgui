package WebGUI::Macro::URLEncode;

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

=head1 NAME

Package WebGUI::Macro::URLEncode

=head1 DESCRIPTION

Macro for URL encoding text.

=head2 process ( text )

process is really a wrapper around $session->url->escape;
of the account link.

=head3 text

The text to URL encode.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return $session->url->escape(shift);
}


1;

