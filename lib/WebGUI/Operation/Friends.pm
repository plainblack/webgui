package WebGUI::Operation::Friends;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Form;
use WebGUI::Friends;
use WebGUI::User;
use WebGUI::International;
use WebGUI::Operation::Shared;

=head1 NAME

Package WebGUI::Operation::Friends

=head1 DESCRIPTION

Operation handler for handling the friends network.

=cut

#-------------------------------------------------------------------

=head2 www_addFriend ( )

Form for inviting a user to become your friend.

=cut

sub www_addFriend {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
    my $friendId = $session->form->get('userId');
    my $protoFriend = WebGUI::User->new($session, $friendId);

    my $i18n = WebGUI::International->new($session, 'Friends');

    # Check for non-existant user id.
    if ((!$protoFriend->username) || (!$protoFriend->profileField('ableToBeFriend'))) {
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('add to friends'),
            $i18n->get('does not want to be a friend'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $session->style->userStyle($output);
    }

    my $output = join '',
        sprintf("<h1>%s</h1>\n", $i18n->get('add to friends')),
        '<p>',
        sprintf($i18n->get('add to friends description'),
            $protoFriend->getWholeName),
        '</p>',
        WebGUI::Form::formHeader($session),
        WebGUI::Form::hidden($session,
            {
                name  => 'op',
                value => 'addFriendSave',
            }
        ),
        WebGUI::Form::hidden($session,
            {
                name  => 'friendId',
                value => $friendId,
            }
        ),
        WebGUI::Form::textarea($session,
            {
                name  => 'comments',
                value => sprintf($i18n->get('default friend comments'), $protoFriend->getFirstName, $session->user->getFirstName),
            }
        ),
        WebGUI::Form::Submit($session,
            {
                value => $i18n->get('add')
            }
        ),
        WebGUI::Form::Button($session,
            {
                value  => $i18n->get('cancel', 'WebGUI'),
                extras => q|onclick="history.go(-1);" class="backwardButton"|,
            }
        ),
        WebGUI::Form::formFooter($session),
    ;
   	return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_addFriendSave ( )

Post process the form, check for required fields, handle inviting users who are already
members (determined by email address) and send the email.

=cut

sub www_addFriendSave {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));

    my $friendId = $session->form->get('friendId');
    my $protoFriend = WebGUI::User->new($session, $friendId);
    my $i18n = WebGUI::International->new($session, 'Friends');

    # Check for non-existant user id.
    if ((!$protoFriend->username) || (!$protoFriend->profileField('ableToBeFriend'))) {
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('add to friends'),
            $i18n->get('does not want to be a friend'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $session->style->userStyle($output);
    }

    my $friends = WebGUI::Friends->new($session);
    $friends->sendAddRequest($friendId, $session->form->get('comments'));

    # display result
    my $output = sprintf(
        q!<h1>%s</h1><p>%s</p><p><a href="%s">%s</a></p><p><a href="%s">%s</a></p>!,
        $i18n->get('add to friends'),
        sprintf($i18n->get('add to friends confirmation'), $protoFriend->getWholeName),
        $session->url->append($session->url->getRequestedUrl, 'op=viewProfile;uid='.$friendId),
        sprintf($i18n->get('add to friends profile'), $protoFriend->getFirstName),
        $session->url->getBackToSiteURL(),
        $i18n->get('493', 'WebGUI'),
    );
    return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_friendRequest ( )

Form for the friend to accept or deny the request.

=cut

sub www_friendRequest {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));

    my $i18n = WebGUI::International->new($session, 'Friends');

    my $inviteId = $session->form->get('inviteId');
    my $friends = WebGUI::Friends->new($session);

    my $invitation = $friends->getAddRequest($inviteId);

    ##Invalid invite ID
    unless (exists $invitation->{friendId}) {  ##No userId corresponds to the inviteId
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('invalid invite code'),
            $i18n->get('invalid invite code message'),
            $session->url->page("op=viewInbox"),
            $i18n->get('354', 'WebGUI');
        return $session->style->userStyle($output);
    }

    ##Already a friend (check friendId already in the group)
    if ($friends->isFriend($invitation->{inviterId})) {
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('invalid invite code'),
            $i18n->get('already a friend'),
            $session->url->page("op=viewInbox"),
            $i18n->get('354', 'WebGUI');
        return $session->style->userStyle($output);
    }

    ##Someone else's invite (check friendId vs current userId).
    if ($session->user->userId ne $invitation->{friendId}) {  ##This isn't your invitation, dude.
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('invalid invite code'),
            $i18n->get('not the right user'),
            $session->url->page("op=viewInbox"),
            $i18n->get('354', 'WebGUI');
        return $session->style->userStyle($output);
    }

    ##Everything looks good.  Make the form!
    my $inviter = WebGUI::User->new($session, $invitation->{inviterId});
    my $output = join '',
        sprintf("<h1>%s</h1>\n", $i18n->get('friend request')),
        '<p>',
        sprintf($i18n->get('friend request description'),
            $inviter->getWholeName),
        '</p>',
        WebGUI::Form::formHeader($session),
        WebGUI::Form::hidden($session,
            {
                name  => 'op',
                value => 'friendRequestSave',
            }
        ),
        WebGUI::Form::hidden($session,
            {
                name  => 'inviteId',
                value => $inviteId,
            }
        ),
        WebGUI::Form::textarea($session,
            {
                name   => 'comments',
                value  => $invitation->{comments},
                extras => 'disabled=disabled',
            }
        ),
        WebGUI::Form::Submit($session, ##Approve
            {
                name   => 'doWhat',
                value  => $i18n->get('572', 'WebGUI'),
            }
        ),
        WebGUI::Form::Submit($session, ##Deny
            {
                name   => 'doWhat',
                value  => $i18n->get('574', 'WebGUI'),
            }
        ),
        WebGUI::Form::formFooter($session),
    ;
   	return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_friendRequestSave ( )

Handle form data from the friend's response to the invitation

=cut

sub www_friendRequestSave {
    my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));

    my $i18n = WebGUI::International->new($session, 'Friends');
    my $doWhat   = $session->form->get('doWhat');
    my $inviteId = $session->form->get('inviteId');
    my $friends = WebGUI::Friends->new($session);
    my $invite = $friends->getAddRequest($inviteId);
    my $inviter = WebGUI::User->new($session, $invite->{inviterId});
    ##Invalid invite ID
    if (!$invite->{inviterId}) {  ##No userId corresponds to the inviteId
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('invalid invite code'),
            $i18n->get('invalid invite code message'),
            $session->url->page("op=viewInbox"),
            $i18n->get('354', 'WebGUI');
        return $session->style->userStyle($output);
    }

    ##If deny, change the status of the request to denied.
    if ($doWhat ne $i18n->get('572', 'WebGUI')) { ##request denied
        $friends->rejectAddRequest($inviteId);
        ##Return screen that says they denied the request.
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('friend request'),
            sprintf($i18n->get('you have not been added'), $inviter->getWholeName),
            $session->url->page("op=viewInbox"),
            $i18n->get('354', 'WebGUI');
        return $session->style->userStyle($output);
    }

    ##If accepted,
    #   set the status to accepted.
    $friends->approveAddRequest($inviteId);

    # Return screen that says they accepted the request.
    my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
        $i18n->get('friend request'),
        sprintf($i18n->get('you have been added'), $inviter->getWholeName),
        $session->url->page("op=viewInbox"),
        $i18n->get('354', 'WebGUI');
    return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_manageFriends ( )

