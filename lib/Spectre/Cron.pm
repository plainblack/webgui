package Spectre::Cron;

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
use DateTime;
use DateTime::Cron::Simple;
use WebGUI::Session;

#-------------------------------------------------------------------

=head2 addJob ( config, job ) 

Adds a job to the cron monitoring queue.

=head3 config

The filename of the configuration file for the site this job belongs to.

=head3 job

A hash reference containing the properties of the job from the WorkflowSchedule table.

=cut

sub addJob {
	my $self = shift;
	my $config = shift;
	my $job = shift;
	return 0 unless ($job->{enabled});
	$self->{_jobs}{$job->{jobId}} = {
		config=>$config,
		schedule=>join(" ", $job->{minuteOfHour}, $job->{hourOfDay}, $job->{dayOfMonth}, $job->{monthOfYear}, $job->{dayOfWeek}),
		workflowId=>$job->{workflowId} 
		}
}


#-------------------------------------------------------------------

=head2 checkSchedules ( ) 

Checks all the schedules of the jobs in the queue and triggers a workflow if a schedule matches.

=cut

sub checkSchedules {
	my $self = shift
	my $now = DateTime->from_epoch(epoch=>time());
	foreach my $jobId (keys %{$self->{_jobs}}) {
		my $cron = DateTime::Cron::Simple->new($self->{_jobs}{$jobId}{schedule});
        	if ($cron->validate_time($now) {
			# kick off an event here once we know what that api looks like
		}
	}
}


#-------------------------------------------------------------------

=head2 deleteJob ( jobId ) 

Removes a job from the monitoring queue.

=head3 jobId

The unique id of the job to remove.

=cut

sub deleteJob {
	my $self = shift;
	delete $self->{_jobs}{shift};
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

=head2 new ( webguiRoot )

Constructor. Loads all schedules from WebGUI sites into it's job queue.

=head3 webguiRoot

The path to the root of the WebGUI installation.

=cut

sub new {
	my $class = shift;
	my $webguiRoot = shift;
	my $self = {_webguiRoot=>$webguiRoot};
	bless $self, $class;
	my $configs = WebGUI::Config->readAllConfigs($webguiRoot);
	foreach my $config (keys %{$configs}) {
		my $session = WebGUI::Session->open($webguiRoot, $config);
		my $result = $session->db->read("select * from WorkflowSchedule");
		while (my $data = $result->hashRef) {
			$self->addJob($config, $data);
		}
		$session->close;
	}
}


1;

