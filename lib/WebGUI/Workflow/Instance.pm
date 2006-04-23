package WebGUI::Workflow::Instance;


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
use JSON;
use WebGUI::Workflow::Spectre;


=head1 NAME

Package WebGUI::Workflow::Instance

=head1 DESCRIPTION

This package provides an API for controlling Spectre/Workflow running instances.

=head1 SYNOPSIS

 use WebGUI::Workflow::Instance

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 create ( session, properties ) 

Creates a new workflow instance and returns a reference to the object. Will return undef if the workflow specified is serial and an instance of it already exists.

=head3 session

A reference to the current session.

=head3 properties

The settable properties of the workflow instance. See the set() method for details.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
	my ($isSingleton) = $session->db->quickArray("select isSingleton from Workflow where workflowId=?",[$properties->{workflowId}]);
	my $params = (exists $properties->{parameters}) ? JSON::objToJson({parameters => $properties->{parameters}}) : undef;
	my ($count) = $session->db->quickArray("select count(*) from WorkflowInstance where workflowId=? and parameters=?",[$properties->{workflowId},$params]);
	return undef if ($isSingleton && $count);
	my $instanceId = $session->db->setRow("WorkflowInstance","instanceId",{instanceId=>"new", runningSince=>time()});
	my $self = $class->new($session, $instanceId);
	$properties->{notifySpectre} = 1 unless ($properties->{notifySpectre} eq "0");
	$self->set($properties);
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this instance.

=cut

sub delete {
	my $self = shift;
	$self->session->db->write("delete from WorkflowInstanceScratch where instanceId=?",[$self->getId]);
	$self->session->db->deleteRow("WorkflowInstance","instanceId",$self->getId);
	WebGUI::Workflow::Spectre->new($self->session)->notify("workflow/deleteInstance",$self->getId);
	undef $self;
}

#-------------------------------------------------------------------

=head2 deleteScratch ( name ) 

Removes a scratch variable that's assigned to this instance.

=head3 name 

The name of the variable to remove.

=cut

