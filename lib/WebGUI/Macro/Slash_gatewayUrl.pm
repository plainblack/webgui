package WebGUI::Macro::Slash_gatewayUrl;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::Slash_gatewayUrl

=head1 DESCRIPTION

Macro for returning the gateway URL (defined in the WebGUI config file) to the site.

=head2 process ( )

process is really a wrapper around $session->url->gateway();

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return $session->url->gateway();
}



1;

