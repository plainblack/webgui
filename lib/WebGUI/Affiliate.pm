package WebGUI::Affiliate;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::User;

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

=head2 grabReferral ( )

Grabs referral information out of the session and adds it to the user's
account if possible.

=cut

sub grabReferral {
	if ($session{user}{userId} ne "1" && $session{user}{referringAffiliate}) {
		return "";
	} elsif ($session{user}{userId} ne "1" && (($session{user}{referringAffiliate} eq "0" && $session{scratch}{referringAffiliate}) || $session{form}{affiliateId})) {
		my $u = WebGUI::User->new($session{user}{userId});
		$u->referringAffiliate($session{scratch}{referringAffiliate});
	} elsif ($session{user}{userId} != 1) {
		my $u = WebGUI::User->new($session{user}{userId});
		$u->referringAffiliate(1);
	} elsif ($session{form}{affiliateId} ne "") {
		WebGUI::Session::setScratch("referringAffiliate",$session{form}{affiliateId});
	}
}

1;
