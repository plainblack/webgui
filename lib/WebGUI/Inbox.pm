package WebGUI::Inbox;

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
use WebGUI::Inbox::Message;

=head1 NAME

Package WebGUI::Inbox;

=head1 DESCRIPTION

This class provides a message routing system, which is primarily used by WebGUI's workflow engine.

=head1 SYNOPSIS

 use WebGUI::Inbox;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addMessage ( properties )

Adds a new message to the inbox.

=head3 properties

See WebGUI::Inbox::Message::create() for details.

=cut 

sub addMessage {
	my $self = shift;
	return WebGUI::Inbox::Message->create($self->session, @_);
}

#-------------------------------------------------------------------

=head2 addPrivateMessage ( properties[, userToSend] )

Adds a new private message to the inbox if the user accepts private messages.

=head3 properties

See WebGUI::Inbox::Message::addMessage() for details.

=cut 

sub addPrivateMessage {
	my $self        = shift;
    my $messageData = shift;
    my $isReply     = shift;
    
    my $userId      = $messageData->{userId};
    my $sentBy      = $messageData->{sentBy} || $self->session->user->userId;
    return undef unless $userId;
    
    my $u = WebGUI::User->new($self->session,$userId);
    return undef unless ($isReply || $u->acceptsPrivateMessages($sentBy));
	
    return $self->addMessage($messageData);
}

#-------------------------------------------------------------------

=head2 canRead ( messageId [, user] ) 

Returns whether or not a user can view the message passed in.

=head3 message

A WebGUI::Inbox::Message object

=head3 user

WebGUI::User object to test against.  Defaults to the current user.

=cut

sub canRead {
	my $self    = shift;
    my $session = $self->session;
    my $message = shift;
    my $user    = shift || $session->user;

    unless (ref $message eq "WebGUI::Inbox::Message") {
        $session->log->warn("Message passed in was either empty or not a valid WebGUI::Inbox::Message.  Got: ".(ref $message));
        return 0
    }

    my $userId  = $message->get("userId");
    my $groupId = $message->get("groupId");

    return ($user->userId eq $userId
        || (defined $groupId && $user->isInGroup($groupId))
        || ($user->isInGroup($session->setting->get('groupIdAdminUser')))
    );

}

#-------------------------------------------------------------------

=head2 deleteMessagesForUser ( $user ) 

Deletes all messages for a user.

=head3 $user

A WebGUI::User object, representing the user who will have all their messages deleted.

=cut

sub deleteMessagesForUser {
	my $self    = shift;
    my $user    = shift;

    my $messages = $self->getMessagesForUser($user, 1e10);
    my $userId  = $user->userId;
    foreach my $message (@{ $messages }) {
        $message->delete($userId);
    }
}

#-------------------------------------------------------------------

=head2 getMessage ( messageId [, userId] ) 

Returns a WebGUI::Inbox::Message object.

=head3 messageId

The id of the message to retrieve.

=head3 userId

The id of the user to retrieve the message for.  Defaults to the current user.

=cut

sub getMessage {
	my $self      = shift;
    my $messageId = shift;
    my $userId    = shift;

	return WebGUI::Inbox::Message->new($self->session, $messageId, $userId);
}

#-------------------------------------------------------------------

=head2 getNextMessage ( message [, userId] ) 

Returns the message that was sent after the message passed in for the user.  This is always assumed
to be in date order.

=head3 message

The message to find the next message for

=head3 user

The WebGUI::User object of the user to retrieve the message for.  Defaults to the current user.

=cut

sub getNextMessage {
    my $self      = shift;
    my $session   = $self->session;
    my $baseMessage = shift;
    my $user      = shift || $session->user;
    
	my $sql = $self->getMessageSql($user,{
        whereClause => "ibox.dateStamp > ".$baseMessage->get("dateStamp"),
        sortBy      => "ibox.dateStamp",
        sortDir     => "asc",
        limit       => 1
    });
    
    my $message = $self->session->db->quickHashRef($sql);
    
    return $self->getMessage($message->{messageId});
}

#-------------------------------------------------------------------

=head2 getPreviousMessage ( message [, userId] ) 

Returns the message that was sent before the message passed in for the user.  This is always assumed
to be sorted in date order.

=head3 message

