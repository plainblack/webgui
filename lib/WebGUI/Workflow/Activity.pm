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
use WebGUI::HTMLForm;


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

=head2 create ( session, workflowId [, id, classname  ] ) 

Creates a new instance of this activity in a workflow.

=head3 session

A reference to the current session.

=head3 workflowId

The unique id of the workflow to attach this activity to.

=head3 id

Normally an ID will be generated for you, but if you want to override this and provide your own 22 character id, then you can specify it here.

=head3 classname

The classname of the activity you wish to create.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $workflowId = shift;
	my $classname = shift;
	my $id = shift;
	my ($sequenceNumber) = $session->db->quickArray("select count(*) from WorkflowActivity where workflowId=?", [$workflowId]);
	$sequenceNumber++;
	my $activityId = $session->db->setRow("WorkflowActivity","activityId", {
		sequenceNumber=>$sequenceNumber, 
		activityId=>"new", 
		className=>$classname || $class, 
		workflowId=>$workflowId
		}, $id);
	return $class->new($session, $activityId, $classname);
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this activity from its workflow.

=cut

sub delete {
	my $self = shift;
	my $sth = $self->session->db->prepare("delete from WorkflowActivityData where activityId=?");
	$sth->execute([$self->getId]);
	$self->session->db->deleteRow("WorkflowActivity","activityId",$self->getId);
	undef $self;
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

=head2 execute ( object )

This method will be called during workflow operation. It needs to be overridden by the base classes.

=head2 object

A reference to some object that will be passed in to this activity for an action to be taken on it.

=cut

sub execute {
	my $self = shift;
	my $object = shift;
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

=head2 getEditForm ( )

Returns a WebGUI::HTMLForm object that represents the parameters of this activity. This method must be extended by the subclasses.

=cut 

sub getEditForm {
	my $self = shift;
	my $form = WebGUI::HTMLForm->new($self->session);
	return $form;
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

=head2 getName ( session )

Returns the name of the activity. Must be overridden. This is a class method.

=head3 session

A reference to the current session.

=cut

sub getName {
	my $session = shift;
	return "Unnamed";
}

#-------------------------------------------------------------------

=head2 getType ( )

Returns the type of workflow that this activity may be used in. Unless this method is overriden, the type is "none". This is a class method.

=cut

sub getType {
	return "none";
}


#-------------------------------------------------------------------

=head2 new ( session, activityId [, classname] )

Constructor.

=head3 session

A reference to the current session.

=head3 activityId 

A unique id refering to an instance of an activity.

=head3 classname

The classsname of the activity you wish to add.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $activityId = shift;
	my $className = shift;
	my $main = $session->db->getRow("WorkflowActivity","activityId", $activityId);
	return undef unless $main->{activityId};
	if ($className) {
                my $cmd = "use ".$className;
                eval ($cmd);
                if ($@) {
                        $session->errorHandler->error("Couldn't compile workflow activity package: ".$className.". Root cause: ".$@);                        
			return undef;                
		}
                $class = $className;
        }
	my $sub = $session->db->buildHashRef("select name,value from WorkflowActivityData where activityId=?",[$activityId]); 
	my %data = (%{$main}, %{$sub});
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
		my $sth = $self->session->db->prepare("replace into WorkflowActivityData (activityId, name, value) values (?,?,?)");
		$sth->execute([$self->getId, $name, $value]);
	}
}


1;


