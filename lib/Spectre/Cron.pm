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
        my $serviceName = "cron";
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

=head2 addJob ( params ) 

Adds a job to the cron monitoring queue.

=head3 params

A hash reference containing data about the job.

=head4 taskId

The unique id for the cron job.

=head4 sitename

The sitename that the job belongs to.

=head4 config

The name of the config file of the site that the job belongs to.

=head4 enabled

A boolean indicating whether the job is enabled or not.

=head4 minuteOfHour

Part of the schedule.

=head4 hourOfDay

Part of the schedule.

=head4 dayOfMonth

Part of the schedule.

=head4 monthOfYear

Part of the schedule.

=head4 dayOfWeek

Part of the schedule.

=head4 runOnce

A boolean indicating whether this cron should be executed more than once.

=head4 workflowId

The ID of the workflow that should be kicked off when the time is right.

=head4 className

The class name of the object to be created to be passed in to the workflow.

=head4 methodName

THe method name of the object to be created to be passed in to the workflow.

=head4 parameters

The parameters of the object to be created to be passed in to the workflow.

=head4 priority

An integer (1,2,3) that determines what priority the workflow should be executed at.

=cut

sub addJob {
	my ($self, $params) = @_[OBJECT, ARG0];
	return 0 unless ($params->{enabled});
	$self->debug("Adding schedule ".$params->{taskId}." to the queue.");
	$self->{_jobs}{$params->{config}}{$params->{taskId}} = {
		taskId=>$params->{taskId},
		config=>$params->{config},
		sitename=>$params->{sitename},
		schedule=>join(" ", $params->{minuteOfHour}, $params->{hourOfDay}, $params->{dayOfMonth}, $params->{monthOfYear}, $params->{dayOfWeek}),
		runOnce=>$params->{runOnce},
		workflowId=>$params->{workflowId},
		className=>$params->{className},
		methodName=>$params->{methodName},
		parameters=>$params->{parameters},
		priority=>$params->{priority}
		};
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
	$self->debug("Checking schedule ".$job->{taskId}." for ".$job->{config}." against the current time.");
	my $cron = DateTime::Cron::Simple->new($job->{schedule});
       	if ($cron->validate_time($now)) {
		$self->debug("It's time to run ".$job->{taskId}." for ".$job->{config}.". Creating workflow instance.");
		my $session = WebGUI::Session->open($self->config->getWebguiRoot, $job->{config});
		my $instance = WebGUI::Workflow::Instance->create($session, {
			workflowId=>$job->{workflowId},
			className=>$job->{className},
			methodName=>$job->{methodName},
			parameters=>$job->{parameters},
			priority=>$job->{priority},
			notifySpectre=>0
			});
		if (defined $instance) {
			$self->debug("Created workflow instance ".$instance->getId.".");
			$kernel->post($self->workflowSession, "addInstance", {instanceId=>$instance->getId, priority=>$job->{priority}, sitename=>$job->{sitename}});
		} else {
			$self->debug("Something bad happened. Couldn't create workflow instance for schedule ".$job->{taskId}." for ".$job->{config}.".");
		}
		if ($job->{runOnce}) {
			$self->debug("Schedule ".$job->{taskId}." for ".$job->{config}." is only supposed to run once.");
			my $cron = WebGUI::Workflow::Cron->new($session, $job->{taskId});
			if (defined $cron) {		
				$self->debug("Deleting schedule from database.");
				$cron->delete(1);
			} else {
				$self->debug("Couldn't instanciate schedule ".$job->{taskId}." in order to delete it.");
			}
			$kernel->yield("deleteJob",{config=>$job->{config}, taskId=>$job->{taskId}});
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
	foreach my $config (keys %{$self->{_jobs}}) {
		foreach my $taskId (keys %{$self->{_jobs}{$config}}) {
			$kernel->yield("checkSchedule", $self->{_jobs}{$config}{$taskId}, $now)
		}
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

=head2 deleteJob ( params ) 

Removes a job from the monitoring queue.

=head3 params

A hash reference containing the info needed to delete this job.

=head4 taskId

The unique ID for this job.

=head4 config

The config file name for the site this job belongs to.

=cut

sub deleteJob {
	my ($self, $params) = @_[OBJECT, ARG0];
	$self->debug("Deleting schedule ".$params->{taskId}." for ".$params->{config}." from queue.");
	delete $self->{_jobs}{$params->{config}}{$params->{taskId}};
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
		$data->{config} = $config;
		$data->{sitename} = $session->config->get("sitename")->[0];
		$kernel->yield("addJob", $data);
	}
	$session->close;
}

#-------------------------------------------------------------------

=head2 new ( config )

Constructor.

=head3 config

A WebGUI::Config object that represents the spectre.conf file.

=head3 workflowSession

A reference to the Worfklow session.

=head3 debug

A boolean indicating Spectre should spew forth debug as it runs.

=cut

sub new {
	my $class = shift;
	my $config  = shift;
	my $workflowSession = shift;
	my $debug = shift;
	my $self = {_debug=>$debug, _workflowSession=>$workflowSession, _config=>$config};
	bless $self, $class;
	my @publicEvents = qw(addJob deleteJob);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop addJob deleteJob checkSchedules checkSchedule loadSchedule), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}


#-------------------------------------------------------------------

=head2 workflowSession ( )

Returns a reference to the workflow session.

=cut

sub workflowSession {
	my $self = shift;
	return $self->{_workflowSession};
}


1;