Display the list of friends and allow the user to remove friends or
send private messages to a subset of them.

=cut

sub www_manageFriends {
	my $session = shift;
    my ($user, $url, $style) = $session->quick(qw(user url style));
	return $session->privilege->insufficient() unless ($user->isInGroup(2));
    my $i18n = WebGUI::International->new($session, 'Friends');

    ##You have no friends!
    my $friends = $user->friends->getUsers;
    unless (scalar(@{$friends})) {  
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('my friends'),
            $i18n->get('no friends'),
            $url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $style->userStyle($output);
    }

    # show the friend manager
    my %var = (
        "account.options"   => WebGUI::Operation::Shared::accountOptions($session),
        formHeader          => WebGUI::Form::formHeader($session)
            . WebGUI::Form::hidden($session, { name  => 'op', value => 'sendMessageToFriends', }),
        removeFriendButton  => WebGUI::Form::button($session, { value  => $i18n->get('remove'), extras => q|onclick="confirmRemovalOfFriends(form);"|, }),
        subjectForm         => WebGUI::Form::text($session, { name=>"subject" }),
        sendMessageButton   => WebGUI::Form::Submit($session, { value  => $i18n->get('send message'), }),
        messageForm         => WebGUI::Form::textarea($session, { name=>"message" }),
        formFooter          => WebGUI::Form::formFooter($session),
        );
    foreach my $userId (@{ $friends}) {
        my $friend = WebGUI::User->new($session, $userId);
        push(@{$var{friends}}, {
            name            => $friend->getWholeName,
            profileUrl      => $url->append($url->getRequestedUrl, 'op=viewProfile;uid='.$userId),
            status          => ($friend->isOnline ? $i18n->get('online') : $i18n->get('offline')),
            checkboxForm    => WebGUI::Form::checkbox($session, { name  => 'userId', value => $userId, }),
            });
    }
    my $template = WebGUI::Asset->new(
        $session, 
        $session->setting->get("manageFriendsTemplateId"),
        "WebGUI::Asset::Template",
        );
   	return $style->userStyle($template->process(\%var));
}


#-------------------------------------------------------------------

=head2 www_removeFriends ()  

Removes friends from the current user's friends list.

=cut

sub www_removeFriends {
    my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
    my @users = $session->form->param("userId");
    WebGUI::Friends->new($session)->delete(\@users);
    return www_manageFriends($session);
}


#-------------------------------------------------------------------

=head2 www_sendMessageToFriends () 

Sends a message to selected friends.

=cut

sub www_sendMessageToFriends {
    my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
    my @users = $session->form->param("userId");
    my $friends = WebGUI::Friends->new($session);
    $friends->sendMessage($session->form->process("subject", "text"), $session->form->process("message","textarea"), \@users);
    return www_manageFriends($session);
}

1;
