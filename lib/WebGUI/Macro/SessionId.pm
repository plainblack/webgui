package WebGUI::Macro::SessionId;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

Returns the current user's session Id.

=cut

sub process {
	my $session = shift;
	return $session->getId;
}


1;
