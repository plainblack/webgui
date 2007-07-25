package WebGUI::Macro::User;

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

Package WebGUI::Macro::User

=head1 DESCRIPTION

Macro for displaying information from the current User's profile.

=head2 process( field )

process takes a single parameter, the name of a field in the current user's User Profile from
the data stored in $session .  If the field does not exist, undef is returned.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return  $session->user->profileField(shift);
}


1;


