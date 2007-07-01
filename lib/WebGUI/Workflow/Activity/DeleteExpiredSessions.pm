package WebGUI::Workflow::Activity::DeleteExpiredSessions;


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
use base 'WebGUI::Workflow::Activity';

=head1 NAME

Package WebGUI::Workflow::Activity::DeleteExpiredSessions

=head1 DESCRIPTION

Deletes expired WebGUI sessions.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_DeleteExpiredSessions");
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
	my $sth = $self->session->db->read("select sessionId from userSession where expires<?",[time()]);
	my $time = time();
        while (my ($sessionId) = $sth->array) {
		my $session = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename, undef, undef, $sessionId, 1);
		if (defined $session) {
			$session->var->end;
			$session->close;
		}
		if ((time() - $time) > 55) {
        		$sth->finish;
			return $self->WAITING;
		}
        }
	return $self->COMPLETE;
}



1;


