package Spectre::Workflow;

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
use HTTP::Request::Common;
use POE;
use POE::Component::Client::UserAgent;

#-------------------------------------------------------------------

=head2 _start ( )

Initializes the workflow manager.

=cut

sub _start {
        my ( $kernel, $self, $publicEvents) = @_[ KERNEL, OBJECT, ARG0 ];
	$self->debug("Starting workflow manager.");
        my $serviceName = "workflow";
        $kernel->alias_set($serviceName);
        $kernel->call( IKC => publish => $serviceName, $publicEvents );
	$self->debug("Reading workflow configs.");
	my $configs = WebGUI::Config->readAllConfigs($self->config->getWebguiRoot);
	foreach my $config (keys %{$configs}) {
		$kernel->yield("loadWorkflows", $configs->{$config});
	}
        $kernel->yield("checkJobs");
}

#-------------------------------------------------------------------

=head2 _stop ( )

Gracefully shuts down the workflow manager.

=cut

sub _stop {
	my ($kernel, $self) = @_[KERNEL, OBJECT];	
	$self->debug("Stopping workflow manager.");
	undef $self;
}



#-------------------------------------------------------------------

=head2 addJob ( config, job )

Adds a workflow job to the workflow processing queue.

=head3 config

The config file name for the site that this job belongs to.

=head3 job

A hash reference containing a row of data from the WorkflowInstance table.

=cut

sub addJob {
	my ($self, $config, $job) = @_[OBJECT, ARG0, ARG1];
	$self->debug("Adding workflow instance ".$job->{instanceId}." from ".$config->getFilename."  to job queue at priority ".$job->{priority}.".");
	# job list
	my $sitename = $config->get("sitename");
	$self->{_jobs}{$job->{instanceId}} = {
		sitename=>$sitename->[0],
		instanceId=>$job->{instanceId},
		status=>"waiting",
		priority=>$job->{priority}
		};
	push(@{$self->{"_priority".$job->{priority}}}, $self->{_jobs}{$job->{instanceId}});
}

#-------------------------------------------------------------------

=head2 checkJobs ( )

Checks to see if there are any open job slots available, and if there are assigns a new job to be run to fill it.

=cut

sub checkJobs {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	$self->debug("Checking to see if we can run anymore jobs right now.");
	if ($self->countRunningJobs < $self->config->get("maxWorkers")) {
		my $job = $self->getNextJob;
		if (defined $job) {
			$job->{status} = "running";
			push(@{$self->{_runningJobs}}, $job);
			$kernel->yield("runWorker",$job);
		}
	}	
	$kernel->delay_set("checkJobs",$self->config->get("timeBetweenJobs"));
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

=head2 countRunningJobs ( )

Returns an integer representing the number of running jobs.

=cut

sub countRunningJobs {
	my $self = shift;
	my $runningJobs = $self->{_runningJobs} || [];
	my $jobCount = scalar(@{$runningJobs});
	$self->debug("There are $jobCount running jobs.");
	return $jobCount;
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
		print "WORKFLOW: ".$output."\n";
	}
}

#-------------------------------------------------------------------

=head2 deleteJob ( instanceId ) 

Removes a workflow job from the processing queue.

=cut

sub deleteJob {
	my ($self, $instanceId) = @_[OBJECT, ARG0];
	$self->debug("Deleting workflow instance $instanceId from job queue.");
	my $priority = $self->{_jobs}{$instanceId}{priority};
	delete $self->{_jobs}{$instanceId};
	for (my $i=0; $i < scalar(@{$self->{"_priority".$priority}}); $i++) {
		if ($self->{"_priority".$priority}[$i]{instanceId} eq $instanceId) {
			splice(@{$self->{"_priority".$priority}}, $i, 1);
		}
	}
}

#-------------------------------------------------------------------

=head2 getNextJob ( )

=cut

sub getNextJob {
	my $self = shift;
	$self->debug("Looking for a workflow instance to execute.");
	foreach my $priority (1..3) {
		foreach my $job (@{$self->{"_priority".$priority}}) {
			if (time() > $job->{statusDelay} & $job->{status}) {
				delete $job->{statusDelay};
				$job->{status} eq "waiting";
			}
			if ($job->{status} eq "waiting") {
				$self->debug("Looks like ".$job->{instanceId}." would be a good workflow instance to run.");
				return $job;
			}
		}
	}
	$self->debug("Didn't see any workflow instances to run.");
	return undef;
}

#-------------------------------------------------------------------

=head2 loadWorkflows ( )

=cut 

sub loadWorkflows {
	my ($kernel, $self, $config) = @_[KERNEL, OBJECT, ARG0];
	$self->debug("Loading workflows for ".$config->getFilename.".");
	my $session = WebGUI::Session->open($config->getWebguiRoot, $config->getFilename);
	my $result = $session->db->read("select * from WorkflowInstance");
	while (my $data = $result->hashRef) {
		$kernel->yield("addJob", $config, $data);
	}
	$session->close;
}

