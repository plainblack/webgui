package WebGUI::Affiliate;

use strict;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

=head1 NAME

Package WebGUI::Affiliate

=head1 DESCRIPTION

Tracks where users come from.

B<NOTE:> This package is experimental as is not officially supported yet.

=head1 SYNOPSIS

 use WebGUI::Affiliate;
 WebGUI::Affiliate::grabReferral();

=head1 FUNCTIONS

These functions are available from this package:

=cut
                                                                                                                                                             

#-------------------------------------------------------------------

=head2 grabReferral ( session )

Grabs referral information out of the session and adds it to the user's account if possible.

=head2 session

A reference to the current session.

=cut

sub grabReferral {
	my $session = shift;
	if ($session->user->isRegistered && $session->user->referringAffiliate) {
		return "";
	} elsif ($session->user->isRegistered && (($session->user->referringAffiliate eq "0" && $session->form->process("referringAffiliate")) || $session->form->process("affiliateId"))) {
		$session->user->referringAffiliate($session->scratch->get("referringAffiliate"));
	} elsif ($session->user->isRegistered) {
		$session->user->referringAffiliate(1);
	} elsif ($session->form->process("affiliateId") ne "") {
		$session->scratch->set("referringAffiliate",$session->form->process("affiliateId"));
	}
}

1;
