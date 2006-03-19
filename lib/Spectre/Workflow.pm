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
        $kernel->yield("checkInstances");
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

=head2 addInstance ( params )

Adds a workflow instance to the workflow processing queue.

=head3 params

A hash reference containing important information about the workflow instance to add to the queue.

=head4 sitename

The host and domain of the site this instance belongs to.

=head3 instanceId

The unqiue id for this workflow instance.

=head3 priority

The priority (1,2, or 3) that this instance should be run at.

=cut

sub addInstance {
	my ($self, $params) = @_[OBJECT, ARG0];
	$self->debug("Adding workflow instance ".$params->{instanceId}." from ".$params->{sitename}." to queue at priority ".$params->{priority}.".");
	$self->{_instances}{$params->{instanceId}} = {
		sitename=>$params->{sitename},
		instanceId=>$params->{instanceId},
		status=>"waiting",
		priority=>$params->{priority}
		};
	push(@{$self->{"_priority".$params->{priority}}}, $params->{instanceId});
}

#-------------------------------------------------------------------

=head2 checkInstances ( )

Checks to see if there are any open instance slots available, and if there are assigns a new instance to be run to fill it.

=cut

sub checkInstances {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	$self->debug("Checking to see if we can run anymore instances right now.");
	if ($self->countRunningInstances < $self->config->get("maxWorkers")) {
		my $instance = $self->getNextInstance;
		if (defined $instance) {
			# mark it running so that it doesn't run twice at once
			$instance->{status} = "running";
			push(@{$self->{_runningInstances}}, $instance->{instanceId});
			# put it at the end of the queue so that others get a chance
			my $priority = $self->{_instances}{$instance->{instanceId}}{priority};
			for (my $i=0; $i < scalar(@{$self->{"_priority".$priority}}); $i++) {
				if ($self->{"_priority".$priority}[$i] eq $instance->{instanceId}) {
					splice(@{$self->{"_priority".$priority}}, $i, 1);
				}
			}
			push(@{$self->{"_priority".$priority}}, $instance->{instanceId});
			# run it already
			$kernel->yield("runWorker",$instance);
		}
	}	
	$kernel->delay_set("checkInstances",$self->config->get("timeBetweenRunningWorkflows"));
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

=head2 countRunningInstances ( )

Returns an integer representing the number of running instances.

=cut

sub countRunningInstances {
	my $self = shift;
	my $runningInstances = $self->{_runningInstances} || [];
	my $instanceCount = scalar(@{$runningInstances});
	$self->debug("There are $instanceCount running instances.");
	return $instanceCount;
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

=head2 deleteInstance ( instanceId ) 

Removes a workflow instance from the processing queue.

=cut

sub deleteInstance {
	my ($self, $instanceId,$kernel, $session ) = @_[OBJECT, ARG0, KERNEL, SESSION];
	$kernel->call($session, "returnInstanceToQueue",$instanceId);	
	$self->debug("Deleting workflow instance $instanceId from instance queue.");
	if ($self->{_instances}{$instanceId}) {
		my $priority = $self->{_instances}{$instanceId}{priority};
		delete $self->{_instances}{$instanceId};
		for (my $i=0; $i < scalar(@{$self->{"_priority".$priority}}); $i++) {
			if ($self->{"_priority".$priority}[$i] eq $instanceId) {
				splice(@{$self->{"_priority".$priority}}, $i, 1);
			}
		}
	}
}

#-------------------------------------------------------------------

=head2 getNextInstance ( )

=cut

sub getNextInstance {
	my $self = shift;
	$self->debug("Looking for a workflow instance to run.");
	foreach my $priority (1..3) {
		foreach my $instanceId (@{$self->{"_priority".$priority}}) {
			if ($self->{_instances}{$instanceId}{status} eq "waiting") {
				$self->debug("Looks like ".$instanceId." would be a good workflow instance to run.");
				return $self->{_instances}{$instanceId};
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
	my $result = $session->db->read("select instanceId,priority from WorkflowInstance");
	while (my ($id, $priority) = $result->array) {
		$kernel->yield("addInstance", {sitename=>$config->get("sitename")->[0], instanceId=>$id, priority=>$priority});
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
	my @publicEvents = qw(addInstance deleteInstance);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop returnInstanceToQueue addInstance checkInstances deleteInstance suspendInstance loadWorkflows runWorker workerResponse), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}

#-------------------------------------------------------------------

=head2 returnInstanceToQueue ( )

Returns a workflow instance back to runnable queue.

=cut

sub returnInstanceToQueue {
	my ($self, $instanceId) = @_[OBJECT, ARG0];
	$self->debug("Returning ".$instanceId." to runnable queue.");
	if ($self->{_instances}{$instanceId}) {
		$self->{_instances}{$instanceId}{status} = "waiting";
		for (my $i=0; $i < scalar(@{$self->{_runningInstances}}); $i++) {
			if ($self->{_runningInstances}[$i] eq $instanceId) {
				splice(@{$self->{_runningInstances}}, $i, 1);
			}
		}
	}
}

#-------------------------------------------------------------------

=head2 runWorker ( )

Calls a worker to execute a workflow activity.

=cut

sub runWorker {
	my ($kernel, $self, $instance, $session) = @_[KERNEL, OBJECT, ARG0, SESSION];
	$self->debug("Preparing to run workflow instance ".$instance->{instanceId}.".");
	POE::Component::Client::UserAgent->new;
	my $url = "http://".$instance->{sitename}.'/';
	my $request = POST $url, [op=>"runWorkflow", instanceId=>$instance->{instanceId}];
	my $cookie = $self->{_cookies}{$instance->{sitename}};
	$request->header("Cookie","wgSession=".$cookie) if (defined $cookie);
	$request->header("User-Agent","Spectre");
	$request->header("X-instanceId",$instance->{instanceId});
	$self->debug("Posting workflow instance ".$instance->{instanceId}." to $url.");
	$kernel->post( useragent => 'request', { request => $request, response => $session->postback('workerResponse') });
	$self->debug("Workflow instance ".$instance->{instanceId}." posted.");
}

#-------------------------------------------------------------------

=head2 suspendInstance ( ) 

Suspends a workflow instance for a number of seconds defined in the config file, and then returns it to the runnable queue.

=cut

sub suspendInstance {
	my ($self, $instanceId, $kernel) = @_[OBJECT, ARG0, KERNEL];
	$self->debug("Suspending workflow instance ".$instanceId." for ".$self->config->get("suspensionDelay")." seconds.");
	$kernel->delay_set("returnInstanceToQueue",$self->config->get("suspensionDelay"), $instanceId);
}

#-------------------------------------------------------------------

=head2 workerResponse ( )

This method is called when the response from the runWorker() method is received.

=cut

sub workerResponse {
	my ($self, $kernel) = @_[OBJECT, KERNEL];
	$self->debug("Retrieving response from workflow instance.");
        my ($request, $response, $entry) = @{$_[ARG1]};
	my $instanceId = $request->header("X-instanceId");	# got to figure out how to get this from the request, cuz the response may die
	$self->debug("Response retrieved is for $instanceId.");
	if ($response->is_success) {
		$self->debug("Response for $instanceId retrieved successfully.");
		if ($response->header("Cookie") ne "") {
			$self->debug("Storing cookie for $instanceId for later use.");
			my $cookie = $response->header("Set-Cookie");
			$cookie =~ s/wgSession=([a-zA-Z0-9\_\-]{22})/$1/;
			$self->{_cookies}{$self->{_instances}{$instanceId}{sitename}} = $cookie;
		}
		my $state = $response->content; 
		if ($state eq "waiting") {
			$self->debug("Was told to wait on $instanceId because we're still waiting on some external event.");
			$kernel->yield("suspendInstance",$instanceId);
		} elsif ($state eq "complete") {
			$self->debug("Workflow instance $instanceId ran one of it's activities successfully.");
			$kernel->yield("returnInstanceToQueue",$instanceId);
		} elsif ($state eq "disabled") {
			$self->debug("Workflow instance $instanceId is disabled.");
			$kernel->yield("suspendInstance",$instanceId);			
		} elsif ($state eq "done") {
			$self->debug("Workflow instance $instanceId is now complete.");
			$kernel->yield("deleteInstance",$instanceId);			
		} elsif ($state eq "error") {
			$self->debug("Got an error for $instanceId.");
			$kernel->yield("suspendInstance",$instanceId);
		} else {
			$self->debug("Something bad happened on the return of $instanceId.");
			$kernel->yield("suspendInstance",$instanceId);
		}
	} elsif ($response->is_redirect) {
		$self->debug("Response for $instanceId was redirected.");
	} elsif ($response->is_error) {	
		$self->debug("Response for $instanceId had a communications error.");
		$kernel->yield("suspendInstance",$instanceId)
		# we should probably log something
	}
}



1;


