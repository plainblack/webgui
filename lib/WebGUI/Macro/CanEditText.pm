package WebGUI::Macro::CanEditText;

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

Package WebGUI::Macro::CanEditText

=head1 DESCRIPTION

Macro for displaying a message to a User who can edit the Asset
containing the Macro.  This macro should not be used outside
of an Asset as it will yield unpredictable results.

=head2 process ( text )

=head3 text

The text that will be shown to the user.  If the user cannot edit
this asset, an empty string will be returned.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my @param = @_;
	if ($session->asset && $session->asset->canEdit) { 
		return $param[0];
	} else {
		return "";
	}
}


1;


