package WebGUI::Operation::Spectre;

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
use Crypt::Blowfish;
use JSON;

=head1 NAME

Package WebGUI::Operation::Spectre

=head1 DESCRIPTION

Operation handler for Spectre functions.

=cut

#-------------------------------------------------------------------

=head2 www_spectre ( )

Checks to ensure the requestor is who we think it is, and then executes a spectre function, and returns a data packet.

=cut

sub www_spectre {
	my $session = shift;
	return $session->privilege->insufficient unless (isInSubnet($session->env->get("REMOTE_ADDR"), $session->config->get("spectreSubnets")));
	my $cipher = Crypt::Blowfish->new($session->config->get("spectreCryptoKey"));
	my $payload = jsonToObj($cipher->decrypt($session->form->get("payload")));
	my $out = {};
	if ($payload->{do} eq "runWorkflow") {
		# do workflow stuff
	}
	return $cipher->encrypt(objToJson($out));
}



1;
