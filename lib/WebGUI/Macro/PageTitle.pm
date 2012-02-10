package WebGUI::Macro::PageTitle;

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

Package WebGUI::Macro::PageTitle

=head1 DESCRIPTION

Macro for returning the title of the current Asset.

=head2 process ( )

Returns the title of the current Asset.  If a WebGUI operation or function
is active, then the title is returned as a link to the Asset.  If there is
no asset cached in the session object, undef is returned.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	if ($session->asset) {
		if ($session->form->process("op") || $session->form->process("func")) {
	        	return '<a href="'.$session->asset->getUrl.'">'.$session->asset->get("title").'</a>';
		} else {
			return $session->asset->get("title");
		}
	}
}


1;

