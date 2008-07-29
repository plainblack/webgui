package WebGUI::Inbox;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}

#-------------------------------------------------------------------

=head2 getMessage ( messageId ) 

Returns a WebGUI::Inbox::Message object.

=head3 messageId

The id of the message to retrieve.

=cut

sub getMessage {
	my $self = shift;
	return WebGUI::Inbox::Message->new($self->session, shift);
}


#-------------------------------------------------------------------

=head2 getMessagesForUser ( user [ , limit ] )

Returns an array reference containing the most recent message objects for a given user.

=head3 user

A user object.

=head3 limit

An integer indicating the number of messages to fetch. Defaults to 50.

=cut

sub getMessagesForUser {
    my $self        = shift;
    my $user        = shift;
    my $perpage     = shift || 50;
    my $page        = shift || 1;
    my $sortBy      = shift;
    
    my @messages = ();
    my $counter  = 0;
    
    my ( $sql, @bindvars );
    my $start   = (($page-1) * $perpage);
    my $end     = $start + $page * $perpage;
    my $limit   = "$start, $perpage";

    ### Here we're going to get enough rows to fill our needs ($end) from each subquery, then
    ### use the UNION to grab only the rows we want to display ($limit)

    # If we have a way to sort, use that
    if ( grep { $_ eq $sortBy } qw( subject sentBy dateStamp ) ) {
        $sql        = q{ ( SELECT messageId, userId, groupId, %s FROM inbox WHERE userId = "%s" ORDER BY %s LIMIT %s ) }
                    . q{ UNION }
                    . q{ ( SELECT messageId, userId, groupId, %s FROM inbox WHERE groupId IN ( %s ) ORDER BY %s LIMIT %s ) }
                    . q{ ORDER BY %s LIMIT %s }
                    ;
        @bindvars   = ( 
                        $sortBy, $user->userId, $sortBy, $end, 
                        $sortBy, $self->session->db->quoteAndJoin( $user->getGroupIdsRecursive ), $sortBy, $end,
                        $sortBy, $limit
                    );
    }
    # Otherwise put "pending" messages above "completed" messaged and sort by date descending
    else {
        $sql    = 
                 q{ ( SELECT messageId, status, dateStamp FROM inbox WHERE status="pending" AND groupId IN ( %s ) ORDER BY dateStamp DESC LIMIT %s ) }
                . q{ UNION }
                . q{ ( SELECT messageId, status, dateStamp FROM inbox WHERE status="pending" AND userId = "%s" ORDER BY dateStamp DESC LIMIT %s ) }
                . q{ UNION }
                . q{ ( SELECT messageId, status, dateStamp FROM inbox WHERE status="completed" AND groupId IN ( %s ) ORDER BY dateStamp DESC LIMIT %s ) }
                . q{ UNION }
                . q{ ( SELECT messageId, status, dateStamp FROM inbox WHERE status="completed" AND userId = "%s" ORDER BY dateStamp DESC LIMIT %s ) }
                . q{ ORDER BY status="pending" DESC, dateStamp DESC LIMIT %s }
                ;

        @bindvars   = ( 
                        ( $self->session->db->quoteAndJoin( $user->getGroupIdsRecursive ), $end,
                        $user->userId, $end, 
                        ) x 2,
                        $limit,
                    );
    }

    my $rs      = $self->session->db->read( sprintf $sql, @bindvars );
    while ( my ( $messageId ) = $rs->array ) {
        push @messages, $self->getMessage( $messageId );
    }
    $rs->finish;

    return \@messages;	
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

