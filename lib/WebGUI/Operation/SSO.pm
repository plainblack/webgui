package WebGUI::Operation::SSO;

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

WebGUI::Operation::SSO

=head1 DESCRIPTION

TODO

=cut

#-------------------------------------------------------------------

=head2 www_ssoViaSessionId

TODO: DOCUMENT ME

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
				$session->end;
				$session->start($userId, $sessionId);
			}
		}
	}
	return undef;
}



1;
