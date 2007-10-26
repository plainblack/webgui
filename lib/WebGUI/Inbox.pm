package WebGUI::Inbox;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
	my $self     = shift;
	my $user     = shift;
	my $limit    = shift || 50;
    my $page     = shift || 1;
    my $sortBy   = shift;
    
	my @messages = ();
	my $counter  = 0;
	
    unless($sortBy eq "subject" || $sortBy eq "sentBy" || $sortBy eq "dateStamp") {
        $sortBy = "status='pending' desc, dateStamp desc";
    }
    
    my $start = (($page-1) * $limit) + 1;
    my $end   = $page * $limit;
    my $rs = $self->session->db->read("select messageId, userId, groupId from inbox order by $sortBy");
	while (my ($messageId, $userId, $groupId) = $rs->array) {
		if ($user->userId eq $userId || ($groupId && $user->isInGroup($groupId))) {
			$counter++;
            next if ($counter < $start);
            push(@messages, $self->getMessage($messageId));
			last if ($counter >= $end);
		}
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