The message to find the previous message for.

=head3 user

The WebGUI::User object of the user to retrieve the message for.  Defaults to the current user.

=cut

sub getPreviousMessage {
	my $self      = shift;
    my $session   = $self->session;
    my $baseMessage = shift;
    my $user      = shift || $session->user;

    my $sql = $self->getMessageSql($user,{
        whereClause => "ibox.dateStamp < ".$baseMessage->get("dateStamp"),
        sortBy      => "ibox.dateStamp",
        sortDir     => "desc",
        limit       => 1
    });
    
    my $message = $self->session->db->quickHashRef($sql);
    
    return $self->getMessage($message->{messageId});
}

#-------------------------------------------------------------------

=head2 getMessagesForUser ( user [ , limit, page, sortBy ] )

Returns an array reference containing the most recent message objects for a given user.

=head3 user

A user object.

=head3 limit

An integer indicating the number of messages to fetch. Defaults to 50.

=head3 page

An integer indication the page to return.  Defaults to 1

=head3 sortby

The column to sort by

=head3 where

An extra clause for filtering results.

=cut

sub getMessagesForUser {
    my $self        = shift;
    my $user        = shift;
    my $perpage     = shift || 50;
    my $page        = shift || 1;
    my $sortBy      = shift;
    my $where       = shift;
    
    my $p = $self->getMessagesPaginator( $user , {
        sortBy        => $sortBy,
        sortDir       => "desc",
        paginateAfter => $perpage,
        pageNumber    => $page,
        whereClause   => $where,
    });
    
    return $self->getMessagesOnPage($p);
}

#-------------------------------------------------------------------

=head2 getMessagesOnPage ( paginator ) 

Returns an array ref of WebGUI::Inbox::Message objects created from the current
page of data.

=head3 paginator

The id of the message to retrieve.

=cut

sub getMessagesOnPage {
	my $self     = shift;
    my $p        = shift;
    my @messages = ();
   
    unless (defined $p and ref $p eq "WebGUI::Paginator") {
        $self->session->log->warn("Paginator was not defined");
        return [];
    }

    foreach my $row (@{$p->getPageData}) {
        push @messages, $self->getMessage( $row->{messageId} );
    }
    
    return \@messages;
}



#-------------------------------------------------------------------

=head2 getMessagesPaginator ( user [, properties ] )

Returns an reference to a WebGUI::Paginator object filled with all the messages in a user's inbox

=head3 user

A user object.

=head3 properties

Properties which can be set to determine how many rows are returned, etc

=head4 sortBy

Column to sort the inbox by.  Valid values are subject, sentBy, and dateStamp.  Defaults to
dateStamp if value is invalid.  Defaults to status DESC, dateStamp DESC if value not set.

=head4 sortDir

Direction to sort the results by.  Defaults to desc.  This only works if a sortBy value is set.

=head4 baseUrl

The URL of the current page including attributes. The page number will be appended to this in all links generated by the paginator.
Defaults to $session->url->pge

=head4 paginateAfter

The number of rows to display per page. If left blank it defaults to 25.

=head4 formVar

Specify the form variable the paginator should use in its links.  Defaults to "pn".

=head4 pageNumber

By default the page number will be determined by looking at $self->session->form->process("pn"). If that is empty the page number will be defaulted to "1". If you'd like to override the page number specify it here.

=head4 whereClause

An extra clause to filter the results returned by the paginator.

=cut

