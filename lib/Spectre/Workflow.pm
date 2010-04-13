package Spectre::Workflow;

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
use HTTP::Request::Common;
use HTTP::Cookies;
use POE qw(Component::Client::HTTP);
use Tie::IxHash;
use JSON qw/ encode_json /;
use Clone qw(clone);

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

=head4 instanceId

The unqiue id for this workflow instance.

=head4 priority

The priority (1,2, or 3) that this instance should be run at.

=cut

sub addInstance {
	my ($self, $instance) = @_[OBJECT, ARG0];
    if ($instance->{priority} < 1 || $instance->{instanceId} eq "" || $instance->{sitename} eq "") {
        $self->error("Can't add workflow instance with missing data: ". $instance->{sitename}." - ".$instance->{instanceId});
    } 
    else {
        $instance->{workingPriority} = ($instance->{priority} -1) * 10;
	    $instance->{lastState} = 'never run';
        $instance->{status} = 'waiting';
	    $self->debug("Adding workflow instance ".$instance->{instanceId}." from ".$instance->{sitename}." to queue at priority ".$instance->{workingPriority}.".");
        $self->{_queue}{$instance->{instanceId}} = $instance; 
    }
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
			$kernel->yield("runWorker",$instance);
		}
	}	
	$kernel->delay_set("checkInstances",$self->config->get("timeBetweenRunningWorkflows"));
}

#-------------------------------------------------------------------

=head2 config ( )

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
    my $count = 0;
    foreach my $instance ($self->getInstances) {
        if ($instance->{status} eq 'running') {
            $count++; 
        }
    }
	$self->debug("There are $count running instances.");
	return $count;
}

#-------------------------------------------------------------------

=head2 debug ( output )

Prints out debug information if debug is enabled.

=head3 output

The debug message to be printed if debug is enabled.

=cut 

sub debug {
	my $self = shift;
	my $output = shift;
	if ($self->{_debug}) {
		print "WORKFLOW: ".$output."\n";
	}
	$self->getLogger->debug("WORKFLOW: ".$output);
}

#-------------------------------------------------------------------

=head2 deleteInstance ( instanceId ) 

Removes a workflow instance from the processing queue.

=cut

sub deleteInstance {
	my ($self, $instanceId,$kernel, $session ) = @_[OBJECT, ARG0, KERNEL, SESSION];
	$self->debug("Deleting workflow instance $instanceId from queue.");
    delete $self->{_queue}{$instanceId};
}

#-------------------------------------------------------------------

=head2 editWorkflowPriority ( href ) 

Updates the priority of a given workflow instance.

=head3 href

Contains information about the instance and the new priority.

=head4 instanceId

The id of the instance to update.

=head4 newPriority

The new priority value.

=cut

sub editWorkflowPriority {
    my ($self, $request, $kernel, $session ) = @_[OBJECT, ARG0, KERNEL, SESSION];
    my ($argsHref, $rsvp) = @$request;

    my $instanceId  = $argsHref->{instanceId};
    my $newPriority = $argsHref->{newPriority};

    $self->debug("Updating the priority of $instanceId to $newPriority.");

    my $instance = $self->getInstance($instanceId);

    if (defined $instance) {
        $instance->{priority} = $newPriority;
        $instance->{workingPriority} = ($instance->{priority} -1) * 10;
        $self->updateInstance($instance);
        # return success message
        $kernel->call(IKC=>post=>$rsvp, encode_json({message => 'edit priority success'}));
    }
    else {
        # return an error message
        my $error = 'edit priority instance not found error';
        $kernel->call(IKC=>post=>$rsvp, encode_json({message => $error}));
    }
}

#-------------------------------------------------------------------

=head2 error ( output )

Prints out error information if debug is enabled.

=head3 output

The error message to be printed if debug is enabled.

=cut 

sub error {
    my ($self, $output) = @_;
	if ($self->{_debug}) {
		print "WORKFLOW: [Error] ".$output."\n";
	}
	$self->getLogger->error("WORKFLOW: ".$output);
}

#-------------------------------------------------------------------

=head2 getInstance ( instanceId )

Returns the properties of an instance.

=head3 instanceId

The id of the instance to retrieve.

=cut

sub getInstance {
    my ($self, $instanceId) = @_;
    return clone($self->{_queue}{$instanceId});
}


#-------------------------------------------------------------------

=head2 getInstances (  )

Returns the array of instances from the queue.

=cut

sub getInstances {
    my ($self) = @_;
    my @instances = values %{$self->{_queue}};
    return @{clone(\@instances)};
}

#-------------------------------------------------------------------

=head2 getJsonStatus ( )

Returns JSON report about the workflow engine. Depricated, use getStatus() instead.

=cut

