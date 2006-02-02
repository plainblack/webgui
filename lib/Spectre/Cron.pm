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
use POE;
use WebGUI::Session;

#-------------------------------------------------------------------

=head2 _start ( )

Initializes the scheduler.

=cut

sub _start {
        print "Starting WebGUI Spectre Scheduler...";
        my ( $kernel, $self, $publicEvents) = @_[ KERNEL, OBJECT, ARG0 ];
        my $serviceName = "scheduler";
        $kernel->alias_set($serviceName);
        $kernel->call( IKC => publish => $serviceName, $publicEvents );
	my $configs = WebGUI::Config->readAllConfigs($self->{_webguiRoot});
	foreach my $config (keys %{$configs}) {
		$kernel->yield("loadSchedule", $config);
	}
        print "OK\n";
        $kernel->yield("checkSchedules");
}

#-------------------------------------------------------------------

=head2 _stop ( )

Gracefully shuts down the scheduler.

=cut

sub _stop {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	print "Stopping WebGUI Spectre Scheduler...";
	undef $self;
	print "OK\n";
}



#-------------------------------------------------------------------

=head2 addJob ( config, job ) 

Adds a job to the cron monitoring queue.

=head3 config

The filename of the configuration file for the site this job belongs to.

=head3 job

A hash reference containing the properties of the job from the WorkflowSchedule table.

=cut

sub addJob {
	my ($self, $config, $job) = @_[OBJECT, ARG0, ARG1];
	return 0 unless ($job->{enabled});
	$self->{_jobs}{$job->{jobId}} = {
		jobId=>$job->{jobId},
		config=>$config,
		schedule=>join(" ", $job->{minuteOfHour}, $job->{hourOfDay}, $job->{dayOfMonth}, $job->{monthOfYear}, $job->{dayOfWeek}),
		workflowId=>$job->{workflowId} 
		}
}


#-------------------------------------------------------------------

=head2 checkSchedule ( job, now ) 

Compares a schedule with the current time and kicks off an event if necessary. This method should only ever need to be called by checkSchedules().

=head3 job

A job definition created through the addJob() method.

=head3 now

A DateTime object representing the time to compare the schedule with.

=cut

sub checkSchedule {
	my ($kernel, $self, $job, $now) = @_[KERNEL, OBJECT, ARG0, ARG1];
	my $cron = DateTime::Cron::Simple->new($job->{schedule});
       	if ($cron->validate_time($now)) {
		# kick off an event here once we know what that api looks like
	}
}

#-------------------------------------------------------------------

=head2 checkSchedules ( ) 

Checks all the schedules of the jobs in the queue and triggers a workflow if a schedule matches.

=cut

sub checkSchedules {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	my $now = DateTime->from_epoch(epoch=>time());
	foreach my $jobId (keys %{$self->{_jobs}}) {
		$kernel->yield("checkSchedule", $self->{_jobs}{$jobId}, $now)
	}
}


#-------------------------------------------------------------------

=head2 deleteJob ( jobId ) 

Removes a job from the monitoring queue.

=head3 jobId

The unique id of the job to remove.

=cut

sub deleteJob {
	my ($self, $jobId) = @_[OBJECT, ARG0];
	delete $self->{_jobs}{$jobId};
}


#-------------------------------------------------------------------

=head2 loadSchedule ( config )

Loads the workflow schedule from a particular site.

=head3 config

The config filename for the site to load the schedule.

=cut

sub loadSchedule {
	my ($kernel, $self, $config) = @_[KERNEL, OBJECT, ARG0];
	my $session = WebGUI::Session->open($self->{_webguiRoot}, $config);
	my $result = $session->db->read("select * from WorkflowSchedule");
	while (my $data = $result->hashRef) {
		$kernel->yield("addJob",$config, $data);
	}
	$session->close;
}

#-------------------------------------------------------------------

=head2 new ( webguiRoot )

Constructor.

=head3 webguiRoot

The path to the root of the WebGUI installation.

=cut

sub new {
	my $class = shift;
	my $webguiRoot = shift;
	my $self = {_webguiRoot=>$webguiRoot};
	bless $self, $class;
	my @publicEvents = qw(addJob deleteJob);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop checkEvents checkEvent loadSchedule), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}



1;

