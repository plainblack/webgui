package WebGUI::Operation::AdSpace.pm

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
use WebGUI::AdSpace;

=head1 NAME

Package WebGUI::Operation::AdSpace

=head1 DESCRIPTION

Operation handler for advertising functions.

=cut

#-------------------------------------------------------------------

=head2 www_clickAd ( )

Handles a click on an advertisement.

=cut

sub www_clickAd {
	my $session = shift;
	my $id = $session->form->param("adId");
	return undef unless $id;
	my $url = WebGUI::AdSpace->countClick($session, $id);
	$session->http->setRedirect($url);
	return "Redirecting to $url";
}



1;
