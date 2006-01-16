package WebGUI::Macro::Page;

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

Package WebGUI::Macro::Page

=head1 DESCRIPTION

Macro for pulling information from the Asset in which it's embedded.

=head2 process ( property )

If the macro is called from outside of an Asset, or if there's no asset in
session variable, returns a single space.

=head3 property

The name of the property to retrieve from the assset via $session->asset->get()

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	if ($session->asset) {
		return $session->asset->get(shift);
	}
	return "";
}


1;


