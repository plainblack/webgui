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

=head2 addActivity ( class ) 

Adds an activity to this workflow.

=head3 class

The classname of the activity to add.

=cut

sub addActivity {
	my $self = shift;
	my $class = shift;
	$class->create($self->session, $self->getId);
}


#-------------------------------------------------------------------

=head2 create ( session ) 

Creates a new instance of a workflow.

=head3 session

A reference to the current session.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $workflowId = $session->db->setRow("Workflow","workflowId",{workflowId=>"new",enabled=>0});
	return $class->new($session, $workflowId);
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

Removes an activity from this workflow.

=head3 activityId

The unique id of the activity to remove.

=cut

sub deleteActivity {
	my $self = shift;
	my $activityId = shift;
	my ($class) = $self->session->db->quickArray("select className from WorkflowActivity where activityId=?",[$activityId]);
	$class->new($self->session, $activityId)->delete;
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
	return $self->{_data}{shift};
}


#-------------------------------------------------------------------

=head2 getActivities ( )

Returns an array reference of the activity objects associated with this workflow.

=cut

sub getActivities {
	my $self = shift;
	my @activities = ();
	my $rs = $self->session->db->prepare("select activityId, className from WorkflowActivity where workflowId=? order by sequenceNumber");
	$rs->execute([$self->getId]);
	while (my ($activityId, $class) = $rs->array) {
		push(@activities, $class->new($self->session, $activityId));
	}
	return \@activities;
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
	my $rs = $self->session->db->read("select activityId, className from WorkflowActivity where workflowId=? 
		and sequenceNumber>=? order by sequenceNumber", [$self->getId, $sequenceNumber]);
	my ($id, $class) = $rs->array;
	$rs->finish;
	return $class->new($self->session, $id);
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

A string indicating the type of object this workflow will be operating on. Valid values are "none", "versiontag" and "user".

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	if ($properties->{enabled} == 1) {
		$self->{_data}{enabled} = 1;
	} elsif ($properties->{enabled} == 0) {
		$self->{_data}{enabled} = 0;
	}
	$self->{_data}{title} = $properties->{title} || $self->{_data}{title} || "Untitled";
	$self->{_data}{description} = (exists $properties->{description}) ? $properties->{description} : $self->{_data}{description};
	$self->{_data}{type} = $properties->{type} || $self->{_data}{type} || "none";
	$self->session->db->setRow("Workflow","workflowId",$self->{_data});
}


1;


