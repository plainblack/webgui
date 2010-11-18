package WebGUI::Macro::AdminText;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::AdminText

=head1 DESCRIPTION

Macro for displaying a text message to user's with Admin turned on.

=head2 process ( [text] )

=head3 text

The text to be displayed to the user.  If the user is not in Admin mode the empty
string is returned.

=cut

#-------------------------------------------------------------------
sub process {	
	my $session = shift;
        my @param = @_;
        return "" unless ($session->isAdminOn);
        return $param[0];
}


1;

