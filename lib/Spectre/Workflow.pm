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
	$self->{"_priority".$job->{priority}}{$job->{instanceId}} = {
		instanceId=>$job->{instanceId},
		config=>$config,
		status=>"waiting"
		};
}

#-------------------------------------------------------------------

=head2 checkJobs ( )

Checks to see if there are any open job slots available, and if there are assigns a new job to be run to fill it.

=cut

sub checkJobs {
	my ($kernel, $self) = @_[KERNEL, OBJECT];
	if ($self->countRunningJobs < 5) {
		my $job = $self->getNextJob;
		$job->{status} = "running";
		$kernel->yield("runJob",$job);
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
	delete $self->{_priority1}{$instanceId};
	delete $self->{_priority2}{$instanceId};
	delete $self->{_priority3}{$instanceId};
}


#-------------------------------------------------------------------

=head2 getNextJob ( )

=cut

sub getNextJob {
	my $self = shift;
	foreach my $priority (1..3) {
		foreach my $instanceId (keys %{$self->{"_priority".$priority}}) {
			if ($self->{"_priority".$priority}{$instanceId}{status} eq "waiting") {
				return $self->{"_priority".$priority}{$instanceId};
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
		object_states => [ $self => [qw(_start _stop checkJobs loadWorkflows runJob), @publicEvents] ],
		args=>[\@publicEvents]
        	);
}

1;


