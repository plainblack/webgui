package WebGUI::Operation::Admin;

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
use WebGUI::AdminConsole;

=head1 NAME

Package WebGUI::Operation::Admin

=head1 DESCRIPTION

Operation handler for admin functions

=cut

#-------------------------------------------------------------------

=head2 www_adminConsole ( )

If the current user is in the Turn On Admin Group, then return an Admin Console.

=cut

sub www_adminConsole {
	my $session = shift;
	return "" unless ($session->user->isInGroup(12));
	my $ac = WebGUI::AdminConsole->new($session);
	return $ac->render;
}

#-------------------------------------------------------------------

=head2 www_switchOffAdmin ( )

If the current user is in the Turn On Admin Group, then allow them to turn off Admin mode
via WebGUI::Session::Var::switchAdminOff()


=cut

sub www_switchOffAdmin {
	my $session = shift;
	return "" unless ($session->user->isInGroup(12));
	$session->var->switchAdminOff();
	return "";
}

#-------------------------------------------------------------------

=head2 www_adminConsole ( )

If the current user is in the Turn On Admin Group, then allow them to turn on Admin mode.

=cut

sub www_switchOnAdmin {
	my $session = shift;
	return "" unless ($session->user->isInGroup(12));
	$session->var->switchAdminOn();
	return "";
}


1;
