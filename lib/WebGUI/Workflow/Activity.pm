package WebGUI::Workflow::Activity;


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

Package WebGUI::Workflow::Activity

=head1 DESCRIPTION

This package provides the base class for workflow activities.

=head1 SYNOPSIS

 use WebGUI::Workflow::Activity;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 create ( session, workflowId ) 

Creates a new instance of this activity in a workflow.

=head3 session

A reference to the current session.

=head3 workflowId

The unique id of the workflow to attach this activity to.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $workflowId = shift;
	my $activityId = $session->db->setRow("WorkflowActivity","activityId",{activityId=>"new", workflowId=>$workflowId});
	return $class->new($session, $activityId);
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this activity from its workflow.

=cut

sub delete {
	my $self = shift;
	my $sth = $self->session->db->prepare("delete from WorkflowActivityData where activityId=?");
	$sth->execute($self->getId);
	$self->session->db->deleteRow("WorkflowActivity","activityId",$self->getId);
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

=head2 getId ( )

Returns the ID of this instance.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 new ( session, activityId )

Constructor.

=head3 session

A reference to the current session.

=head3 activityId 

A unique id refering to an instance of an activity.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $activityId = shift;
	my $main = $session->db->getRow("WorkflowActivity","activityId", $activityId);
	my $sub = $session->db->buildHashRef("select name,value from WorkflowActivityData where activityId=".$session->db->quote($activityId)); 
	my %data = (%{$main}, %{$sub});
	return undef unless $data->{activityId};
	bless {_session=>$session, _id=>$activityId, _data=>\%data}, $class;
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

=head2 set ( name , value )

Sets a variable for this activity.

=head3 name

The name of the variable to set.

=head3 value

The value of the variable.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->{_data}{$name} = $value;
	if ($name eq "title" || $name eq "description") {
		$self->session->db->setRow("WorkflowActivity","activityId",{ activityId=>$self->getId, title=>$self->get("title"), description=>$self->get("description")});
	} else {
		my $sth = $self->session->db->prepare("replace into WorkflowActivitydata (activityId, name, value) values (?,?,?)");
		$sth->execute($self->getId, $name, $value);
	}
}


1;