sub deleteScratch {
	my $self = shift;
	my $name = shift;
	delete $self->{_scratch}{$name};
	$self->session->db->write("delete from WorkflowInstanceScratch where instanceId=? and name=?", [$self->getId, $name]);
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

=head2 get ( name ) 

Returns the value for a given property. See the set() method for details.

=cut

sub get {
	my $self = shift;
	my $name = shift;
	if ($name eq "parameters") {
		my $parameters = JSON::jsonToObj($self->{_data}{$name});
		return $parameters->{parameters};
	}
	return $self->{_data}{$name};
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this instance.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 getNextActivity ( )

Returns a reference to the next activity in this workflow from the current position of this instance.

=cut

sub getNextActivity {
	my $self = shift;
	my $workflow = $self->getWorkflow;
	return undef unless defined $workflow;
	return $workflow->getNextActivity($self->get("currentActivityId"));
}

#-------------------------------------------------------------------

=head2 getScratch ( name ) 

Returns the value for a given scratch variable. 

=cut

sub getScratch {
	my $self = shift;
	my $name = shift;
	unless (exists $self->{_scratch}) {
		$self->{_scratch} = $self->session->db->buildHashRef("select name,value from WorkflowInstanceScratch where instanceId=?", [ $self->getId ]);
	}
	return $self->{_scratch}{$name};
}

#-------------------------------------------------------------------

=head2 getWorkflow ( )

Returns a reference to the workflow object this instance is associated with.

=cut

sub getWorkflow {
	my $self = shift;
	return WebGUI::Workflow->new($self->session, $self->get("workflowId"));
}

#-------------------------------------------------------------------

=head2 new ( session, instanceId )

Constructor.

=head3 session

A reference to the current session.

=head3 instanceId 

A unique id refering to a workflow instance.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $instanceId = shift;
	my $data = $session->db->getRow("WorkflowInstance","instanceId", $instanceId);
	return undef unless $data->{instanceId};
	bless {_session=>$session, _id=>$instanceId, _data=>$data}, $class;
}

#-------------------------------------------------------------------

=head2 run ( ) 

Executes the next iteration in this workflow. Returns a status code based upon what happens. The following are the status codes:

 undefined	The workflow doesn't exist.
 disabled	The workflow is disabled.
 done		Workflow has completely run it's course.
 error		Something bad happened. Try again later.
 complete	The activity completed successfully, you may run the next one.
 waiting	The activity is waiting on an external event such as user input.

=cut

sub run {
	my $self = shift;
	my $workflow = $self->getWorkflow;
	return "undefined" unless (defined $workflow);
	return "disabled" unless ($workflow->get("enabled"));
	if ($workflow->get("isSerial")) {
		my ($firstId) = $self->session->db->quickArray("select workflowId from WorkflowInstance order by runningSince");
		return "waiting" if ($workflow->getId ne $firstId); # must wait for currently running instance to complete
	}
	my $activity = $workflow->getNextActivity($self->get("currentActivityId"));
	unless  (defined $activity)  {
		$self->delete;
		return "done";
	}
	$self->session->errorHandler->debug("Running workflow activity ".$activity->getId.", which is a ".(ref $activity).", for instance ".$self->getId.".");
	my $class = $self->get("className");
	my $method = $self->get("methodName");
	my $params = $self->get("parameters");
	my $status = "";
	if ($class && $method) {
		my $cmd = "use $class";
		eval($cmd);
		if ($@) {
			$self->session->errorHandler->error("Error loading activity class $class: ".$@);
			return "error";
		}
		my $object = eval{ $class->$method($self->session, $params) };
		if ($@) {
			$self->session->errorHandler->error("Error instanciating activity (".$activity->getId.") pass-in object: ".$@);
			return "error";
		}
		unless (defined $object) {
			$self->session->errorHandler->error("Pass in object came back undefined for activity (".$activity->getId.") using ".$class.", ".$method.", ".$params.".");
			return "error";
		}
		$status = eval{$activity->execute($object, $self)};
		if ($@) {
			$self->session->errorHandler->error("Caught exception executing workflow activity ".$activity->getId." for instance ".$self->getId." which reported ".$@);
			return "error";
		}
	} else {
		$status = $activity->execute(undef, $self);
		if ($@) {
			$self->session->errorHandler->error("Caught exception executing workflow activity ".$activity->getId." for instance ".$self->getId." which reported ".$@);
			return "error";
		}
	}
	if ($status eq "complete") {
		$self->set({"currentActivityId"=>$activity->getId, notifySpectre=>0});
	}
	return $status;
}


#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( properties )

Sets one or more of the properties of this workflow instance.

=head3 properties

A hash reference containing properties to change.

=head4 priority

An integer of 1, 2, or 3, with 1 being highest priority (run first) and 3 being lowest priority (run last). Defaults to 2.

=head4 workflowId

The id of the workflow we're executing.

=head4 className

The classname of an object that will be created to pass into the workflow.

=head4 methodName

The method name of the constructor for className.

=head4 parameters

The parameters to be passed into the constructor. Note that the system will always pass in the session as the first argument.

=head4 currentActivityId

The unique id of the activity in the workflow that needs to be executed next. If blank, it will execute the first activity in the workflow.

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	$self->{_data}{priority} = $properties->{priority} || $self->{_data}{priority} || 2;
	$self->{_data}{workflowId} = $properties->{workflowId} || $self->{_data}{workflowId};
	$self->{_data}{className} = (exists $properties->{className}) ? $properties->{className} : $self->{_data}{className};
	$self->{_data}{methodName} = (exists $properties->{methodName}) ? $properties->{methodName} : $self->{_data}{methodName};
	if (exists $properties->{parameters}) {
		$self->{_data}{parameters} = JSON::objToJson({parameters => $properties->{parameters}});
	}
	$self->{_data}{currentActivityId} = (exists $properties->{currentActivityId}) ? $properties->{currentActivityId} : $self->{_data}{currentActivityId};
	$self->{_data}{lastUpdate} = time();
	$self->session->db->setRow("WorkflowInstance","instanceId",$self->{_data});
	if ($properties->{notifySpectre}) {
		my $spectre = WebGUI::Workflow::Spectre->new($self->session);
		$spectre->notify("workflow/deleteInstance",$self->getId);
		$spectre->notify("workflow/addInstance", {sitename=>$self->session->config->get("sitename")->[0], instanceId=>$self->getId, priority=>$self->{_data}{priority}});
	}
}

#-------------------------------------------------------------------

=head2 setScratch (name, value)

Attaches a scratch variable to this workflow instance.

=head3 name

A scalar representing the name of the variable.

=head3 value

A scalar value to assign to the variable.

=cut

sub setScratch {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	delete $self->{_scratch};
	$self->session->db->write("replace into WorkflowInstanceScratch (instanceId, name, value) values (?,?,?)", [$self->getId, $name, $value]);
}


1;


