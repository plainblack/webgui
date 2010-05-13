package WebGUI::Friends;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Class::InsideOut qw(id register public readonly);
use WebGUI::DateTime;
use WebGUI::HTML;
use WebGUI::Inbox;
use WebGUI::International;
use WebGUI::User;
use WebGUI::Utility;

readonly session    => my %session;
readonly user       => my %user;

=head1 NAME

WebGUI::Friends

=head1 SYNOPSIS

my $friends = WebGUI::Friends->new($session, $user);

$friends->add(\@userIds);
$friends->remove(\@userIds);

=head1 DESCRIPTION

A user relationship management system.

=head1 METHODS

=cut


#-------------------------------------------------------------------

=head2 add ( \@userIds )

Add friends. Also adds the reciprocal relationship.

=head3 userIds

An array reference of userIds to add as friends.

=cut

sub add {
    my $self = shift;
    my $userIds = shift;
    my $me = $self->user;
    $me->friends->addUsers($userIds);
    foreach my $userId (@{$userIds}) {
        my $friend = WebGUI::User->new($self->session, $userId);
        $friend->friends->addUsers([$me->userId]);
    }
}

#-------------------------------------------------------------------

=head2 approveAddRequest ( inviteId ) 

Sends an approval, sets up the relationship, and deletes the invitation.

=head3 inviteId

The unique idenitifer for this invitation.

=cut

sub approveAddRequest {
    my $self = shift;
    my $inviteId = shift;
    my $db = $self->session->db;
    my $invite = $self->getAddRequest($inviteId);
    $self->add([$invite->{inviterId}]);
    my $i18n = WebGUI::International->new($self->session, "Friends");
    my $inbox = WebGUI::Inbox->new($self->session);
    $inbox->addMessage({
        message => sprintf($i18n->get("invitation accepted by user"), $self->user->getWholeName),
        subject => $i18n->get('friends invitation accepted'),
        userId  => $invite->{inviterId},
        status  => 'unread',
        sentBy  => $self->user->userId,
    });
    $inbox->getMessage($invite->{messageId})->setStatus('completed');
    $db->deleteRow("friendInvitations", "inviteId", $inviteId);
}


#-------------------------------------------------------------------

=head2 delete ( \@userIds )

Remove friends.  Also removes the reciprocal relationship.

=head3 userIds

An array reference of userIds to remove from friends list.

=cut

sub delete {
    my $self = shift;
    my $userIds = shift;
    my $me = $self->user;

    $me->friends->deleteUsers($userIds);
    foreach my $userId (@{$userIds}) {
        my $friend = WebGUI::User->new($self->session, $userId);
        $friend->friends->deleteUsers([$me->userId]);
    }
}

#-------------------------------------------------------------------

=head2 getAddRequest ( inviteId ) 

Returns the invitation data as a hash reference.

=cut

sub getAddRequest {
    my $self = shift;
    my $inviteId = shift;
    my $invite = $self->session->db->getRow('friendInvitations', 'inviteId', $inviteId);
}


#-------------------------------------------------------------------

=head2 getAllPendingAddRequests ( session )

Class method. Returns a WebGUI::SQL::ResultSet object with all the unanswered add requests.

=cut

sub getAllPendingAddRequests {
    my $class = shift;
    my $session = shift;
    return $session->db->read("select * from friendInvitations order by dateSent");
}


#-------------------------------------------------------------------

=head2 getNextInvitation ( invitation ) 

Returns the invitation that was sent to the user just after the invitation passed in.

=cut

sub getNextInvitation {
    my $self       = shift;
    my $invitation = shift;

    my $sql = q{
        select
            *
        from
            friendInvitations
        where
            friendId = ?
            and dateSent > ?
        order by dateSent asc
        limit 1
    };
    my $bindvars = [$self->user->userId,$invitation->{dateSent}];
    return $self->session->db->quickHashRef($sql,$bindvars);
}


#-------------------------------------------------------------------

=head2 getPreviousInvitation ( invitation ) 

Returns the invitation that was sent to the user just before the invitation passed in.

=cut

sub getPreviousInvitation {
    my $self       = shift;
    my $invitation = shift;

    my $sql = q{
        select
            *
        from
            friendInvitations
        where
            friendId = ?
            and dateSent < ?
        order by dateSent desc
        limit 1
    };
    my $bindvars = [$self->user->userId,$invitation->{dateSent}];
    return $self->session->db->quickHashRef($sql,$bindvars);
}

#-------------------------------------------------------------------

=head2 isFriend ( userId )

Returns a booelean indicating whether the userId is already a friend of this user.

=head3 userId

The userId to check against this user.

=cut

