package WebGUI::Macro::SessionId;

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

Package WebGUI::Macro::SessionId

=head1 DESCRIPTION

A macro to return the ID of the user's current session.

=head2 process( )

Really just a wrapper around $session->getId;

=cut

sub process {
	my $session = shift;
	return $session->getId;
}


1;