sub getJsonStatus {
    my ($kernel, $request, $self) = @_[KERNEL,ARG0,OBJECT];
    my ($sitename, $rsvp) = @$request;
    my %queues = (
            Waiting => [],
            Suspended => [],
            Running => [],
            );
    my %output;
    if ($sitename) { #must have entry for each queue
        %output = %queues;
        foreach my $instance ($self->getInstances) {
            my $queue = ucfirst($instance->{status});
            push @{$output{$queue}}, [$instance->{workingPriority}, $instance->{instanceId}, $instance];
        }
    }
    else {
        foreach my $instance ($self->getInstances) {
            my $site = $instance->{sitename};
            unless (exists $output{$site}) { # must have an entry for each queue in each site
                $output{$site} = clone \%queues;
            }
            my $queue = ucfirst($instance->{status});
            push @{$output{$site}{$queue}}, $instance;
        }
    }
    $kernel->call(IKC=>post=>$rsvp, encode_json(\%output));
}

#-------------------------------------------------------------------

=head2 getStatus ( )

Returns JSON report about the workflow engine. Returns an array reference of hash references of instance data. Each instance contains the following fields: instanceId, status, lastState, sitename, priority, and workingPriority.

=cut

sub getStatus {
    my ($kernel, $request, $self) = @_[KERNEL,ARG0,OBJECT];
    my ($data, $rsvp) = @$request;
    my @instances = $self->getInstances;
    $kernel->call(IKC=>post=>$rsvp, encode_json(\@instances));
}

#-------------------------------------------------------------------

=head2 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
	my $self = shift;
	return $self->{_logger};
}

#-------------------------------------------------------------------

=head2 getNextInstance ( )

Returns the next available instance.

=cut

sub getNextInstance {
	my $self = shift;
	$self->debug("Looking for a workflow instance to run.");
    my @instances = $self->getInstances;
	if (scalar(@instances) > 0) {
        my $lowInstance = {};
        my $lowPriority = 999999999999;
        my $waitingCount = 0;
        foreach my $instance (@instances) {
            next unless $instance->{status} eq 'waiting';
            $waitingCount++;
            if ($instance->{workingPriority} < $lowPriority) {
                $lowInstance = $instance;
                $lowPriority = $instance->{workingPriority};
            }
        }
		$self->debug("Total workflows waiting to run: ".$waitingCount);
        if ($lowInstance->{instanceId} ne '') {
		    $self->debug("Looks like ".$lowInstance->{instanceId}." would be a good workflow instance to run.");
		    return $lowInstance;
        }
	}
	$self->debug("Didn't see any workflow instances to run.");
	return undef;
}

#-------------------------------------------------------------------

=head2 new ( config, logger, [ , debug ] )

Constructor. Loads all active workflows from each WebGUI site and begins executing them.

=head3 config

The config object for spectre.

=head3 logger

A reference to the logger object.

=head3 debug

A boolean indicating Spectre should spew forth debug as it runs.

=cut

sub new {
	my $class = shift;
	my $config = shift;
	my $logger = shift;
	my $debug = shift;
	my $self = {_debug=>$debug, _config=>$config, _logger=>$logger};
	bless $self, $class;
	my @publicEvents = qw(addInstance deleteInstance editWorkflowPriority getStatus getJsonStatus);
	POE::Session->create(
		object_states => [ $self => [qw(_start _stop returnInstanceToRunnableState addInstance checkInstances deleteInstance suspendInstance runWorker workerResponse), @publicEvents] ],
		args=>[\@publicEvents]
        	);
	my $cookies = HTTP::Cookies->new(file => '/tmp/cookies');
	POE::Component::Client::HTTP->spawn(
		Agent => 'Spectre',
		Alias => 'workflow-ua',
		CookieJar => $cookies
  		);
	$self->{_queue} = {};
}


#-------------------------------------------------------------------

=head2 returnInstanceToRunnableState ( )

Returns a workflow instance back to runnable queue.

=cut

sub returnInstanceToRunnableState {
	my ($self, $instance) = @_[OBJECT, ARG0];
	$self->debug("Returning ".$instance->{instanceId}." to runnable state.");
    $instance->{status} = 'waiting';
    $self->updateInstance($instance);
}

#-------------------------------------------------------------------

=head2 runWorker ( )

Calls a worker to execute a workflow activity.

=cut