#-------------------------------------------------------------------

=head2 new ( config [ , debug ] )

Constructor. Loads all active workflows from each WebGUI site and begins executing them.

=head3 config

The path to the root of the WebGUI installation.

=head3 debug

A boolean indicating Spectre should spew forth debug as it runs.

=cut

sub new {
	my $class = shift;
	my $config = shift;
	my $debug = shift;
	my $self = {_debug=>$debug, _config=>$config};
	bless $self, $class;
	my @publicEvents = qw(addJob deleteJob);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop checkJobs loadWorkflows runWorker), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}

#-------------------------------------------------------------------

=head2 runWorker ( )

Calls a worker to execute a workflow activity.

=cut

sub runWorker {
	my ($kernel, $self, $job, $session) = @_[KERNEL, OBJECT, ARG0, SESSION];
	$self->debug("Preparing to run workflow instance ".$job->{instanceId}.".");
	POE::Component::Client::UserAgent->new;
	my $url = "http://".$job->{sitename}.'/';
	my $request = POST $url, [op=>"runWorkflow", instanceId=>$job->{instanceId}];
	my $cookie = $self->{_cookies}{$job->{sitename}};
	$request->header("Cookie","wgSession=".$cookie) if (defined $cookie);
	$request->header("User-Agent","Spectre");
	$request->header("X-JobId",$job->{instanceId});
	$self->debug("Posting workflow instance ".$job->{instanceId}." to $url.");
	$kernel->post( useragent => 'request', { request => $request, response => $session->postback('workerResponse') });
	$self->debug("Workflow instance ".$job->{instanceId}." posted.");
}

#-------------------------------------------------------------------

=head2 suspendJob ( jobId ) 

This method puts a running job back into the available jobs pool thusly freeing up a slot in the running jobs pool. This is done when a job has executed a workflow activity, but the entire workflow has not yet completed.

=head3 jobId

The job being suspended.

=cut

sub suspendJob {
	my $self = shift;
	my $instanceId = shift;
	$self->debug("Suspending workflow instance ".$instanceId.".");
	$self->{_jobs}{$instanceId}{status} = "delay";
	$self->{_jobs}{$instanceId}{statusDelay} = $self->config->get("delayAfterSuspension") + time();
	for (my $i=0; $i < scalar(@{$self->{_runningJobs}}); $i++) {
		if ($self->{_runningJobs}[$i]{instanceId} eq $instanceId) {
			splice(@{$self->{_runningJobs}}, $i, 1);
		}
	}
}

#-------------------------------------------------------------------

=head2 workerResponse ( )

This method is called when the response from the runWorker() method is received.

=cut

sub workerResponse {
	my $self = $_[OBJECT];
	$self->debug("Retrieving response from workflow instance job.");
        my ($request, $response, $entry) = @{$_[ARG1]};
	my $jobId = $request->header("X-JobId");	# got to figure out how to get this from the request, cuz the response may die
	$self->debug("Response retrieved is for $jobId.");
	if ($response->is_success) {
		$self->debug("Response for $jobId retrieved successfully.");
		if ($response->header("Cookie") ne "") {
			$self->debug("Storing cookie for $jobId for later use.");
			my $cookie = $response->header("Set-Cookie");
			$cookie =~ s/wgSession=([a-zA-Z0-9\_\-]{22})/$1/;
			$self->{_cookies}{$self->{_jobs}{$jobId}{sitename}} = $cookie;
		}
		my $state = $response->content; 
		if ($state eq "waiting") {
			$self->debug("Was told to wait on $jobId because we're still waiting on some external event.");
			$self->suspendJob($jobId);
		} elsif ($state eq "complete") {
			$self->debug("Workflow instance $jobId ran one of it's activities successfully.");
			$self->suspendJob($jobId);
		} elsif ($state eq "disabled") {
			$self->debug("Workflow instance $jobId is disabled.");
			$self->deleteJob($jobId);			
		} elsif ($state eq "done") {
			$self->debug("Workflow instance $jobId is now complete.");
			$self->deleteJob($jobId);			
		} elsif ($state eq "error") {
			$self->debug("Got an error for $jobId.");
			$self->suspendJob($jobId);
		} else {
			$self->debug("Something bad happened on the return of $jobId.");
			$self->suspendJob($jobId);
			# something bad happened
		}
	} elsif ($response->is_redirect) {
		$self->debug("Response for $jobId was redirected.");
	} elsif ($response->is_error) {	
		$self->debug("Response for $jobId had a communications error.");
		$self->suspendJob($jobId)
		# we should probably log something
	}
}



1;


