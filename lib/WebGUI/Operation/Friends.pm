package WebGUI::Operation::Friends;

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
use WebGUI::Content::Account;

=head1 NAME

Package WebGUI::Operation::Friends

=head1 DESCRIPTION

Operation handler for handling the friends network.

DEPRECATED - Do not use this package in new code.

=cut

#-------------------------------------------------------------------

=head2 www_addFriend ( )

DEPRECATED - See WebGUI::Account::Friends::sendFriendsRequest

=cut

sub www_addFriend {
	my $session = shift;
    my $uid      = $session->form->process("userId");
    my $instance = WebGUI::Content::Account->createInstance($session,"friends");
    return $instance->displayContent($instance->callMethod("sendFriendsRequest",[],$uid));
}


#-------------------------------------------------------------------

=head2 www_friendRequest ( )

DEPRECATED - See WebGUI::Account::Inbox::viewInvitation

=cut

sub www_friendRequest {
	my $session = shift;
    my $instance = WebGUI::Content::Account->createInstance($session,"inbox");
    return $instance->displayContent($instance->callMethod("viewInvitation"));
}

#-------------------------------------------------------------------

=head2 www_manageFriends ( )


DEPRECATED - See WebGUI::Account::Friends::view

=cut

sub www_manageFriends {
	my $session = shift;
    my $instance = WebGUI::Content::Account->createInstance($session,"friends");
    return $instance->displayContent($instance->callMethod("view"));
}

1;
