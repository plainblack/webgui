package WebGUI::Workflow;


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
use WebGUI::Workflow::Activity;

=head1 NAME

Package WebGUI::Workflow

=head1 DESCRIPTION

This package provides the API for manipulating workflows.

=head1 SYNOPSIS

 use WebGUI::Workflow;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addActivity ( class [, id ] ) 

Adds an activity to this workflow. Returns a reference to the new activity object.

=head3 class

The classname of the activity to add.

=head3 id

Normally an ID will be generated for you, but if you want to override this and provide your own 22 character id, then you can specify it here.

=cut

sub addActivity {
	my $self = shift;
	my $class = shift;
	my $id = shift;
	return WebGUI::Workflow::Activity->create($self->session, $self->getId, $id, $class);
}


#-------------------------------------------------------------------

=head2 create ( session, properties, [, id ] ) 

Creates a new instance of a workflow.

=head3 session

A reference to the current session.

=head3 properties

A hash reference of properties to set for this workflow. See set() for details.

=head3 id

Normally an ID will be generated for you, but if you want to override this and provide your own 22 character id, then you can specify it here.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
	my $id = shift;
	my $workflowId = $session->db->setRow("Workflow","workflowId",{workflowId=>"new",enabled=>0},$id);
	my $self = $class->new($session, $workflowId);
	$self->set($properties);
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this workflow and everything associated with it..

=cut

sub delete {
	my $self = shift;

	foreach my $cron (@{$self->getCrons}) {
		$cron->delete;
	}

	foreach my $instance (@{$self->getInstances}) {
		$instance->delete;
	}

	foreach my $activity (@{$self->getActivities}) {
		$activity->delete;
	}

	$self->session->db->deleteRow("Workflow","workflowId",$self->getId);
}

#-------------------------------------------------------------------

=head2 deleteActivity ( activityId )

Removes an activity from this workflow. This is just a convenience method, so you don't have to manually load and construct activity objects when you're already working with a workflow.

=head3 activityId

The unique id of the activity to remove.

=cut

sub deleteActivity {
	my $self = shift;
	my $activityId = shift;
	my $activity = $self->getActivity($activityId);
	if ($activity) {
        $activity->delete;
        $self->reorderActivities;
    }
}

#-------------------------------------------------------------------

=head2 demoteActivity ( activityId ) 

Moves an activity down one position in the execution order.

=head3 activityId

The id of the activity to move.

=cut

sub demoteActivity {
	my $self = shift;
	my $thisId = shift;
        my ($thisSeq) = $self->session->db->quickArray("select sequenceNumber from WorkflowActivity where activityId=?",[$thisId]);
        my ($otherId) = $self->session->db->quickArray("select activityId from WorkflowActivity where workflowId=? and sequenceNumber=?",[$self->getId, $thisSeq+1]);
        if ($otherId ne "") {
                $self->session->db->write("update WorkflowActivity set sequenceNumber=sequenceNumber+1 where activityId=?", [$thisId]);
                $self->session->db->write("update WorkflowActivity set sequenceNumber=sequenceNumber-1 where activityId=?", [$otherId]);
                $self->reorderActivities;
        }
}

#-------------------------------------------------------------------

=head2 get ( name ) 

Returns the value for a given property.

=cut

sub get {
	my $self = shift;
	my $name = shift;
	return $self->{_data}{$name};
}


#-------------------------------------------------------------------

=head2 getActivity ( activityId )

Retrieves an activity object. This is just a convenience method, so you don't have to manually load and construct activity objects when you're already working with a workflow.

=head3 activityId

The unique id of the activity.

=cut

sub getActivity {
	my $self = shift;
	my $activityId = shift;
	my $activity = WebGUI::Workflow::Activity->new($self->session, $activityId);
    return $activity;
}

#-------------------------------------------------------------------

=head2 getActivities ( )

Returns an array reference of the activity objects associated with this workflow.

=cut

