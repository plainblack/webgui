package WebGUI::Operation::Invite;

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
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Form;
use WebGUI::Mail::Send;
use WebGUI::Operation::Auth;

=head1 NAME

Package WebGUI::Operation::Invite

=head1 DESCRIPTION

DEPRECATED - This module is deprecated and should not be used in any new code.
Use WebGUI::Account::Inbox instead.

=cut

#-------------------------------------------------------------------

=head2 www_inviteUser ( )

DEPRECATED - This method is deprecated and should not be used in any new code.
Use WebGUI::Account::Inbox::inviteUser instead.

=cut

sub www_inviteUser {
	my $session = shift;
	my $instance = WebGUI::Content::Account->createInstance($session,"inbox");
    return $instance->displayContent($instance->callMethod("inviteUser"));
}

#-------------------------------------------------------------------

=head2 www_acceptInvite ( )

DEPRECATED - This method is deprecated and should not be used by any new code.

=cut

sub www_acceptInvite {
	my $session = shift;
    ##Send them right to auth.
    my $auth = WebGUI::Operation::Auth::getInstance($session);
    return $session->style->userStyle($auth->createAccount());
}

1;
