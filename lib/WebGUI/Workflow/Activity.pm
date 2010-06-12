package WebGUI::Workflow::Activity;


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
use WebGUI::HTMLForm;
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::Workflow::Activity

=head1 DESCRIPTION

This package provides the base class for workflow activities.

=head1 SYNOPSIS

 use WebGUI::Workflow::Activity;

=head1 CONSTANTS

The following constants are available from this package.

=head2 COMPLETE

A constant  to be sent to Spectre informing it that this activity completed successfully.

=cut

sub COMPLETE { return "complete" };

=head2 ERROR

A constant to be sent to Spectre informing it that this activity did not execute properly due to some error.

=cut

sub ERROR { return "error" };

=head2 WAITING ( [ waitTime ] )

A constant to be sent to Spectre informing it that this actiivty is
waiting for some other event to be triggered.  This is also used for
long running activities to be released by Spectre and to be requeued.

=head3 waitTime

Instead of sending the constant it will set a time to wait before running the workflow again. Can be any number of seconds 1 or higher.

=cut

sub WAITING {
    my ($class, $waitTime) = @_;
    return "waiting $waitTime";
}

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
	my $id = shift;
	my $classname = shift;
	my ($sequenceNumber) = $session->db->quickArray("select max(sequenceNumber) from WorkflowActivity where workflowId=?", [$workflowId]);
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

=head2 definition ( session, definition )

Sets up the parameters of the activity for use in forms in the workflow editor. This is a class method.

=head3 session

A reference to the current session.

=head3 definition

An array reference containing a list of hash hreferences of properties.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, "Workflow_Activity");
	push (@{$definition}, {
		name=>$i18n->get("topicName"),
		properties=>{
			title=>{
				fieldType=>"text",
				defaultValue=>"Untitled",
				label=>$i18n->get("title"),
				hoverHelp=>$i18n->get("title help")
				},
			description=>{
				fieldType=>"textarea",
				defaultValue=>undef,
				label=>$i18n->get("description"),
				hoverHelp=>$i18n->get("description help")
				}
			}
		});
	return $definition;
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
}

#-------------------------------------------------------------------

=head2 execute ( object, instance )

This method will be called during workflow operation. It needs to be mutated by the sub classes.

=head2 object

A reference to some object that will be passed in to this activity for an action to be taken on it.

=head2 instance

A reference to the workflow instance object.

=cut

sub execute {
	my $self = shift;
	my $object = shift;
	my $instance = shift;
	return 1;
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

Returns the form that will be used to edit the properties of an activity.

=cut

sub getEditForm {
    my $self = shift;
    my $form = WebGUI::HTMLForm->new($self->session);
    $form->submit;
    $form->hidden(name=>"activityId", value=>$self->getId);
    $form->hidden(name=>"className", value=>$self->get("className"));
    my $fullDefinition = $self->definition($self->session);
    $form->dynamicForm($fullDefinition, "properties", $self);
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

=head2 getName ( )

Returns the name of the activity.

=cut

sub getName {
	my $self = shift;
	my $definition = $self->definition($self->session);
	return $definition->[0]{name};
}

#-------------------------------------------------------------------

=head2 getTTL ( )

Returns the maximum amount of time, in seconds, that a Workflow
Activity should run.  Currently 55 seconds.

=cut

sub getTTL {
	return 55;
}

#-------------------------------------------------------------------

=head2 new ( session, activityId  )

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
	return undef unless $main->{activityId};
	$class = $main->{className};
    eval { WebGUI::Pluggable::load($class) };
    if ($@) {
        $session->errorHandler->error($@);
        return undef;
    }  
	my $sub = $session->db->buildHashRef("select name,value from WorkflowActivityData where activityId=?",[$activityId]);
	my %data = (%{$main}, %{$sub});
    for my $definition (reverse @{$class->definition($session)}) {
        for my $property (keys %{$definition->{properties}}) {
            if(!defined $data{$property} || $data{$property} eq '' && $definition->{properties}{$property}{defaultValue}) {
                $data{$property} = $definition->{properties}{$property}{defaultValue};
            }
        }
    }
    bless {_session=>$session, _id=>$activityId, _data=>\%data}, $class;
}

#-------------------------------------------------------------------

=head2 newByPropertyHashRef ( session,  properties )

Constructor.

=head3 session

A reference to the current session.

=head3 properties

A properties hash reference. The className of the properties hash must be valid.

=cut

sub newByPropertyHashRef {
    my $class = shift;
    my $session = shift;
    my $properties = shift;
    return undef unless defined $properties;
    return undef unless exists $properties->{className};
    my $className = $properties->{className};
    eval { WebGUI::Pluggable::load($className) };
    if ($@) {
        $session->errorHandler->error($@);
        return undef;
    }  
    bless {_session=>$session, _id=>$properties->{activityId}, _data => $properties}, $className;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates activity with data from Form.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	my %data;
	my $fullDefinition = $self->definition($self->session);
	foreach my $definition (@{$fullDefinition}) {
		foreach my $property (keys %{$definition->{properties}}) {
			$data{$property} = $self->session->form->process(
				$property,
				$definition->{properties}{$property}{fieldType},
				$definition->{properties}{$property}{defaultValue}
				);
		}
	}
	$data{title} = $fullDefinition->[0]{name} if ($data{title} eq "" || lc($data{title}) eq "untitled");
	foreach my $key (keys %data) {
		$self->set($key, $data{$key});
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


