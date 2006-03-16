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
use WebGUI::Workflow::Cron;
use WebGUI::Workflow::Instance;

#-------------------------------------------------------------------

=head2 _start ( )

Initializes the scheduler.

=cut

sub _start {
        my ( $kernel, $self, $publicEvents) = @_[ KERNEL, OBJECT, ARG0 ];
	$self->debug("Starting Spectre scheduler.");
        my $serviceName = "scheduler";
        $kernel->alias_set($serviceName);
        $kernel->call( IKC => publish => $serviceName, $publicEvents );
	$self->debug("Loading the schedules from all the sites.");
	my $configs = WebGUI::Config->readAllConfigs($self->config->getWebguiRoot);
	foreach my $config (keys %{$configs}) {
		$kernel->yield("loadSchedule", $config);
	}
        $kernel->yield("checkSchedules");
}

#-------------------------------------------------------------------

=head2 _stop ( )

Gracefully shuts down the scheduler.

=cut

sub _stop {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	$self->debug("Stopping the scheduler.");
	undef $self;
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
	$self->debug("Adding schedule ".$job->{taskId}." to the queue.");
	$self->{_jobs}{$job->{taskId}} = {
		taskId=>$job->{taskId},
		config=>$config,
		schedule=>join(" ", $job->{minuteOfHour}, $job->{hourOfDay}, $job->{dayOfMonth}, $job->{monthOfYear}, $job->{dayOfWeek}),
		runOnce=>$job->{runOnce},
		workflowId=>$job->{workflowId},
		className=>$job->{className},
		methodName=>$job->{methodName},
		parameters=>$job->{parameters},
		priority=>$job->{priority}
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
	$self->debug("Checking schedule ".$job->{taskId}." against the current time.");
	my $cron = DateTime::Cron::Simple->new($job->{schedule});
       	if ($cron->validate_time($now)) {
		$self->debug("It's time to run ".$job->{taskId}.". Creating workflow instance.");
		my $session = WebGUI::Session->open($self->config->getWebguiRoot, $job->{config});
		my $instance = WebGUI::Workflow::Instance->create($session, {
			workflowId=>$job->{workflowId},
			className=>$job->{className},
			methodName=>$job->{methodName},
			parameters=>$job->{parameters},
			priority=>$job->{priority}
			});
		if (defined $instance) {
			$self->debug("Created workflow instance ".$instance->getId.".");
		} else {
			$self->debug("Something bad happened. Couldn't create workflow instance for schedule ".$job->{taskId}.".");
		}
		if ($job->{runOnce}) {
			$self->debug("Schedule ".$job->{taskId}." is only supposed to run once.");
			my $cron = WebGUI::Workflow::Cron->new($session, $job->{taskId});
			if (defined $cron) {		
				$self->debug("Deleting schedule from database.");
				$cron->delete;
			} else {
				$self->debug("Couldn't instanciate schedule ".$job->{taskId}." in order to delete it.");
			}
		}
		$session->close;
	}
}

#-------------------------------------------------------------------

=head2 checkSchedules ( ) 

Checks all the schedules of the jobs in the queue and triggers a workflow if a schedule matches.

=cut

sub checkSchedules {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	$self->debug("Checking schedules against current time.");
	my $now = DateTime->from_epoch(epoch=>time());
	foreach my $taskId (keys %{$self->{_jobs}}) {
		$kernel->yield("checkSchedule", $self->{_jobs}{$taskId}, $now)
	}
	$kernel->delay_set("checkSchedules",60);
}


#-------------------------------------------------------------------

=head2 config 

Returns a reference to the config object.

=cut 

sub config {
	my $self = shift;
	return $self->{_config};
}

#-------------------------------------------------------------------

=head2 debug ( output )

Prints out debug information if debug is enabled.

=head3 

=cut 

sub debug {
	my $self = shift;
	my $output = shift;
	if ($self->{_debug}) {
		print "CRON: ".$output."\n";
	}
}

#-------------------------------------------------------------------

=head2 deleteJob ( taskId ) 

Removes a job from the monitoring queue.

=head3 taskId

The unique id of the job to remove.

=cut

sub deleteJob {
	my ($self, $taskId) = @_[OBJECT, ARG0];
	$self->debug("Deleting schedule $taskId from queue.");
	delete $self->{_jobs}{$taskId};
}


#-------------------------------------------------------------------

=head2 loadSchedule ( config )

Loads the workflow schedule from a particular site.

=head3 config

The config filename for the site to load the schedule.

=cut

sub loadSchedule {
	my ($kernel, $self, $config) = @_[KERNEL, OBJECT, ARG0];
	$self->debug("Loading schedules for $config.");
	my $session = WebGUI::Session->open($self->config->getWebguiRoot, $config);
	my $result = $session->db->read("select * from WorkflowSchedule");
	while (my $data = $result->hashRef) {
		$kernel->yield("addJob",$config, $data);
	}
	$session->close;
}

#-------------------------------------------------------------------

=head2 new ( config )

Constructor.

=head3 config

A WebGUI::Config object that represents the spectre.conf file.

=head3 debug

A boolean indicating Spectre should spew forth debug as it runs.

=cut

sub new {
	my $class = shift;
	my $config  = shift;
	my $debug = shift;
	my $self = {_debug=>$debug, _config=>$config};
	bless $self, $class;
	my @publicEvents = qw(addJob deleteJob);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop checkSchedules checkSchedule loadSchedule), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}



1;

