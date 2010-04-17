package WebGUI::Workflow::Instance;


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
use JSON;
use WebGUI::Pluggable;
use WebGUI::Workflow::Spectre;
use WebGUI::Workflow;
use WebGUI::International;
use WebGUI::Operation::Spectre;

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

Creates a new workflow instance and returns a reference to the object. Will return undef if the workflow specified
is singleton and an instance of it already exists.

=head3 session

A reference to the current session.

=head3 properties

The settable properties of the workflow instance. See the set() method for details.

=cut

sub create {
	my ($class, $session, $properties) = @_;

    # do singleton check
    my $placeHolders = [$properties->{workflowId}];
	my ($isSingleton) = $session->db->quickArray("select count(*) from Workflow where workflowId=? and mode='singleton'",$placeHolders);
    my $sql = "select count(*) from WorkflowInstance where workflowId=?";
	if (exists $properties->{parameters}) {
        push @{ $placeHolders }, JSON->new->canonical->encode({parameters => $properties->{parameters}});
        $sql .= ' and parameters=?';
    }
    else {
        $sql .= ' and parameters IS NULL';
    }
	my ($count) = $session->db->quickArray($sql,$placeHolders);
    $session->stow->set('singletonWorkflowClash', 0);
    if ($isSingleton && $count) {
        $session->log->info("An instance of singleton workflow $properties->{workflowId} already exists, not creating a new one");
        $session->stow->set('singletonWorkflowClash', 1);
        return undef
    }

    # create instance
	my $instanceId = $session->db->setRow("WorkflowInstance","instanceId",{instanceId=>"new", runningSince=>time()});
	my $self = $class->new($session, $instanceId, 1);
	$self->set($properties,1);
	
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ( [ skipNotify ] )

Removes this instance.

=head3 skipNotify

A boolean, that if true will not notify Spectre of the delete.

=cut

sub delete {
	my $self = shift;
	my $skipNotify = shift;
	$self->session->db->write("delete from WorkflowInstanceScratch where instanceId=?",[$self->getId]);
	$self->session->db->deleteRow("WorkflowInstance","instanceId",$self->getId);
	WebGUI::Workflow::Spectre->new($self->session)->notify("workflow/deleteInstance",$self->getId) unless ($skipNotify);
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
	# start the workflow in case the programmer forgot
	unless ($self->{_started}) {
		$self->start;
	}
    delete $self->{_workflow};
}


#-------------------------------------------------------------------

=head2 get ( name )

Returns the value for a given property. See the set() method for details.

=cut

sub get {
    my $self = shift;
    my $name = shift;
    if ($name eq "parameters") {
        if ($self->{_data}{parameters}) {
            my $parameters = JSON::decode_json($self->{_data}{parameters});
            return $parameters->{parameters};
        }
        else {
            return {};
        }
    }
    return $self->{_data}{$name};
}

#-------------------------------------------------------------------

=head2 getAllInstances ( session )

Returns an array reference of all the instance objects defined in this system. A class method.

=cut

sub getAllInstances {
	my $class = shift;
	my $session = shift;
    my @instances = ();
    my $rs = $session->db->read("SELECT instanceId FROM WorkflowInstance");
    while (my ($instanceId) = $rs->array) {
        my $instance = WebGUI::Workflow::Instance->new($session, $instanceId);
        if (defined $instance) {
            push(@instances, $instance);
        }
        else {
            $session->errorHandler->warn('Tried to instance instanceId '.$instanceId.' but it returned undef');
        }
    }
    return \@instances;	
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
    unless (exists $self->{_workflow}) {
        $self->{_workflow} = WebGUI::Workflow->new($self->session, $self->get("workflowId"));
    }
    return $self->{_workflow};
}

#-------------------------------------------------------------------

=head2 hasNextActivity ( )

Returns true if the instance has a workflow activity after the current one.

=cut

sub hasNextActivity {
	my $self = shift;
	my $workflow = $self->getWorkflow;
	return undef unless defined $workflow;
	return $workflow->hasNextActivity($self->get("currentActivityId"));
}

#-------------------------------------------------------------------

=head2 new ( session, instanceId, [isNew] )

Constructor.

=head3 session

A reference to the current session.

=head3 instanceId 

A unique id refering to a workflow instance.

=head3 isNew 

A boolean, that, if true, sets that the instance is new and hasn't been started
yet.  This option is really for the L<create> method to use, and should not
be used by developers unless your name starts with JT and ends in Smith.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $instanceId = shift;
    my $isNew = shift;
	my $data = $session->db->getRow("WorkflowInstance","instanceId", $instanceId);
	return undef unless $data->{instanceId};
	my $self = {
        _session    => $session, 
        _id         => $instanceId, 
        _data       => $data, 
        _started    => ($isNew ? 0 : 1)
        };
	bless $self, $class;
    return $self;
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

B>NOTE:> You should normally never run this method. The workflow engine will use it instead. When you're ready to kick off a workflow you've created, use start() instead.

=cut

sub run {
	my $self     = shift;
	my $workflow = $self->getWorkflow;
    my $session  = $self->session;
	unless (defined $workflow) {
		$self->set({lastStatus=>"undefined"}, 1);
		return "undefined";
	}
	unless ($workflow->get("enabled")) {
		$self->set({lastStatus=>"disabled"}, 1);
		return "disabled";
	}
	if ($workflow->isSerial) {
		my ($firstId) = $session->db->quickArray(
            "select instanceId from WorkflowInstance where workflowId=? order by runningSince",
            [$workflow->getId]
        );
		if ($self->getId ne $firstId) { # must wait for currently running instance to complete
			$self->set({lastStatus=>"waiting"}, 1);
			return "waiting";
		}
	}
    ##Undef if returned if there is an error, or if there is not a next activity.
    ##Use hasNextActivity to tell the difference and handle the cases differently.
    if (! $self->hasNextActivity) {
        $self->delete(1);
        return "done";
    }
    my $activity = $self->getNextActivity;
	unless  (defined $activity)  {
        $session->errorHandler->error(
            sprintf q{Unable to load Workflow Activity for activity after id %s in workflow %s},
                $self->get('currentActivityId'),
                $workflow->getId
        );
        $self->set({lastStatus=>"error"}, 1);
        return "error";
	}
	$session->errorHandler->info("Running workflow activity ".$activity->getId.", which is a ".(ref $activity).", for instance ".$self->getId.".");
    my $object = eval { $self->getObject };
    if ( my $e = WebGUI::Error::ObjectNotFound->caught ) {
        $session->log->warn(
            q{The object for this workflow does not exist.  Type: } . $self->get('className') . q{, ID: } . $e->id
        );
        $self->delete(1);
        return "done";
    }
    elsif ($@) {
        $session->errorHandler->error(
            q{Error on workflow instance '} . $self->getId . q{': }. $@
        );
        $self->set({lastStatus=>"error"}, 1);
        return "error";
    }

	my $status = eval { $activity->execute($object, $self) };
	if ($@) {
		$session->errorHandler->error("Caught exception executing workflow activity ".$activity->getId." for instance ".$self->getId." which reported ".$@);
		$self->set({lastStatus=>"error"}, 1);
		return "error";
	}
	if ($status eq "complete") {
		$self->set({lastStatus=>"complete", "currentActivityId"=>$activity->getId}, 1);
	}
    else {
		$self->set({lastStatus=>$status}, 1);
	}
	return $status;
}

#-------------------------------------------------------------------

=head2 getObject

Returns the object this workflow is being used on, or undef if it does not have a related object.

=cut

sub getObject {
    my $self = shift;
    if ( exists $self->{_object} ) {
        return $self->{_object};
    }
    my $class = $self->get("className");
    my $method = $self->get("methodName");
    if ( !($class && $method) ) {
        return undef;
    }
    my @params;
    unless ($self->get('noSession')) {
        push @params, $self->session;
    }
    push @params, $self->get("parameters");
    my $object = WebGUI::Pluggable::instanciate( $class, $method, \@params );
    return $self->{_object} = $object;
}

#-------------------------------------------------------------------

=head2 getInstancesForObject ( session, properties )

Class method.  Finds the instances of running workflows pertaining to a given object.
Returns an array reference of instance IDs, or an array reference of instance objects.

=head3 session

The WebGUI session object to use.

=head3 properties

A hash reference of properties similar to what is given to L</create>.  The relevant entries are:

=head4 className

The class of the object to search for

=head4 methodName

The method used to instanciate the object

=head4 parameters

The parameters to be given to the creation method to instanciate the object

=head4 returnObjects

If true, returns objects instead of instance IDs.

=cut

sub getInstancesForObject {
    my $class = shift;
    my $session = shift;
    my $properties = shift;
    my $className = $properties->{className};
    my $methodName = $properties->{methodName};
    my $parameters = $properties->{parameters};
    my $workflowId = $properties->{workflowId};
    my $returnObjects = $properties->{returnObjects};
    my $dbParameters = JSON->new->canonical->encode({parameters => $parameters});

    my $sql = q{
        SELECT
            instanceId
        FROM
            WorkflowInstance
        WHERE
            className = ?
            AND methodName = ?
            AND parameters = ?
    };
    my $sqlParams = [$className, $methodName, $parameters];
    if ($workflowId) {
        $sql .= 'AND workflowId = ?';
        push @$sqlParams, $workflowId;
    }
    my $instanceIds = $session->db->buildArrayRef($sql, $sqlParams);
    if ($returnObjects) {
        my $instances = [ map {
            $class->new($session, $_);
        } @{$instanceIds} ];
        return $instances;
    }
    return $instanceIds;
}


#-------------------------------------------------------------------

=head2 runAll ( )

Depricated. Runs all activities in this workflow instance, and returns the last status code, which should be "done" unless
something bad happens.

=cut

sub runAll {
    my $self = shift;
    my $status = "complete";
    while ($status eq "complete") {
        $status = $self->run;
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

=head2 set ( properties, [ skipSpectreNotification ])

Sets one or more of the properties of this workflow instance.

=head3 properties

A hash reference containing properties to change.

=head4 priority

An integer of 1, 2, or 3, with 1 being highest priority (run first) and 3 being lowest priority (run last). Defaults to 2.

=head4 workflowId

The id of the workflow we're executing.

=head4 className

The classname of an object that will be created to pass into the workflow.  The object will not
be constructed unless both className and methodName are true.

=head4 methodName

The method name of the constructor for className.  The object will not
be constructed unless both className and methodName are true.

=head4 parameters

A hashref of parameters to be passed into the constructor for className. Note that the system will always pass in the session as the first argument.

=head4 noSession

Normally a reference to the session is the first property passed into methodName(), and then the parameters are passed in. If you're using an object that doesn't need/want a WebGUI::Session object then set noSession to 1. Defaults to 0.

=head4 currentActivityId

The unique id of the activity in the workflow that needs to be executed next. If blank, it will execute the first activity in the workflow.

=head4 lastStatus

See the run() method for a description of statuses.

=head3 skipSpectreNotification

A boolean, that if set to 1 will not inform Spectre of the change in settings.

=cut

sub set {
	my ($self, $properties, $skipNotify) = @_;
	$self->{_data}{lastUpdate} = time();
	$self->{_data}{noSession} = (exists $properties->{noSession}) ? $properties->{noSession} : $self->{_data}{noSession}; 
	$self->{_data}{priority} = $properties->{priority} || $self->{_data}{priority} || 2;
	$self->{_data}{lastStatus} = $properties->{lastStatus} || $self->{_data}{lastStatus};
	$self->{_data}{workflowId} = $properties->{workflowId} || $self->{_data}{workflowId};
	$self->{_data}{className} = (exists $properties->{className}) ? $properties->{className} : $self->{_data}{className};
	$self->{_data}{methodName} = (exists $properties->{methodName}) ? $properties->{methodName} : $self->{_data}{methodName};
	if (exists $properties->{parameters}) {
		$self->{_data}{parameters} = JSON->new->canonical->encode({parameters => $properties->{parameters}});
	}
	$self->{_data}{currentActivityId} = (exists $properties->{currentActivityId}) ? $properties->{currentActivityId} : $self->{_data}{currentActivityId};
	$self->session->db->setRow("WorkflowInstance","instanceId",$self->{_data});
    if ($self->{_started} && !$skipNotify) {
		my $spectre = WebGUI::Workflow::Spectre->new($self->session);
		$spectre->notify("workflow/deleteInstance",$self->getId);
		$spectre->notify("workflow/addInstance", {cookieName=>$self->session->config->getCookieName, gateway=>$self->session->config->get("gateway"), sitename=>$self->session->config->get("sitename")->[0], instanceId=>$self->getId, priority=>$self->{_data}{priority}});
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


#-------------------------------------------------------------------

=head2 start ( [ skipRealtime ] )

Tells the workflow instance that it's ok to start executing.

=head3 skipRealtime

When a workflow instance is started WebGUI tries to run it immediately to see if it can be completely executed in realtime. However, if you'd like to skip this option set this boolean to 1.

=cut

sub start {
	my ($self, $skipRealtime) = @_;
	my $log = $self->session->errorHandler;
	$self->{_started} = 1;
	
	# run the workflow in realtime to start.
	unless ($skipRealtime) {
		my $start = time();
		my $status = "complete";
		$log->info('Trying to execute workflow instance '.$self->getId.' in realtime.');
		while ($status eq "complete" && ($start > time() -10)) { # how much can we run in 10 seconds
			$status = $self->run;
			$log->info('Completed activity for workflow instance '.$self->getId.' in realtime with return status of '.$status.'.');
		}
	
		# we were able to complete the workflow in realtime
		if ($status eq "done") {
			$log->info('Completed workflow instance '.$self->getId.' in realtime.');
            $self->delete(1);
			return undef;
		}		
	}

	# hand off the workflow to spectre
	$log->info('Could not complete workflow instance '.$self->getId.' in realtime, handing off to Spectre.');
	my $spectre = WebGUI::Workflow::Spectre->new($self->session);
	$spectre->notify("workflow/addInstance", {cookieName=>$self->session->config->getCookieName, gateway=>$self->session->config->get("gateway"), sitename=>$self->session->config->get("sitename")->[0], instanceId=>$self->getId, priority=>$self->{_data}{priority}});

    my $spectreTest = WebGUI::Operation::Spectre::spectreTest($self->session);
    if($spectreTest ne "success"){
        return WebGUI::International->new($self->session, "Macro_SpectreCheck")->get($spectreTest);
    }

    return undef;
}

1;


