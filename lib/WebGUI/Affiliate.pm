package WebGUI::Affiliate;

=head1 LEGAL
                                                                                                                                                             
 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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

#-------------------------------------------------------------------
sub grabReferral {
	if ($session{user}{userId} != 1 && $session{user}{referringAffiliate} > 0) {
		return "";
	} elsif ($session{user}{userId} != 1 && $session{user}{referringAffiliate} == 0) {
		my $u = WebGUI::User->new($session{user}{userId});
		$u->referringAffiliate($session{scratch}{referringAffiliate});
		WebGUI::Session::deleteScratch("referringAffiliate");
	} elsif ($session{form}{affiliateId} ne "") {
		WebGUI::Session::setScratch("referringAffiliate",$session{form}{affiliateId});
	}
}

1;
