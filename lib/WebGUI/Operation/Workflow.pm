package WebGUI::Operation::Workflow;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Workflow;
use WebGUI::Workflow::Activity;
use WebGUI::Workflow::Instance;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Operations::Workflow

=head1 DESCRIPTION

Operation handler for managing workflows.

=cut

#-------------------------------------------------------------------

=head2 www_addWorkflow ()

Allows the user to choose the type of workflow that's going to be created. 

=cut

sub www_addWorkflow {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		name=>"op",
		value=>"addWorkflowSave"
		);
	my %options = ();
	foreach my $object (keys %{$session->config->get("workflowActivities")}) {
		if ($object eq "None") {
			$options{$object} = $i18n->get("no object");
		} else {
			$options{$object} = $object;
		}
	}
	$f->selectBox(
		name=>"type",
		label=>$i18n->get("object type"),
		options=>\%options,
		value=>"None",
		hoverHelp=>$i18n->get("object type help")
		);
	$f->submit;
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));
	return $ac->render($f->print);
}

#-------------------------------------------------------------------

=head2 www_addWorkflowSave ()

Saves the results from www_addWorkflow().

=cut

sub www_addWorkflowSave {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->create($session, {type=>$session->form->get("type")});	
	return www_editWorkflow($session, $workflow);
}

#-------------------------------------------------------------------

=head2 www_deleteWorkflow ( )

Deletes an entire workflow.

=cut

