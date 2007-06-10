package WebGUI::Operation::SSO;

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

Package WebGUI::Operation::Admin

=head1 DESCRIPTION

Operation handler for admin functions

=cut

#-------------------------------------------------------------------

=head2 www_switchOffAdmin ( )

If the current user is in the Turn On Admin Group, then allow them to turn off Admin mode
via WebGUI::Session::Var::switchAdminOff()


=cut

sub www_ssoViaSessionId {
	my $session = shift;
	my $sessionId = $session->form->get("sessionId");
	if (defined $sessionId && $sessionId ne "") {
		if ($sessionId eq $session->getId) {
			# we're already the correct session
		}
		else {
			my ($userId) = $session->db->quickArray("select userId from userSession where sessionId=?",[$sessionId]);
			if (defined $userId && $userId ne "") {
				$session->var->end;
				$session->var->start($userId, $sessionId);
			}
		}
	}
	return undef;
}



1;
