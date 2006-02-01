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


#-------------------------------------------------------------------

=head2 addJob ( config, job )

Adds a workflow job to the workflow processing queue.

=head3 config

The config file name for the site that this job belongs to.

=head3 job

A hash reference containing a row of data from the WorkflowInstance table.

=cut

sub addJob {
	my $self = shift;
	my $config = shift;
	my $job = shift;	
	$self->{"_priority".$job->{priority}}{$job->{instanceId}} = {
		config=>$config,
		status=>"waiting"
		};
}

#-------------------------------------------------------------------

=head2 deleteJob ( instanceId ) 

Removes a workflow job from the processing queue.

=cut

sub deleteJob {
	my $self = shift;
	delete $self->{_priority1}{shift};
	delete $self->{_priority2}{shift};
	delete $self->{_priority3}{shift};
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

=head2 getNextJob ( )

=cut

sub getNextJob {
	my $self = shift;
	foreach my $priority (1..3) {
		foreach my $instanceId (keys %{$self->{"_priority".$priority}}) {
			if ($self->{"_priority".$priority}{status} eq "waiting") {
				
		}
	}
	return undef;
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
	my $configs = WebGUI::Config->readAllConfigs($webguiRoot);
	foreach my $config (keys %{$configs}) {
		my $session = WebGUI::Session->open($webguiRoot, $config);
		my $result = $session->db->read("select * from WorkflowInstance");
		while (my $data = $result->hashRef) {
			$self->addJob($config, $data);
		}
		$session->close;
	}
}


1;


