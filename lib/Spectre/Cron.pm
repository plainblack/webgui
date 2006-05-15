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
use HTTP::Request::Common;
use POE;
use POE::Component::Client::UserAgent;
use WebGUI::Session;
use WebGUI::Workflow::Cron;

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
		gateway=>$params->{gateway},
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
		$kernel->yield("runJob",$job);
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
	$self->getLogger->debug("CRON: ".$output);
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

=head2 error ( output )

Prints out error information if debug is enabled.

=head3 

=cut 

sub error {
	my $self = shift;
	my $output = shift;
	if ($self->{_debug}) {
		print "CRON: ".$output."\n";
	}
	$self->getLogger->error("CRON: ".$output);
}

#-------------------------------------------------------------------

=head3 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
	my $self = shift;
	return $self->{_logger};
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
		my $params = JSON::jsonToObj($data->{parameters});
		$data->{parameters} = $params->{parameters};
		$data->{config} = $config;
		$data->{gateway} = $session->config->get("gateway");
		$data->{sitename} = $session->config->get("sitename")->[0];
		$kernel->yield("addJob", $data);
	}
	$session->close;
}

#-------------------------------------------------------------------

=head2 new ( config, logger, workflow, [ debug ] )

Constructor.

=head3 config

A WebGUI::Config object that represents the spectre.conf file.

=head3 logger

A reference to the logger object.

=head3 workflow

A reference to the Worfklow session.

=head3 debug

A boolean indicating Spectre should spew forth debug as it runs.

=cut

sub new {
	my $class = shift;
	my $config  = shift;
	my $logger = shift;
	my $workflowSession = shift;
	my $debug = shift;
	my $self = {_debug=>$debug, _workflowSession=>$workflowSession, _config=>$config, _logger=>$logger};
	bless $self, $class;
	my @publicEvents = qw(runJob runJobResponse addJob deleteJob);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop runJob runJobResponse addJob deleteJob checkSchedules checkSchedule loadSchedule), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}


#-------------------------------------------------------------------

=head2 runJob ( )

Calls a worker to execute a cron job.

=cut

sub runJob {
	my ($kernel, $self, $job, $session) = @_[KERNEL, OBJECT, ARG0, SESSION];
	$self->debug("Preparing to run a scheduled job ".$job->{taskId}.".");
	POE::Component::Client::UserAgent->new;
	if ($job->{sitename} eq "" || $job->{config} eq "" || $job->{taskId} eq "") {
		$self->error("Warning: A scheduled task has corrupt information and is nat able to be run. Skipping execution.");
		$kernel->yield("deleteJob",{config=>$job->{config}, taskId=>$job->{taskId}}) if ($job->{config} ne "" && $job->{taskId} ne "");
	} else {
		my $url = "http://".$job->{sitename}.':'.$self->config->get("webguiPort").$job->{gateway};
		my $request = POST $url, [op=>"runCronJob", taskId=>$job->{taskId}];
		my $cookie = $self->{_cookies}{$job->{sitename}};
		$request->header("Cookie","wgSession=".$cookie) if (defined $cookie);
		$request->header("User-Agent","Spectre");
		$request->header("X-taskId",$job->{taskId});
		$request->header("X-config",$job->{config});
		$self->debug("Posting schedule job ".$job->{taskId}." to $url.");
		$kernel->post( useragent => 'request', { request => $request, response => $session->postback('runJobResponse') });
		$self->debug("Cron job ".$job->{taskId}." posted.");
	}
}

#-------------------------------------------------------------------

=head2 runJobResponse ( )

This method is called when the response from the runJob() method is received.

=cut

sub runJobResponse {
	my ($self, $kernel) = @_[OBJECT, KERNEL];	
	$self->debug("Retrieving response from scheduled job.");
        my ($request, $response, $entry) = @{$_[ARG1]};
	my $taskId = $request->header("X-taskId");	# got to figure out how to get this from the request, cuz the response may die
	my $config = $request->header("X-config");	# got to figure out how to get this from the request, cuz the response may die
	$self->debug("Response retrieved is for scheduled task $config / $taskId.");
	my $job = $self->{_jobs}{$config}{$taskId};
	if ($response->is_success) {
		$self->debug("Response for scheduled task $config / $taskId retrieved successfully.");
		if ($response->header("Cookie") ne "") {
			$self->debug("Storing cookie for $config / $taskId for later use.");
			my $cookie = $response->header("Set-Cookie");
			$cookie =~ s/wgSession=([a-zA-Z0-9\_\-]{22})/$1/;
			$self->{_cookies}{$job->{sitename}} = $cookie;
		}
		my $state = $response->content; 
		if ($state eq "done") {
			$self->debug("Scheduled task $config / $taskId is now complete.");
			if ($job->{runOnce}) {
				$kernel->yield("deleteJob",{config=>$job->{config}, taskId=>$job->{taskId}});
			}
		} elsif ($state eq "error") {
			$self->debug("Got an error response for scheduled task $config / $taskId, will try again in ".$self->config->get("suspensionDelay")." seconds.");
			$kernel->delay_set("runJob",$self->config->get("suspensionDelay"),$job);
		} else {
			$self->error("Something bad happened on the return of scheduled task $config / $taskId, will try again in ".$self->config->get("suspensionDelay").". ".$response->error_as_HTML);
			$kernel->delay_set("runJob",$self->config->get("suspensionDelay"),$job);
		}
	} elsif ($response->is_redirect) {
		$self->debug("Response for $config / $taskId was redirected.");
	} elsif ($response->is_error) {	
		$self->error("Response for scheduled task $config / $taskId had a communications error. ".$response->error_as_HTML);
		$kernel->delay_set("runJob",$self->config->get("suspensionDelay"),$job);
		# we should probably log something
	}
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