sub getMessagesPaginator {    
    my $self          = shift;
    my $session       = $self->session;
    my $user          = shift || $session->user;
    my $properties    = shift;
    
    my $userId        = $user->userId;
    my $sortBy        = $properties->{sortBy};
    my $sortDir       = $properties->{sortDir}  || "desc";
    my $baseUrl       = $properties->{baseUrl}  || $session->url->page;
    my $paginateAfter = $properties->{paginateAfter};
    my $formVar       = $properties->{formVar};
    my $pageNumber    = $properties->{pageNumber};
    my $whereClause   = $properties->{whereClause} || '';

    #Make sure a valid sortBy is passed in
    if($sortBy && !WebGUI::Utility::isIn($sortBy,qw( subject sentBy dateStamp status ))) {
        $sortBy = q{dateStamp}
    }
    #Sort by fullname if user wants to sort by who sent the message
    if ($sortBy eq "sentBy") {
        $sortBy  = q{fullName};
    }
    elsif ($sortBy eq "status") {
        $sortBy  = q{messageStatus};
    }
    elsif($sortBy) {
        $sortBy  = qq{ibox.$sortBy};
    }
    else {
        $sortBy  = q{messageStatus='pending' DESC, dateStamp DESC};
        $sortDir = q{};
    }
    
    my $sql = $self->getMessageSql($user, {
        user        => $user,
        sortBy      => $sortBy,
        sortDir     => $sortDir,
        whereClause => $whereClause,
    });

    my $p = WebGUI::Paginator->new(
        $session,
        $baseUrl,
        $paginateAfter,
        $formVar,
        $pageNumber
    );

    $p->setDataByQuery($sql,undef,undef);

    return $p;	
}

#-------------------------------------------------------------------

=head2 getMessageSql ( user, properties ) 

Returns the SQL used to return the messages in a user's inbox.

=head3 user

WebGUI::User object of user to get messages for.  Defaults to current user.

=head3 properties

Hash reference of properties

=head4 sortBy

Column to sort by.  Valid columns are:

    ibox.messageId,
    ibox.subject,
    ibox.sentBy,
    ibox.dateStamp,
    ibox.status,
    messageStatus,
    fullName

=head4 sortDir

Direction to sort by

=head4 whereClause

A where clause to use

=head4 limit

A full limit clause, not just the number to limit.

=cut

sub getMessageSql {
	my $self        = shift;
    my $session     = $self->session;
    my $user        = shift || $session->user;
    my $props       = shift || {};

    my $userId      = $user->userId;
    my $sortBy      = $props->{sortBy};
    my $sortDir     = $props->{sortDir};
    my $whereClause = $props->{whereClause};
    my $limit       = $props->{limit};
    my $select      = $props->{'select'};

    if($sortBy) {
        $sortBy = qq{ORDER BY $sortBy $sortDir};
    }

    if($whereClause) {
        $whereClause = qq{AND $whereClause};
    }

    if($limit) {
        $limit = qq{LIMIT $limit};
    }

    if(!$select) {
        $select =<<SELECT;
ibox.messageId, ibox.subject, ibox.sentBy, ibox.dateStamp,
(IF(ibox.status = 'completed' or ibox.status = 'pending',ibox.status,IF(inbox_messageState.repliedTo,'replied',IF(inbox_messageState.isRead,'read','unread')))) as messageStatus,
(IF(userProfileData.firstName != '' and userProfileData.firstName is not null and userProfileData.lastName !='' and userProfileData.lastName is not null, concat(userProfileData.firstName,' ',userProfileData.lastName),users.username)) as fullName
SELECT
    }

    my $messageLimit = 20_000;
    my $limitHalf    = $messageLimit / 2;
    my $limitQuarter = $messageLimit / 4;
    my $userGroups   = $session->db->quoteAndJoin( $user->getGroupIdsRecursive );
    $userGroups      = "''" if $userGroups eq "";

    # for performance purposes don't use datasets larger than 20000 no matter how man messages are in the inbox
    my $sql = qq{
        SELECT
            $select
        FROM inbox_messageState
        JOIN inbox ibox USING (messageId)
        JOIN users on users.userId = ibox.sentBy
        JOIN userProfileData on userProfileData.userId = ibox.sentBy
        WHERE inbox_messageState.messageId = ibox.messageId 
        AND   inbox_messageState.userId    = '$userId' 
        AND   inbox_messageState.deleted   = 0
        $whereClause
        $sortBy
        $limit
    };

    #$session->log->warn($sql);

    return $sql;
}


#-------------------------------------------------------------------

=head2 getUnreadMessageCount ( [userId] ) 

Returns the number of unread messages for the user passed in

=head3 userId

user to get unread message count for.  Defaults to current user.

=cut

sub getUnreadMessageCount {
	my $self     = shift;
    my $session  = $self->session;
    my $userId   = shift || $session->user->userId;

    return $session->db->quickScalar(
        qq{select count(*) from inbox_messageState where userId=? and deleted=0 and isRead=0 },
        [$userId]
    );
}



#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


1;
