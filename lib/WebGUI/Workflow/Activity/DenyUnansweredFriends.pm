package WebGUI::Workflow::Activity::DenyUnansweredFriends;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::DateTime;
use DateTime::Duration;
use WebGUI::Friends;

=head1 NAME

Package WebGUI::Workflow::Activity::DenyUnansweredFriends

=head1 DESCRIPTION

This activity denies unanswered "Add a friend" requests after a set period of time.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Friends");
	push(@{$definition}, {
		name        =>  $i18n->get("deny unanswered friends"),
		properties  => {
		    timeout => {
				fieldType       => "interval",
				label           => $i18n->get("timeout"),
				defaultValue    => 0,
				hoverHelp       => $i18n->get("timeout help"),
				},
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
    my $start = time();
    my $session = $self->session;
    my $now = WebGUI::DateTime->new($session, $start);
    my $outdated = DateTime::Duration->new(seconds => $self->get("timeout"));
    my $pending = WebGUI::Friends->getAllPendingAddRequests($session);
    my $ttl = $self->getTTL;
    while (my $invite = $pending->hashRef) {
        my $sentOn = WebGUI::DateTime->new($session, $invite->{dateSent});
        if (DateTime::Duration->compare($now - $sentOn, $outdated) == 1) {
            WebGUI::Friends->new($session, WebGUI::User->new($session, $invite->{friendId}))->rejectAddRequest($invite->{inviteId},$session->setting->get("sendRejectNotice"));
        }
        if (time() - $start > $ttl) {
            $pending->finish;
            return $self->WAITING(1);
        }
    }
	return $self->COMPLETE;
}



1;