sub getActivities {
	my $self = shift;
	my @activities = ();
	my $rs = $self->session->db->prepare("select activityId from WorkflowActivity where workflowId=? order by sequenceNumber");
	$rs->execute([$self->getId]);
	while (my ($activityId) = $rs->array) {
		push(@activities, $self->getActivity($activityId));
	}
	return \@activities;
}

#-------------------------------------------------------------------

=head2 getInstances ( )

Returns an array reference of the instance objects currently existing for this workflow.

=cut

sub getInstances {
	my $self = shift;
	my @instances = ();
	my $rs = $self->session->db->read("SELECT instanceId FROM WorkflowInstance WHERE workflowId = ?", [$self->getId]);
	while (my ($instanceId) = $rs->array) {
		push(@instances, WebGUI::Workflow::Instance->new($self->session, $instanceId));
	}
	return \@instances;
}

#-------------------------------------------------------------------

=head2 getCrons ( )

Returns an array reference of the cron objects that trigger this workflow.

=cut

sub getCrons {
	my $self = shift;
	my @crons = ();
	my $rs = $self->session->db->read("SELECT taskId FROM WorkflowSchedule WHERE workflowId = ?", [$self->getId]);
	while (my ($taskId) = $rs->array) {
		push(@crons, WebGUI::Workflow::Cron->new($self->session, $taskId));
	}
	return \@crons;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this workflow.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 getList ( session, [ type ] )

Returns a hash reference of workflowId/title pairs of all enabled workflows.  This is a class method.

=head3 session

A reference to the current session.

=head3 type

If specified this will limit the list to a certain type of workflow based upon the object type that the workflow is set up to handle.

=cut

sub getList {
	my $class = shift;
	my $session = shift;
	my $type = shift;
	my $sql = "select workflowId, title from Workflow where enabled=1";
    my @params;
	if ($type) {
		$sql .= " and type=?";
		push(@params, $type);
	}
	return $session->db->buildHashRef($sql, \@params);
}


#-------------------------------------------------------------------

=head2 getNextActivity ( [ activityId ] )

Returns the next activity in the workflow after the activity specified.
If no activity id is specified, then the first workflow will be returned.

=head3 activityId

The unique id of an activity in this workflow.

=cut

sub getNextActivity {
	my $self       = shift;
	my $activityId = shift;
    my $id         = $self->getNextActivityId($activityId);
	return $self->getActivity($id);
}


#-------------------------------------------------------------------

=head2 getNextActivityId ( [ activityId ] )

Returns the ID of the next activity in the workflow after the activity specified.
If no activity id is specified, then the first workflow will be returned.

=head3 activityId

The unique id of an activity in this workflow.

=cut

sub getNextActivityId {
	my $self       = shift;
	my $activityId = shift;
	my ($sequenceNumber) = $self->session->db->quickArray("select sequenceNumber from WorkflowActivity where activityId=?", [$activityId]);
	$sequenceNumber++;
	my ($id) = $self->session->db->quickArray("select activityId from WorkflowActivity where workflowId=? 
		and sequenceNumber>=? order by sequenceNumber", [$self->getId, $sequenceNumber]);
    return $id;
}


#-------------------------------------------------------------------

=head2 hasNextActivity ( [ activityId ] )

Returns true if there is an activity after the specified activity.
If no activity id is specified, then the first workflow will be returned.

=head3 activityId

The unique id of an activity in this workflow.

=cut

sub hasNextActivity {
	my $self       = shift;
    return $self->getNextActivityId(@_) ? 1 : 0;
}


#-------------------------------------------------------------------

=head2 isParallel ( ) 

Returns 1 if the mode is set to "parallel".

=cut

sub isParallel {
    my $self = shift;
    return ($self->get("mode") eq "parallel") ? 1 : 0;
}


#-------------------------------------------------------------------

=head2 isRealtime ( ) 

Depricated. Always returns 0.

=cut

sub isRealtime {
    return 0;
}


#-------------------------------------------------------------------

=head2 isSerial ( ) 

Returns 1 if the mode is set to "serial".

=cut

sub isSerial {
    my $self = shift;
    return ($self->get("mode") eq "serial") ? 1 : 0;
}


#-------------------------------------------------------------------

=head2 isSingleton ( ) 

Returns 1 if the mode is set to "singleton".

=cut

sub isSingleton {
    my $self = shift;
    return ($self->get("mode") eq "singleton") ? 1 : 0;
}


#-------------------------------------------------------------------

=head2 new ( session, workflowId )

Constructor.

=head3 session

A reference to the current session.

=head3 workflowId

The unique id of this workflow.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $workflowId = shift;
	my $data = $session->db->getRow("Workflow","workflowId", $workflowId);
	return undef unless $data->{workflowId};
	bless {_session=>$session, _id=>$workflowId, _data=>$data}, $class;
}

#-------------------------------------------------------------------

=head2 promoteActivity ( activityId ) 

Moves an activity up one position in the execution order.

=head3 activityId

The id of the activity to move.

=cut

sub promoteActivity {
	my $self = shift;
	my $thisId = shift;
        my ($thisSeq) = $self->session->db->quickArray("select sequenceNumber from WorkflowActivity where activityId=?",[$thisId]);
        my ($otherId) = $self->session->db->quickArray("select activityId from WorkflowActivity where workflowId=? and sequenceNumber=?",[$self->getId, $thisSeq-1]);
        if ($otherId ne "") {
                $self->session->db->write("update WorkflowActivity set sequenceNumber=sequenceNumber-1 where activityId=?", [$thisId]);
                $self->session->db->write("update WorkflowActivity set sequenceNumber=sequenceNumber+1 where activityId=?", [$otherId]);
                $self->reorderActivities;
        }
}

#-------------------------------------------------------------------

=head3 reorderActivities ( )

Reorders the acitivities to make sure they're consecutive.

=cut

sub reorderActivities {
	my $self = shift;
        my $sth = $self->session->db->read("select activityId from WorkflowActivity where workflowId=? order by sequenceNumber",[$self->getId]);
	my $i = 0;
        while (my ($id) = $sth->array) {
                $i++;   
                $self->session->db->write("update WorkflowActivity set sequenceNumber=? where activityId=?",[$i, $id]);
        }               
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

Sets a variable for this workflow.

=head3 properties

A hash reference containing the properties to set.

=head4 title

A title indicating what this workflow does. It should be short and descriptive as it will appear in dropdown forms.

=head4 description

A longer description of the workflow.

=head4 enabled

A boolean indicating whether this workflow may be executed right now.

=head4 type

A string indicating the type of object this workflow will be operating on. Valid values are "None", or any object type, like "WebGUI::VersionTag".

=head4 mode

A string containing one of "singleton", "parallel", "serial", or "realtime". Parallel is the default and should be
used in most situations. Singletons will allow only one instance of the workflow to be created at one time. New
instances will be destroyed immediately if a one instance of a singleton already exists. Serial workflows will run
instances sequentially in FIFO. Realtime workflows will run immediately without being handed off to Spectre for
governance.

=cut

sub set {
	my $self = shift;
	my $properties = shift;

    # depricated. replaced by mode.
	if ($properties->{isSerial} == 1) {
		$properties->{mode} = "serial";
	}
	if ($properties->{isSingleton} == 1) {
		$properties->{mode} = "singleton";
	}

    $self->{_data}{mode}        = $properties->{mode} || $self->{_data}{mode} || "parallel";
	$self->{_data}{enabled}     = exists $properties->{enabled} ? $properties->{enabled} : $self->{_data}{enabled};
	$self->{_data}{title}       = $properties->{title} || $self->{_data}{title} || "Untitled";
	$self->{_data}{description} = (exists $properties->{description}) ? $properties->{description} : $self->{_data}{description};
	$self->{_data}{type}        = $properties->{type} || $self->{_data}{type} || "None";
	$self->session->db->setRow("Workflow","workflowId",$self->{_data});
}

=head1 SEE ALSO

L<WebGUI::Workflow::Instance>

After creating a workflow, you need to create an instance of that workflow to kick off activities in it.

=cut


1;


