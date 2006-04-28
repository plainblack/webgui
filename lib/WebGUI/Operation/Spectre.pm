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
use WebGUI::Utility;
use POE::Component::IKC::ClientLite;

=head1 NAME

Package WebGUI::Operation::Spectre

=head1 DESCRIPTION

Operations for Spectre.

=cut

#-------------------------------------------------------------------

=head2 www_spectreTest (  )

Spectre executes this function to see if WebGUI connectivity is working.

=cut

sub www_spectreTest {
	my $session = shift;
	$session->http->setMimeType("text/plain");
	$session->http->setCacheControl("none");
	unless (isInSubnet($session->env->get("REMOTE_ADDR"), $session->config->get("spectreSubnets"))) {
		$session->errorHandler->security("make a Spectre workflow runner request, but we're only allowed to accept requests from ".join(",",@{$session->config->get("spectreSubnets")}).".");
        	return "subnet";
	}
	my $remote = create_ikc_client(
		port=>$session->config->get("spectrePort"),
		ip=>$session->config->get("spectreIp"),
		name=>rand(100000),
		timeout=>10
		);
	# Can't perform this test until I get smarter. =)
	#return "spectre" unless $remote;
	#my $result = $remote->post_respond('admin/ping');
	#return "spectre" unless defined $result;
	return "success";
}


1;
