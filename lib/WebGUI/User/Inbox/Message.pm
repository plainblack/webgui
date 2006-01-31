package WebGUI::User::Inbox::Message;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

=head1 NAME

Package WebGUI::User::Inbox::Message;

=head1 DESCRIPTION

This package provides an API for working with a User's inbox messages.

=head1 SYNOPSIS


=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 create ( )

=cut 

sub create {
	my $self = shift;
}

#-------------------------------------------------------------------

=head2 delete

Deletes  this message from the inbox.

=cut

sub delete {
	my $self = shift;
	my $sth = $self->session->db->prepare("delete from userInbox where messageId=?");
	$sth->execute($self->getId);
}

#-------------------------------------------------------------------

=head DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}

#-------------------------------------------------------------------

=head2 get ( property ) 

Returns the value of a property.

=head3 property

The name of any property of an inbox message.

=head4 message

=head4 subject

=cut

sub get {
	my $self = shift;
	unless ($self->{_properties}) {
		$self->{_properties} = $self->session->db->getRow("userInbox","messageId",$self->getId);
	}
	return $self->{_properties}{shift};
}


#-------------------------------------------------------------------

=head2 getId ()

Returns the ID of this message.

=cut

sub getId {
	my $self = shift;
	return $self->{_messageId};
}

#-------------------------------------------------------------------

=head2 inbox

Returns a reference to the user's inbox.

=cut

sub inbox {
	my $self = shift;
	return $self->{_inbox};
}

#-------------------------------------------------------------------

=head2 new ( inbox, messageId )

Constructor.

=head3 inbox

A reference to a user's inbox object.

=head3 messageId

=cut

sub new {
	my $class = shift;
	my $inbox = shift;
	my $messageId = shift;
	bless {_inbox=>$inbox, _messageId=>$messageId}, $class;
}

#-------------------------------------------------------------------

=head2 session

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->inbox->session;
}

#-------------------------------------------------------------------

=head2 user

Returns a reference to the user who owns this inbox.

=cut

sub user {
	my $self = shift;
	return $self->inbox->user;
}

1;

