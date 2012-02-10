package WebGUI::Workflow::Activity::SummarizePassiveProfileLog;


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
use WebGUI::PassiveProfiling;

=head1 NAME

Package WebGUI::Workflow::Activity::SummarizePassiveProfileLog;

=head1 DESCRIPTION

Calculates the statistics for passive profiling so that they may be used in the AOI macros.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_SummarizePassiveProfileLog");
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
	return $self->COMPLETE unless ($self->session->setting->get("passiveProfilingEnabled"));
        my ($firstDate) = $self->session->db->quickArray("select min(dateOfEntry) from passiveProfileLog");
        my $sessionExpired = time() - $self->session->setting->get("sessionTimeout");
        # We process entries for registered users and expired visitor sessions
        my $sql = "select * from passiveProfileLog where userId <> 1 or (userId = 1 and dateOfEntry < ?)";
        my $sth = $self->session->db->read($sql, [$sessionExpired]);
        while (my $data = $sth->hashRef) {
                WebGUI::PassiveProfiling::summarizeAOI($self->session,$data);
                $self->session->db->write("delete from passiveProfileLog where passiveProfileLogId = ?", [$data->{passiveProfileLogId}]);
        }
        $sth->finish;
	return $self->COMPLETE;
}



1;


