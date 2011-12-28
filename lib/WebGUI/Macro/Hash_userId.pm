package WebGUI::Macro::Hash_userId;

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

Package WebGUI::Macro::Hash_userId

=head1 DESCRIPTION

Macro for userId of the current user.

=head2 process

Returns the userId from the session object for the current user.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        return $session->user->userId;
}



1;
