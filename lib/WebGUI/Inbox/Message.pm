package WebGUI::Inbox::Message;

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
use WebGUI::Mail::Send;
use WebGUI::International;

=head1 NAME

Package WebGUI::Inbox::Message;

=head1 DESCRIPTION

This package provides an API for working with inbox messages.

=head1 SYNOPSIS

 use WebGUI::Inbox::Message;

 my $message = WebGUI::Inbox::Message->new($session, $messageId);

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 create ( session, properties ) 

Creates a new message.

=head2 session

A reference to the current session.

=head3 properties

A hash reference containing the properties to update. 

=head4 message

The content of this message.

=head4 subject

The topic of this message. Defaults to 'Notification'.

=head4 status

May be "unread", "pending", or "completed". Defaults to "pending".

You should set this to "pending" if the message requires an action which will later be completed.

WebGUI::Inbox::Message->create( $session, { status => "pending"} )

You should set this to "unread" if this is a message without an action, such as a notification.

WebGUI::Inbox::Message->create( $session, { status => "unread" } );

You should only set this to "completed" if this is an action that would normally be "pending" but for some reason
requries no further action.  For instance, if the user submitting some content is also the approver you may choose
to simply set the status immediately to completed.

=head4 userId

A userId of a user attached to this message.

=head4 groupId

A groupId of a group attached to this message.

=head4 sentBy

A userId that created this message. Defaults to '3' (Admin).

=head4 emailMessage

Email message to use rather than inbox message contents.

=head4 emailSubject

Email subject to use rather than inbox message subject.

=head4 smsMessage

SMS notification message to send to C<smsAddress>

=head4 smsSubject

SMS notification subject (typically used for SMS Gateway authentication)

=head4 smsAddress

