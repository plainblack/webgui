package WebGUI::User::Inbox;

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

Package WebGUI::User::Inbox;

=head1 DESCRIPTION

This package provides an API for working with a User's inbox.

=head1 SYNOPSIS

 my $inbox = $user->inbox;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addMessage ( )

=cut 

sub addMessage {
	my $self = shift;
	return WebGUI::User::Inbox::Message->create($self);
}

#-------------------------------------------------------------------

=head2 deleteAllMessages

Deletes all the messages in this user's inbox.

=cut

sub deleteAllMessages {
	my $self = shift;
	my $sth = $self->session->db->prepare("delete from userInbox where userId=?");
	$sth->execute($self->user->userId);
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

=head2 new ( user )

Constructor.

=head3 user

A reference to the user who's inbox that we'll be manipulating.

=cut

sub new {
	my $class = shift;
	my $user = shift;
	bless {_user=>$user}, $class;
}

#-------------------------------------------------------------------

=head2 session

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->user->session;
}

#-------------------------------------------------------------------

=head2 user

Returns a reference to the user who owns this inbox.

=cut

sub user {
	my $self = shift;
	return $self->{_user};
}

1;