sub isFriend {
    my $self = shift;
    my $userId = shift;
    return isIn($userId, @{$self->user->friends->getUsers});    
}

#-------------------------------------------------------------------

=head2 isInvited ( userId )

Returns a booelean indicating whether the user has already been invited to the friends network.

=head3 userId

The userId to check against this user.

=cut

sub isInvited {
    my $self    = shift;
    my $session = $self->session;
    my $userId  = shift;
    
    my ($isInvited) = $session->db->quickArray(q{
        select
            count(*)
        from
            friendInvitations
        where
            inviterId = ?
            and friendId = ?
    },
    [$self->user->userId,$userId]);

    return $isInvited;    
}

#-------------------------------------------------------------------

=head2 new ( session, user )

Constructor.

=head3 session

A reference to the current WebGUI::Session object.

=head3 user

A reference to a WebGUI::User object that we're going to manage the friends of. Defaults to the current user
attached to the session.

=cut

sub new {
    my $class       = shift;
    my $session     = shift;
    my $user        = shift || $session->user;
    my $self        = register($class);
    $session{id $self} = $session;
    $user{id $self} = $user;
    return $self;
}

#-------------------------------------------------------------------

=head2 rejectAddRequest ( inviteId[,sendNotification] )

Sends a rejection notice, and deletes the invitation.

=head3 inviteId

The id of an invitation.

=head3 sendNotification

Boolean indicating whether or not to send out the deny notification.  Defaults to true

=cut

sub rejectAddRequest {
    my $self     = shift;
    my $inviteId = shift;
    my $notify   = shift;

    my $db = $self->session->db;
    my $invite = $self->getAddRequest($inviteId);
    my $i18n = WebGUI::International->new($self->session, "Friends");
    my $inbox = WebGUI::Inbox->new($self->session);
    
    unless (defined $notify && !$notify) {  #Notify is defined but not true
        $inbox->addMessage({
            message => sprintf($i18n->get("friends invitation not accepted by user"), $self->user->getWholeName),
            subject => $i18n->get('friends invitation not accepted'),
            userId  => $invite->{inviterId},
            status  => 'unread',
        });
    }
    $inbox->getMessage($invite->{messageId})->setStatus('completed');
    $self->session->db->deleteRow("friendInvitations", "inviteId", $inviteId);
}

#-------------------------------------------------------------------

=head2 sendAddRequest ( userId, message, inviteUrl )

Sends a request to another user to be added to this user's friends list. Returns an invitationId.

=head3 userId

The user to invite to be a friend.

=head3 message

The message to lure them to accept.

=head3 inviteUrl

The url to view the friend request

=cut

sub sendAddRequest {
    my $self       = shift;
    my $userId     = shift;
    my $comments   = shift;
    my $url        = $self->session->url;
    my $inviteUrl  = shift || $url->append($url->getSiteURL,'op=account');

    my $i18n = WebGUI::International->new($self->session, "Friends");

    # No sneaky attack paths...
    $comments = WebGUI::HTML::filter($comments);

    # Create the invitation url.
    my $inviteId = $self->session->id->generate();
    
    $inviteUrl = $url->append($inviteUrl,'inviteId='.$inviteId);

    # Build the message
    my $messageText = sprintf $i18n->get("invitation approval email"), $self->user->getWholeName, $self->session->url->getSiteURL, $comments, $inviteUrl;

    # send message
    my $message = WebGUI::Inbox->new($self->session)->addMessage({
        message => $messageText,
        subject => $i18n->get("friends network invitation"),
        userId  => $userId,
        status  => 'pending',
        sentBy  => $self->user->userId,
    });

    # Create the invitation record.
    $self->session->db->setRow(
        'friendInvitations',
        'inviteId',
        {
            inviterId   => $self->user->userId,
            friendId    => $userId,
            dateSent    => WebGUI::DateTime->new($self->session, time)->toMysql,
            comments    => $comments,
            messageId   => $message->getId,
        },
        $inviteId,
    );
    return $inviteId;
}

#-------------------------------------------------------------------

=head2 sendMessage ( subject, message, [ userIds ] )

=head3 subject

The subject of the message.

=head3 message

The message itself.

=head3 userIds

An array reference of userIds to send the message to. Defaults to all friends.

=cut

sub sendMessage {
    my $self = shift;
    my $subject = shift || "Untitled";
    my $message = shift;
    my $userIds = shift || $self->user->friends->getUsers;
    my $inbox = WebGUI::Inbox->new($self->session);
    my $myId = $self->user->userId;
    foreach my $userId (@{$userIds}) {
        $inbox->addPrivateMessage({
            message => $message,
            subject => $subject,
            userId  => $userId,
            sentBy  => $myId,
            status  => 'unread',
        });
    }
}

1;
