package WebGUI::Workflow::Activity::DeleteExpiredSessions;


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

See WebGUI::Workflow::Activity::definition() for details.

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
	my $sth = $self->session->db->read("select sessionId, lastPageView from userSession where expires<?",[time()]);
	my $time = time();
    my $ttl = $self->getTTL;

    while ( my ( $sessionId, $lastPageView ) = $sth->array ) {
        # timeRecordSessions
        my ($nonTimeRecordedRows) = $self->session->db->quickArray("select count(*) from userLoginLog where lastPageViewed = timeStamp and sessionId = ? ", [$sessionId] );
        if ($nonTimeRecordedRows eq "1") {
            # We would normally expect to only find one entry
            $self->session->db->write("update userLoginLog set lastPageViewed = ? where lastPageViewed = timeStamp and sessionId = ? ",
                [ $lastPageView, $sessionId ]);
        } elsif ($nonTimeRecordedRows eq "0") {
            # Do nothing
        } else {
            # If something strange happened and we ended up with > 1 matching rows, cut our losses and remove offending userLoginLog rows (otherwise we
            # could end up with ridiculously long user recorded times)
            $self->session->errorHandler->warn("More than 1 old userLoginLog rows found, removing offending rows");
            $self->session->db->write("delete from userLoginLog where lastPageViewed = timeStamp and sessionId = ? ", [$sessionId] );
        }
		my $session = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilePath, undef, undef, $sessionId, 1);
		if (defined $session) {
			$session->var->end;
			$session->close;
		}
		if ((time() - $time) > $ttl) {
            $sth->finish;
			return $self->WAITING(1);
		}
    }
	
    return $self->COMPLETE;
}



1;


