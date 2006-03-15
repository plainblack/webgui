package WebGUI::Workflow;


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
	# delete crons
	foreach my $activity (@{$self->getActivities}) {
		$activity->delete;
	}
	# delete instances
	$self->session->db->deleteRow("Workflow","workflowId",$self->getId);
	$self->undef;
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
	$activity->delete if ($activity);
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
	return WebGUI::Workflow::Activity->new($self->session, $activityId);
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

=head2 getId ( )

Returns the ID of this workflow.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 getList ( session, [ type ] )

Returns a hash reference of workflowId/title pairs of all the workflows defined in the system. This is a class method. Note that this will not return anything that is disabled.

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
	$sql .= " and type=?" if ($type);
	return $session->db->buildHashRef($sql, [$type]);
}


#-------------------------------------------------------------------

=head2 getNextActivity ( [ activityId ] )

Returns the next activity in the workflow after the activity specified. If no activity id is specified, then the first workflow will be returned.

=head3 activityId

The unique id of an activity in this workflow.

=cut

sub getNextActivity {
	my $self = shift;
	my $activityId = shift;
	my ($sequenceNumber) = $self->session->db->quickArray("select sequenceNumber from WorkflowActivity where activityId=?", [$activityId]);
	$sequenceNumber++;
	my ($id) = $self->session->db->quickArray("select activityId from WorkflowActivity where workflowId=? 
		and sequenceNumber>=? order by sequenceNumber", [$self->getId, $sequenceNumber]);
	return $self->getActivity($id);
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

=head4 isSerial

A boolean indicating whether this workflow can be run in parallel or serial. If it's serial, then only one instance of the workflow will be allowed to be created at a given time. So if you try to create a new instance of it, and one instance is already created, the create() method will return undef instead of a reference to the object.

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	if ($properties->{enabled} == 1) {
		$self->{_data}{enabled} = 1;
	} elsif ($properties->{enabled} == 0) {
		$self->{_data}{enabled} = 0;
	}
	if ($properties->{isSerial} == 1) {
		$self->{_data}{isSerial} = 1;
	} elsif ($properties->{isSerial} == 0) {
		$self->{_data}{isSerial} = 0;
	}
	$self->{_data}{title} = $properties->{title} || $self->{_data}{title} || "Untitled";
	$self->{_data}{description} = (exists $properties->{description}) ? $properties->{description} : $self->{_data}{description};
	$self->{_data}{type} = $properties->{type} || $self->{_data}{type} || "None";
	$self->session->db->setRow("Workflow","workflowId",$self->{_data});
}


1;


