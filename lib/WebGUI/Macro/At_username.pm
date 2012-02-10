package WebGUI::Macro::At_username;

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

Package WebGUI::Macro::At_username

=head1 DESCRIPTION

Macro for displaying the current User's username.

=head2 process

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return $session->user->username;
}



1;