sub runWorker {
	my ($kernel, $self, $instance, $session) = @_[KERNEL, OBJECT, ARG0, SESSION];
	$self->debug("Preparing to run workflow instance ".$instance->{instanceId}.".");
    $self->debug("Incrementing ".$instance->{instanceId}." priority from ".$instance->{workingPriority});
	$instance->{workingPriority}++;
    $instance->{status} = 'running';
    $self->updateInstance($instance);
	my $url = "http://".$instance->{sitename}.':'.$self->config->get("webguiPort").$instance->{gateway};
	my $request = POST $url, [op=>"runWorkflow", instanceId=>$instance->{instanceId}];
	my $cookie = $self->{_cookies}{$instance->{sitename}};
	$request->header("Cookie",$instance->{cookieName}."=".$cookie) if (defined $cookie);
	$request->header("X-instanceId",$instance->{instanceId});
	$request->header("User-Agent","Spectre");
	$self->debug("Posting workflow instance ".$instance->{instanceId}." to $url.");
	$kernel->post('workflow-ua','request', 'workerResponse', $request);
	$self->debug("Workflow instance ".$instance->{instanceId}." posted.");
}

#-------------------------------------------------------------------

=head2 suspendInstance ( ) 

Suspends a workflow instance for a number of seconds defined in the config file, and then returns it to the runnable queue.

=cut

sub suspendInstance {
    my ($self, $kernel, $instance, $waitTimeout) = @_[OBJECT, KERNEL, ARG0, ARG1];
    $waitTimeout ||= $self->config->get("suspensionDelay");
    $self->debug("Suspending workflow instance ".$instance->{instanceId}." for ".$waitTimeout." seconds.");
    $instance->{status} = 'suspended';
    $self->updateInstance($instance);
    $kernel->delay_set("returnInstanceToRunnableState", $waitTimeout, $instance);
}

#-------------------------------------------------------------------

=head2 updateInstance ( properties )

Updates an instance's properties.

=head3 properties

A hash reference of the properties of the instance.

=cut

sub updateInstance {
    my ($self, $instance) = @_;
    $self->debug("Updating ".$instance->{instanceId}."'s properties.");
    $self->{_queue}{$instance->{instanceId}} = $instance;
}


#-------------------------------------------------------------------

=head2 workerResponse ( )

This method is called when the response from the runWorker() method is received.

=cut

sub workerResponse {
	my ($self, $kernel, $requestPacket, $responsePacket) = @_[OBJECT, KERNEL, ARG0, ARG1];
	$self->debug("Retrieving response from workflow instance.");
 	my $request  = $requestPacket->[0];
   	my $response = $responsePacket->[0];
	my $instanceId = $request->header("X-instanceId");	# got to figure out how to get this from the request, cuz the response may die
	$self->debug("Response retrieved is for $instanceId.");
	my $instance = $self->getInstance($instanceId);
    unless (defined $instance) {
        $self->debug("Instance $instanceId no longer exist in my queue, so there's no reason to process the response.");
        return;
    }
	if ($response->is_success) {
		$self->debug("Response for $instanceId retrieved successfully.");
		if ($response->header("Set-Cookie") ne "") {
			$self->debug("Storing cookie for $instanceId for later use.");
			my $cookie = $response->header("Set-Cookie");
			my $pattern = $instance->{cookieName}."=([a-zA-Z0-9\_\-]{22}).*";
			$cookie =~ s/$pattern/$1/;
			$self->{_cookies}{$instance->{sitename}} = $cookie;
		}
		my $state = $response->content; 
		$instance->{lastState} = $state;
		$instance->{lastRunTime} = localtime(time());
		if ($state =~ m/^waiting\s*(\d+)?$/) {
            my $waitTime = $1;
			$self->debug("Was told to suspend $instanceId because we're still waiting on some external event.");
			$kernel->yield("suspendInstance",$instance, $waitTime);
		}
        elsif ($state eq "complete") {
			$self->debug("Workflow instance $instanceId ran one of it's activities successfully.");
			$kernel->yield("returnInstanceToRunnableState",$instance);
		}
        elsif ($state eq "disabled") {
			$self->debug("Workflow instance $instanceId is disabled.");
			$kernel->yield("suspendInstance",$instance);			
		}
        elsif ($state eq "done") {
			$self->debug("Workflow instance $instanceId is now complete.");
			$kernel->yield("deleteInstance",$instanceId);			
		}
        elsif ($state eq "error") {
			$self->debug("Got an error response for $instanceId.");
			$kernel->yield("suspendInstance",$instance);
		}
        else {
			$self->error("Something bad happened on the return of $instance->{sitename} - $instanceId. ".$response->code.": ".$response->message);
			$kernel->yield("suspendInstance",$instance);
		}
	}
    elsif ($response->is_redirect) {
		$self->error("Response for $instance->{sitename} - $instanceId was redirected. This should never happen if configured properly!!!");
		$instance->{lastState} = "redirect";
		$instance->{lastRunTime} = localtime(time());
		$kernel->yield("suspendInstance",$instance)
	}
    elsif ($response->is_error) {	
		$instance->{lastState} = "comm error";
		$instance->{lastRunTime} = localtime(time());
		$self->error("Response for $instance->{sitename} - $instanceId had a communications error. ".$response->code.": ".$response->message);
		$kernel->yield("suspendInstance",$instance)
	}
}


1;
