package WebGUI::Macro::AdSpace;

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
use WebGUI::AdSpace;

=head1 NAME

Package WebGUI::Macro::AdSpace

=head1 DESCRIPTION

Macro for displaying ads from the ad management system in WebGUI.

=head2 process ( name )

=head3 name

The unique name of an Ad Space.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my $name = shift;
	if ($session->stow->get("cacheFixOverride")) {
		return "[AD:".$name."]";
	}
	my $adSpace = WebGUI::AdSpace->newByName($session, $name);
	return undef unless defined $adSpace;
	return $adSpace->displayImpression;
}

1;