sub www_deleteWorkflow {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId"));
	$workflow->delete if defined $workflow;
	return www_manageWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_deleteWorkflowActivity ( )

Deletes an activity from a workflow.

=cut

sub www_deleteWorkflowActivity {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId"));
	if (defined $workflow) {
		$workflow->deleteActivity($session->form->get("activityId"));
		$workflow->set({enabled=>0});
	}
	return www_editWorkflow($session);
}

#------------------------------------------------------------------

=head2 www_demoteWorkflowActivity ( session )

Moves a workflow activity down one position in the execution order.

=head3 session

A reference to the current session.

=cut

sub www_demoteWorkflowActivity {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->new($session, $session->form->param("workflowId"));
	$workflow->demoteActivity($session->form->param("activityId"));
	return www_editWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_editWorkflow ( session, workflow )

Displays displays the editable properties of a workflow.

=cut

sub www_editWorkflow {
	my $session = shift;
	my $workflow = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	$workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId")) unless (defined $workflow);
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $workflowActivities = $session->config->get("workflowActivities");
	my $addmenu = '<div style="float: left; width: 200px; font-size: 11px;">';
	foreach my $class (@{$workflowActivities->{$workflow->get("type")}}) {
		my $activity = WebGUI::Workflow::Activity->newByPropertyHashRef($session, {className=>$class});
		$addmenu .= '<a href="'.$session->url->page("op=editWorkflowActivity;className=".$class.";workflowId=".$workflow->getId).'">'.$activity->getName."</a><br />\n";
	}	
	$addmenu .= '</div>';
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		name=>"op",
		value=>"editWorkflowSave"
		);
	$f->hidden(
		name=>"workflowId",
		value=>$workflow->getId
		);
	$f->readOnly(
		label=>$i18n->get("workflowId"),
		value=>$workflow->getId
		);
	$f->readOnly(
		label=>$i18n->get("object type"),
		value=>$workflow->get("type")
		);
	$f->text(
		name=>"title",
		value=>$workflow->get("title"),
		label=>$i18n->get("title"),
		hoverHelp=>$i18n->get("title help")
		);
	$f->textarea(
		name=>"description",
		value=>$workflow->get("description"),
		label=>$i18n->get("description"),
		hoverHelp=>$i18n->get("description help")
		);
	$f->yesNo(
		name=>"enabled",
		value=>$workflow->get("enabled"),
		defaultValue=>0,
		label=>$i18n->get("is enabled"),
		hoverHelp=>$i18n->get("is enabled help")
		);
	$f->yesNo(
		name=>"isSingleton",
		value=>$workflow->get("isSingleton"),
		defaultValue=>0,
		label=>$i18n->get("is singleton"),
		hoverHelp=>$i18n->get("is singleton help")
		);
	$f->yesNo(
		name=>"isSerial",
		value=>$workflow->get("isSerial"),
		defaultValue=>0,
		label=>$i18n->get("is serial"),
		hoverHelp=>$i18n->get("is serial help")
		);
	$f->submit;
	my $steps = '<table class="content">';
	my $rs = $session->db->read("select activityId, title from WorkflowActivity where workflowId=? order by sequenceNumber",[$workflow->getId]);
	while (my ($id, $title) = $rs->array) {
		$steps .= '<tr><td>'
			.$session->icon->delete("op=deleteWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id, undef, $i18n->get("confirm delete activity"))
			.$session->icon->edit("op=editWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id)
			.$session->icon->moveDown("op=demoteWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id)
			.$session->icon->moveUp("op=promoteWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id)
			.'</td><td>'.$title.'</td></tr>';	
	}
	$steps .= '</table>';
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
	$ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));
	return $ac->render($f->print.$addmenu.$steps);
}


#-------------------------------------------------------------------

=head2 www_editWorkflowSave ( )

Saves the results of www_editWorkflow()

=cut

sub www_editWorkflowSave {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->new($session, $session->form->param("workflowId"));
	$workflow->set({
		enabled=>$session->form->get("enabled","yesNo"),
		isSerial=>$session->form->get("isSerial","yesNo"),
		title=>$session->form->get("title"),
		description=>$session->form->get("description","textarea"),
		});
	return www_editWorkflow($session, $workflow);
}


#-------------------------------------------------------------------

=head2 www_editWorkflowActivity ( )

Displays a form to edit the properties of a workflow activity.

=cut

sub www_editWorkflowActivity {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $activity = '';
	if ($session->form->get("className")) {
		$activity = WebGUI::Workflow::Activity->newByPropertyHashRef($session, {activityId=>"new",className=>$session->form->get("className")});
	} else {
		$activity = WebGUI::Workflow::Activity->new($session, $session->form->get("activityId"));
	}
	my $form = $activity->getEditForm;
	$form->hidden( name=>"op", value=>"editWorkflowActivitySave");
	$form->hidden( name=>"workflowId", value=>$session->form->get("workflowId"));
	$form->submit;
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
	$ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));
	return $ac->render($form->print,$activity->getName);
}

#-------------------------------------------------------------------

=head2 www_editWorkflowActivitySave ( )

Saves the results of www_editWorkflowActivity().

=cut

sub www_editWorkflowActivitySave {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId"));
	if (defined $workflow) {
		my $activityId = $session->form->get("activityId");
		my $activity = '';
		if ($activityId eq "new") {
			$activity = $workflow->addActivity($session->form->get("className"));
		} else {
			$activity = $workflow->getActivity($activityId);
		}
		$activity->processPropertiesFromFormPost;
	}
	return www_editWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_manageWorkflows ( )

Display a list of the workflows.

=cut

sub www_manageWorkflows {
	my $session = shift;
        return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $output = '<table width="100%">'; 
	my $rs = $session->db->read("select workflowId, title, enabled from Workflow order by title");
	while (my ($id, $title, $enabled) = $rs->array) {
		$output .= '<tr><td>'
			.$session->icon->delete("op=deleteWorkflow;workflowId=".$id, undef, $i18n->get("are you sure you want to delete this workflow"))
			.$session->icon->edit("op=editWorkflow;workflowId=".$id)
			.'</td><td>'.$title.'</td><td>'
			.($enabled ? $i18n->get("enabled") : $i18n->get("disabled"))
			."</td></tr>\n";
	}
	$output .= '</table>';
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
	return $ac->render($output);
}


#------------------------------------------------------------------

=head2 www_promoteWorkflowActivity ( session )

Moves a workflow activity up one position in the execution order.

=head3 session

A reference to the current session.

=cut

sub www_promoteWorkflowActivity {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup("pbgroup000000000000015"));
	my $workflow = WebGUI::Workflow->new($session, $session->form->param("workflowId"));
	$workflow->promoteActivity($session->form->param("activityId"));
	return www_editWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_runWorkflow ( )

Checks to ensure the requestor is who we think it is, and then executes a workflow and returns the results.

=cut

sub www_runWorkflow {
        my $session = shift;
	$session->http->setMimeType("text/plain");
	$session->http->setCacheControl("none");
	unless (isInSubnet($session->env->get("REMOTE_ADDR"), $session->config->get("spectreSubnets"))) {
		$session->errorHandler->security("make a Spectre workflow runner request, but we're only allowed to accept requests from ".join(",",@{$session->config->get("spectreSubnets")}).".");
        	return "error";
	}
	my $instanceId = $session->form->param("instanceId");
	if ($instanceId) {
		my $instance = WebGUI::Workflow::Instance->new($session, $instanceId);
		if (defined $instance) {
			return $instance->run;
		}
		return "complete";
	}
	$session->errorHandler->warn("No instance ID passed to workflow runner.");
	return "error";
}

1;
