package WebGUI::Operation::Admin;

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
use WebGUI::AdminConsole;

=head1 NAME

Package WebGUI::Operation::Admin

=head1 DESCRIPTION

Operation handler for admin functions.

See also L<WebGUI::Content::Admin>, which handles C<op=admin> requests.

=cut

#-------------------------------------------------------------------

=head2 www_adminConsole ( )

If the current user is in the Turn On Admin Group, then return an Admin Console.

=cut

sub www_adminConsole {
	my $session = shift;
	return "" unless ($session->user->canUseAdminMode);
	my $ac = WebGUI::AdminConsole->new($session);
	return $ac->render;
}

#-------------------------------------------------------------------

=head2 www_switchOffAdmin ( )

If the current user is in the Turn On Admin Group, then allow them to turn off Admin mode
via WebGUI::Session::switchAdminOff()


=cut

sub www_switchOffAdmin {
	my $session = shift;
	return "" unless ($session->user->canUseAdminMode);
	$session->response->setCacheControl("none");
	$session->switchAdminOff();
	return "";
}

#-------------------------------------------------------------------

=head2 www_switchOnAdmin ( )

If the current user is in the Turn On Admin Group, then allow them to turn on Admin mode.

=cut

sub www_switchOnAdmin {
	my $session = shift;
	return "" unless ($session->user->canUseAdminMode);
	$session->response->setCacheControl("none");
	$session->switchAdminOn();
	return "";
}


1;
