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
use POE;
use POE::Component::Client::UserAgent;

#-------------------------------------------------------------------

=head2 _start ( )

Initializes the workflow manager.

=cut

sub _start {
        print "Starting WebGUI Spectre Workflow Manager...";
        my ( $kernel, $self, $publicEvents) = @_[ KERNEL, OBJECT, ARG0 ];
        my $serviceName = "workflow";
        $kernel->alias_set($serviceName);
        $kernel->call( IKC => publish => $serviceName, $publicEvents );
	my $configs = WebGUI::Config->readAllConfigs($self->{_webguiRoot});
	foreach my $config (keys %{$configs}) {
		$kernel->yield("loadWorkflows", $config);
	}
        print "OK\n";
        $kernel->yield("checkJobs");
}

#-------------------------------------------------------------------

=head2 _stop ( )

Gracefully shuts down the workflow manager.

=cut

sub _stop {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	print "Stopping WebGUI Spectre Workflow Manager...";
	undef $self;
	print "OK\n";
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
	# job list
	$self->{_jobs}{$job->{instanceId}} = {
		instanceId=>$job->{instanceId},
		config=>$config,
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
	if ($self->countRunningJobs < 5) {
		my $job = $self->getNextJob;
		if (defined $job) {
			$job->{status} = "running";
			push(@{$self->{_runningJobs}}, $job);
			$kernel->yield("runWorker",$job);
		}
	}	
}

#-------------------------------------------------------------------

=head2 countRunningJobs ( )

Returns an integer representing the number of running jobs.

=cut

sub countRunningJobs {
	my $self = shift;
	return scalar(@{$self->{_runningJobs}});
}

#-------------------------------------------------------------------

=head2 deleteJob ( instanceId ) 

Removes a workflow job from the processing queue.

=cut

sub deleteJob {
	my ($self, $instanceId) = @_[OBJECT, ARG0];
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
	foreach my $priority (1..3) {
		foreach my $job (@{$self->{"_priority".$priority}}) {
			if ($job->{status} eq "waiting") {
				return $job;
			}
		}
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 loadWorkflows ( )

=cut 

sub loadWorkflows {
	my ($kernel, $self, $config) = @_[KERNEL, OBJECT, ARG0];
	my $session = WebGUI::Session->open($self->{_webguiRoot}, $config);
	my $result = $session->db->read("select * from WorkflowInstance");
	while (my $data = $result->hashRef) {
		$kernel->yield("addJob", $config, $data);
	}
	$session->close;
}

#-------------------------------------------------------------------

=head2 new ( webguiRoot )

Constructor. Loads all active workflows from each WebGUI site and begins executing them.

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
	POE::Component::Client::UserAgent->new;
	my $url = $job->{sitename}.'/'.$job->{gateway};
	$url =~ s/\/\//\//g;
	$url = "http://".$url."?op=spectre;instanceId=".$job->{instanceId};
	$kernel->post( useragent => 'request', { request => HTTP::Request->new(GET => $url), response => $session->postback('workerResponse') });
}

#-------------------------------------------------------------------

=head2 suspendJob ( jobId ) {

This method puts a running job back into the available jobs pool thusly freeing up a slot in the running jobs pool. This is done when a job has executed a workflow activity, but the entire workflow has not yet completed.

=head3 jobId

The job being suspended.

=cut

sub suspendJob {
	my $self = shift;
	my $instanceId = shift;
	$self->{_jobs}{$instanceId}{status} = "waiting";
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
        my ($request, $response, $entry) = @{$_[ARG1]};
	my $jobId = "";	# got to figure out how to get this from the request, cuz the response may die
	if ($response->is_success) {
		my $state = ""; # get the response
		if ($state eq "continue") {
			$self->suspendJob($jobId);
		} elsif ($state eq "done") {
			$self->deleteJob($jobId);			
		} else {
			$self->suspendJob($jobId);
			# something bad happened
		}
	} elsif ($response->is_redirect) {
		# nothing to do, cuz we're following the redirect to see what happens
	} elsif ($response->is_error) {	
		$self->suspendJob($jobId)
		# we should probably log something
	}
}



1;