Email address that SMS notification is sent to (typically the user's C<cellPhone> C<@> C<smsGateway>)

=head3 options

A hash reference containing options for handling the message. 

=head4 no_email 

If no_email is true, then no email will be made or sent.  Only
the inbox message will be made.

=head4 no_sms

If no_sms is true, then no attempt to sms notifications will be sent.

=head4 overridePerUserDelivery

If true, then the C<isInbox> flag will not be passed to L<WebGUI::Mail::Send::Create>, and thus the
per-user settings for email delivery will not be used. Useful if you want to force this message to
be sent as an Email rather than allowing the user's C<receiveInboxEmailNotifications> setting to
take effect.

=head4 extraHeaders

A hash ref containing extra header information to send to WebGUI::Message::create valid headers include:
cc, bcc, replyTo, returnPath, contentType, messageId, and inReplyTo.  See WebGUI::Message::create for more details.

=cut

sub create {
    my $class      = shift;
    my $session    = shift;
    my $properties = shift;
    my $options    = shift || {};
	my $self = {};
    my $i18n = WebGUI::International->new($session);
	$self->{_properties}{messageId} = "new";
	$self->{_properties}{status}    = $properties->{status} || "pending";
	$self->{_properties}{subject}   = $properties->{subject} || $i18n->get(523,'WebGUI');
	$self->{_properties}{message}   = $properties->{message};
	$self->{_properties}{dateStamp} = time();
	$self->{_properties}{userId}    = $properties->{userId};
	$self->{_properties}{groupId}   = $properties->{groupId};
    $self->{_properties}{sentBy}    = $properties->{sentBy} || 3;
        unless ( $self->{_properties}{userId} || $self->{_properties}{groupId} ) {
             $self->{_properties}{userId} = $session->user->userId;
         }
    my $status = $self->{_properties}{status};
    my $smsMessage = $properties->{smsMessage};
    my $smsSubject = $properties->{smsSubject};
    my $smsAddress = $properties->{smsAddress};
    
	if ($status eq "completed") {
		$self->{_properties}{completedBy} = $session->user->userId;
		$self->{_properties}{completedOn} = time();
	}
    elsif($status ne "pending") {
        $self->{_properties}{status} = "active";
    }

	$self->{_messageId} = $self->{_properties}{messageId} = $session->db->setRow("inbox","messageId",$self->{_properties});
    $self->{_userId   } = $self->{_properties}{userId};
    $self->{_inbox    } = $self->{_properties};

    #Add the message state row for individual user passed in
    if($self->{_properties}{userId}) {
        $session->db->write(
            q{ REPLACE INTO inbox_messageState (messageId,userId) VALUES (?,?) },
            [$self->{_messageId},$self->{_properties}{userId}]
        );
    }
    #Add the message state row for every user in the group
    if($self->{_properties}{groupId}) {
        my $g     = WebGUI::Group->new($session,$self->{_properties}{groupId});
        my $users = $g->getAllUsers;
        foreach my $userId (@{$users}) {
            $session->db->write(
                q{ REPLACE INTO inbox_messageState (messageId,userId) VALUES (?,?) },
                [$self->{_messageId},$userId]
            );
        }
    }
    unless ( $options->{ no_email } ) {
        my $subject = (defined $properties->{emailSubject}) ? $properties->{emailSubject} : $self->{_properties}{subject};
        #Set default mail headers
        my $mailHeaders = {
           toUser=>$self->{_properties}{userId},
           toGroup=>$self->{_properties}{groupId},
           subject=>$subject,
        };
        #Add extraHeaders if they are passsed in as options
        if($options->{ extraHeaders } && ref $options->{ extraHeaders } eq 'HASH') {
           %{$mailHeaders} = (%{$mailHeaders},%{$options->{ extraHeaders }});
        }
        #Get inbox override flag
        my $overridePerUserDelivery = $options->{overridePerUserDelivery} ? undef : 'isInbox';
        #Create the mail message
        my $mail = WebGUI::Mail::Send->create($session,$mailHeaders,$overridePerUserDelivery);

        my $preface = "";
        my $fromUser = WebGUI::User->new($session, $properties->{sentBy});
        #Don't append prefaces to the visitor users or messages that don't specify a user (default case)
        unless ($fromUser->isVisitor || $fromUser->userId eq 3) {  #Can't use isAdmin because it will not send prefaces from normal users who in the admin group
            $preface = sprintf($i18n->get('from user preface', 'Inbox_Message'), $fromUser->username);
        }
        my $msg = (defined $properties->{emailMessage}) ? $properties->{emailMessage} : $self->{_properties}{message};
		$msg = '<p>' . $preface . '</p><br />'.$msg if($preface ne "");
        $mail->addHtml($msg);
        $mail->addFooter;
		$mail->queue;
    }
    
    unless ( $options->{ no_sms } ) {
        # If smsAddress provided, send smsMessage too
        if ( $smsAddress && $smsMessage) {
            my $sms = WebGUI::Mail::Send->create(
                $session,
                {   to      => $smsAddress,
                    subject => $smsSubject,
                }
            );
            if ($sms) {
                $sms->addText($smsMessage);
                $sms->queue;
            }
        }
    }
	
	$self->{_session} = $session;
	bless $self, $class;
}

#-------------------------------------------------------------------

=head2 delete ( userId )

Deletes this message from the inbox for the user passed in

=head3 userId

User to delete message for.  If no user is passed in, the current user will be used.

=cut

sub delete {
	my $self      = shift;
    my $session   = $self->session;
    my $db        = $session->db;
    my $messageId = $self->getId;
    my $userId    = shift || $self->{_userId};

    $self->setDeleted($userId);

    my $isActive  = $db->quickScalar(
        q{ select count(*) from inbox_messageState where messageId=? and deleted=0 },
        [$messageId]
    );
    #Delete the message from the database if everyone who was sent the message has deleted it
    unless ($isActive) {
        $self->purge;
    }
}

#-------------------------------------------------------------------

=head2 get ( property ) 

Returns the value of a property.

=head3 property

The name of any property of an inbox message. See create() for details. In addition to those settable by create, you may also retrieve these:

=head4 dateStamp

The date the message was created.

=head4 completedBy

The userId of the user that completed the action associated with this message.

=head4 completedOn

An epoch date representing when the action associated with this message was completed.

=cut

sub get {
	my $self = shift;
	my $name = shift;

    if($name eq "status") {
        my $status  = $self->{_properties}{status};
        if($status eq "active") {
            return "read"    if($self->{_properties}{isRead});
            return "replied" if($self->{_properties}{repliedTo});
            return "unread";
        }
        return $status;
    }

	return $self->{_properties}{$name};
}


#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this message.

=cut

sub getId {
	my $self = shift;
	return $self->{_messageId};
}


#-------------------------------------------------------------------

=head2 getStatus ( [ userId ] ) 

Gets the current status of the message for the user passed in

=head3 userId

The id of the user to get the status of the message for.  Defaults to the current user.

=cut

sub getStatus {
	my $self   = shift;
	my $userId = shift || $self->{_userId};

    my $status      = $self->{_properties}{status};
    my $statusCodes = $self->statusCodes;
    
    if($status eq "active") {
        return $statusCodes->{"replied"} if($self->{_properties}{repliedTo});
        return $statusCodes->{"read"   } if($self->{_properties}{isRead});
        return $statusCodes->{"unread" };
    }

    return $statusCodes->{$self->get("status")};
}

#-------------------------------------------------------------------

=head2 isRead ( ) 

Returns whether or not the message has been read.

=cut

sub isRead {
	my $self   = shift;
    return $self->{_properties}{isRead};
}

#-------------------------------------------------------------------

=head2 isValidStatus ( status ) 

Returns whether or not the status passed in is valid.  Can be called as a class or instance method

=head4 status

The id of the user that replied to this message. Defaults to the current user.

=cut

sub isValidStatus {
	my $self   = shift;
    my $status = shift;
    return (exists $self->statusCodes->{$status});
}

#-------------------------------------------------------------------

=head2 new ( session, messageId )

Constructor used to access existing messages.  Use create for making
new messages.

=head3 session

A reference to the current session.

=head3 messageId

The unique id of a message.

=head3 userId

The userId for this message.  Defaults to the current user.

=cut

sub new {
	my $class     = shift;
	my $session   = shift;
	my $messageId = shift;
    my $userId    = shift || $session->user->userId;
    
    #Don't bother going on if a messageId wasn't passed in
    return undef unless $messageId;

    my $inbox = $session->db->getRow("inbox","messageId",$messageId);
    my $statusValues = $session->db->quickHashRef(
        q{ select isRead, repliedTo, deleted from inbox_messageState where messageId=? and userId=? },
        [$messageId,$userId]
    );

    #Don't return messages that don't exist
    return undef unless (scalar(keys %{$inbox}));

    #Don't return deleted messages
    return undef if($statusValues->{deleted});

    my $self       = {};

    my %properties  = (%{$inbox},%{$statusValues});
 
	bless {_properties=>\%properties, _inbox=>$inbox, _session=>$session, _messageId=>$messageId, _userId=>$userId}, $class;
}

#-------------------------------------------------------------------

=head2 purge

Completely deletes a message from the inbox.

=cut

sub purge {
	my $self = shift;
    my $db   = $self->session->db;
    my $messageId = $self->getId;
    $db->write("delete from inbox where messageId=?",[$messageId]);
    $db->write("delete from inbox_messageState where messageId=?",[$messageId]);
}

#-------------------------------------------------------------------

=head2 session

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setCompleted ( [ userId ] ) 

Marks a message completed.

=head4 userId

The id of the user that completed this task. Defaults to the current user.

=cut

sub setCompleted {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	$self->{_properties}{status}      = "completed";
	$self->{_properties}{completedBy} = $userId;
	$self->{_properties}{completedOn} = time();
    $self->{_inbox}{status}           = "completed";
    $self->{_inbox}{completedBy}      = $userId;
    $self->{_inbox}{completedOn}      = time();
	$self->session->db->setRow("inbox","messageId",$self->{_inbox});
    #Completed messages should also be marked read for all users connected to this message
    $self->setReadAll;
}

#-------------------------------------------------------------------

=head2 setDeleted ( [ userId ] ) 

Marks a message deleted.

=head4 userId

The id of the user that deleted this message. Defaults to the current user.

=cut

sub setDeleted {
	my $self   = shift;
	my $userId = shift || $self->session->user->userId;

    $self->session->db->write(
        q{update inbox_messageState set deleted=1 where messageId=? and userId=?},
        [$self->getId,$userId]
    );
}

#-------------------------------------------------------------------

=head2 setRead ( [ userId ] ) 

Marks a message read.

=head4 userId

The id of the user that reads this message. Defaults to the current user.

=cut

sub setRead {
	my $self   = shift;
	my $userId = shift || $self->session->user->userId;

    $self->session->db->write(
        q{update inbox_messageState set isRead=1 where messageId=? and userId=?},
        [$self->getId,$userId]
    );
}

#-------------------------------------------------------------------

=head2 setReadAll ( ) 

Marks a message read for all users who are connected to this message

=cut

sub setReadAll {
	my $self   = shift;

    $self->session->db->write(
        q{update inbox_messageState set isRead=1 where messageId=?},
        [$self->getId]
    );
}

#-------------------------------------------------------------------

=head2 setReplied ( [ userId ] ) 

Marks a message replied.

=head4 userId

The id of the user that replied to this message. Defaults to the current user.

=cut

sub setReplied {
	my $self   = shift;
	my $userId = shift || $self->session->user->userId;

    $self->session->db->write(
        q{update inbox_messageState set repliedTo=1, isRead=1 where messageId=? and userId=?},
        [$self->getId,$userId]
    );
}


#-------------------------------------------------------------------

=head2 setStatus ( status,[ userId ] ) 

Sets the current status of the message

There are two levels of status for any inbox message:

Global Message Status - This is the status of the entire message and holds true for everyone who received the message.  These status values are as follows:

pending - indicates that there is some action for one of the users who received this message to act on.
active  - indicates that this is a message that requires no action by any users who received this message.
completed - indicates that the action that was required is now completed.

Individual Message Status - This is the status of the message for each individual who received it.  If you send a message to a group, each person who received the message will be able to see the message in one of the following states:

unread  - indicates that this message has not be read by the current user
read    - indicates that this message has been read by the current user
replied - indicates that the user has replied to this message

It is important to note that there is one more status not listed here which is deleted.  This is a special state which cannot be set through this method.  You should use the setDeleted method in this class if you wish to delete a message for a user. 

=head4 status

Status to mark the message

=head4 userId

The id of the user that completed this task. Defaults to the current user.

=cut

sub setStatus {
	my $self    = shift;
    my $status  = shift;
    my $session = $self->session;
	my $userId  = shift || $session->user->userId;
	unless ($status) {
        $session->log->warn("No status passed in for message.  Exit without update");
        return undef;
    }

    unless($self->isValidStatus($status)) {
        $self->session->log->warn("Invalid status $status passed in for message.  Exit without update");
        return undef;
    }

    if($status eq "completed") {
        $self->setCompleted($userId);
        return undef;
    }
    elsif($status eq "read") {
        $self->setRead($userId);
    }
    elsif($status eq "unread") {
        $self->setUnread($userId);
    }
    elsif($status eq "replied")  {
        $self->setReplied($userId);
    }
    
    #Only let completed stuff go back to pending
    if ( $status eq "pending" && $self->{_properties}{status} eq "completed") {
        $self->{_properties}{status} = "pending";
        $self->{_inbox}{status} = "pending"
    }
    
	$self->session->db->setRow("inbox","messageId",$self->{_inbox});
    return undef;
}

#-------------------------------------------------------------------

=head2 setUnread ( [ userId ] ) 

Marks a message unread.

=head4 userId

The id of the user that reads this message. Defaults to the current user.

=cut

sub setUnread {
	my $self   = shift;
	my $userId = shift || $self->session->user->userId;

    $self->session->db->write(
        q{update inbox_messageState set isRead=0 where messageId=? and userId=?},
        [$self->getId,$userId]
    );
}

#-------------------------------------------------------------------

=head2 statusCodes ( session ) 

Returns a hash ref of valid status values.  Can be called as a class or instance method:

WebGUI::Inbox::Message->statusCodes($session);

my $message     = WebGUI::Inbox::Message->new($session, $messageId);
my $statusCodes = $inbox->statusCodes;

There are two levels of status for any inbox message:

Global Message Status - This is the status of the entire message and holds true for everyone who received the message.  These status values are as follows:

pending - indicates that there is some action for one of the users who received this message to act on.
active  - indicates that this is a message that requires no action by any users who received this message.
completed - indicates that the action that was required is now completed.

Individual Message Status - This is the status of the message for each individual who received it.  If you send a message to a group, each person who received the message will be able to see the message in one of the following states:

unread  - indicates that this message has not be read by the current user
read    - indicates that this message has been read by the current user
replied - indicates that the user has replied to this message

It is important to note that there is one more status not listed here which is deleted.  This is a special state and you should use the setDeleted method in this class if you wish to delete a message for a user. 

=head4 session

The current session object.

=cut

sub statusCodes {
	my $self    = shift;
    my $session = shift;

    if(ref $self eq "WebGUI::Inbox::Message") {
        $session = $self->session;
    }

    my $i18n = WebGUI::International->new($session);
    return {
        "active"    => $i18n->get("inbox message status active"),
        "pending"   => $i18n->get(552),
        "completed" => $i18n->get(350),
        "unread"    => $i18n->get("private message status unread"),
        "read"      => $i18n->get("private message status read"),
        "replied"   => $i18n->get("private message status replied"),        
    }
}

1;
