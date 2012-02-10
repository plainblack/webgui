package WebGUI::Workflow::Activity::SendQueuedMailMessages;


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
use WebGUI::Mail::Send;

=head1 NAME

Package WebGUI::Workflow::Activity::SendQueuedMailMessages

=head1 DESCRIPTION

Sends all the messages in the mail queue.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_SendQueuedMailMessages");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my $start = time();
    my $ttl = $self->getTTL;
	foreach my $id (@{WebGUI::Mail::Send->getMessageIdsInQueue($self->session)}) {
		my $message = WebGUI::Mail::Send->retrieve($self->session, $id);
		if (defined $message) {
			unless ($message->send) {
				# if the message fails to send, requeue it
				$message->queue;
			}	
		}
		# just in case there are a lot of messages, we should release after a minutes worth of sending
		last if (time() > $start + $ttl);
	}
	return $self->COMPLETE;
}



1;


